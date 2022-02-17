![.github/workflows/format-code.yml](https://github.com/ministryofjustice/staff-device-dns-dhcp-admin/workflows/.github/workflows/format-code.yml/badge.svg)

# Staff Device DNS / DHCP Admin

This is the web portal for managing Staff Device DNS / DHCP servers

## Getting Started  

### Authenticate with AWS  

Assuming you have been granted necessary access permissions to the Shared Service Account, please follow the CloudOps best practices provided [step-by-step guide](https://ministryofjustice.github.io/cloud-operations/documentation/team-guide/best-practices/use-aws-sso.html#re-configure-aws-vault) to configure your AWS Vault and AWS Cli with AWS SSO.  

### Prepare the variables  

1. Clone the repository  
1. Copy `.env.example` to `.env`
1. Modify the `.env` file and provide values for variables as below:  

| Variables | How? |
| --- | --- |
| `AWS_PROFILE=` | your **AWS-CLI** profile name for the **Shared Services** AWS account. Check [this guide](https://ministryofjustice.github.io/cloud-operations/documentation/team-guide/best-practices/use-aws-sso.html#re-configure-aws-vault) if you need help. |
| `SHARED_SERVICES_ACCOUNT_ID=` | Account ID of the MoJO Shared Services AWS account.  |
| `REGISTRY_URL=` | `<MoJO Development AWS Account ID>`.dkr.ecr.eu-west-2.amazonaws.com |  
| `ENV=` | Your Terraform namespace from the DNS DHCP Infrastructure repo. |  

3. Copy `.env.development` to `.env.<your terraform namespace>`

### Authenticating Docker with AWS ECR

The Docker base image is stored in ECR. Prior to building the container you must authenticate Docker to the ECR registry. [Details can be found here](https://docs.aws.amazon.com/AmazonECR/latest/userguide/Registries.html#registry_auth).

If you have [aws-vault](https://github.com/99designs/aws-vault#installing) configured according to CloudOps best practices, do the following to authenticate:

```bash
make authenticate-docker
```  

### Prerequisite to starting the App

This repo is dependant on a locally running dhcp network. This is so that the admin app can query the dhcp api without timing out.
1. Clone the repository [here](https://github.com/ministryofjustice/staff-device-dhcp-server)
1. Follow the instructions in the cloned repository to run the dhcp server
1. Navigate back to this repo

### Starting the App

1. If this is the first time you have setup the project:

   1. Build the base containers

      ```sh
      make build-dev
      ```

   2. Setup the database

      ```sh
      make db-setup
      ```

1. Start the application

```sh
$ make serve
```

### Running Tests

1. Setup the test database

```sh
make db-setup
```

2. Run the entire test suite

```sh
make test
```

To run individual tests:

1. Shell onto a test container

```sh
ENV=test make shell
```

2. Run the test file or folder

```sh
bundle exec rspec path/to/spec/file
```

## Scripts

There are two utility scripts in the `./scripts` directory to:

1. Migrate the database schema
2. Deploy new tasks into the service

### Deployment

The `deploy` command is wrapped in a Makefile. It calls `./scripts/deploy` which schedules a zero downtime phased [deployment](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/update-service.html) in ECS.

It doubles the currently running tasks and briefly serves traffic from the new and existing tasks in the service.
The older tasks are eventually decommissioned, and production traffic is gradually shifted over to only the new running tasks.

On CI this command is executed from the [buildspec.yml](./buildspec.yml) file after migrations and publishing the new image to ECR has been completed.

### Targetting the ECS Cluster and Service to Deploy

The ECS infrastructure is managed by Terraform. The name of the cluster and service are [outputs](https://www.terraform.io/docs/configuration/outputs.html) from the Terraform apply. These values are published to SSM Parameter Store, when this container is deployed it pulls those values from Parameter Store and sets them as environment variables.

The deploy script references these environment variables to target the ECS Admin service and cluster. This is to avoid depending on the hardcoded strings.

The build pipeline assumes a role to access the target AWS account.

#### Publishing Image from Local Machine

1. Export the following configurations as an environment variable.

```bash
  export DHCP_DNS_TERRAFORM_OUTPUTS='{
    "admin": {
      "ecs": {
        "cluster_name": "[TARGET_CLUSTER_NAME]",
        "service_name": "[TARGET_SERVICE_NAME]"
      }
    }
  }'
```

This mimics what happens on CI where this environment variable is already set.

When run locally, you need to target the AWS account directly with AWS Vault.

2. Schedule the deployment

```bash
  aws-vault exec [target_aws_account_profile] -- make deploy
```

## Maintenance

### AWS RDS SSL Certificate

The AWS RDS SSL certificate is due to expire August 22, 2024. See [the documentation](https://docs.aws.amazon.com/documentdb/latest/developerguide/ca_cert_rotation.html) for information on updating the certificate closer to the date.

To update the certificate, update the Dockerfile to use the new intermediate (region specific) certificate (found [here](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.SSL.html)), and update the `config/database.yml` to point to the new certificate file path.

## DHCP Data Checks

For information on how to perform the data import before network cutover, please see [the documentation](docs/cutover_data_checks.md).
