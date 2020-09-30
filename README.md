![.github/workflows/format-code.yml](https://github.com/ministryofjustice/staff-device-dns-dhcp-admin/workflows/.github/workflows/format-code.yml/badge.svg)

# Staff Device DNS / DHCP Admin

This is the web frontend for managing Staff Device DNS / DHCP servers

## Development

1. Clone the repository
1. If this is the first time you have setup the project
    1. Setup the database.

        ```sh
        make db-setup
        ```

    2. Build the base containers.

        ```sh
        make build-dev
        ```

1. Start the application

```sh
$ make serve
```

### Running tests

1. First setup your test database
```sh
ENV=test make db-setup
```
1. To run the entire test suite
```sh
make test
```
1. If you would like to run individual tests
  1. First shell onto a test container
  ```sh
  ENV=test make shell
  ```
  1. Run the tests you would like, for example rspec.
  ```sh
  bundle exec rspec path/to/spec/file
  ```

### Environment Variables

The following environment variables must be added to .env to authenticate against AWS Cognito.

```
COGNITO_CLIENT_ID
COGNITO_CLIENT_SECRET
COGNITO_USER_POOL_SITE
COGNITO_USER_POOL_ID
```

## Scripts

We have two utility scripts in the `./scripts` directory to:

1. Migrate the database schema
2. Deploy new tasks into the service

### Deployment

The `deploy` command is wrapped in a Makefile, it calls `./scripts/deploy` which schedules a zero downtime phased [deployment](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/update-service.html) in ECS.

It doubles the currently running tasks and briefly serves traffic from the new and existing tasks in the service.
The older tasks are eventually decommissioned, and production traffic is gradually shifted over to only the new running tasks.

On CI this command is executed from the [buildspec.yml](./buildspec.yml) file after migrations and publishing the new image to ECR has been completed.

#### Targetting the ECS cluster and service to deploy

The ECS infrastructure is managed by Terraform. The name of the cluster and service are outputs from the apply and set as environment variables on CI ($DHCP_DNS_TERRAFORM_OUTPUTS). The deploy script references these dynamic names to target the ECS Admin service and cluster. This is to avoid depending on the names of the services and clusters, which may change in the future.

The build pipeline assumes a role to access the target AWS account.

#### Deploying from local machine

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

### AWS RDS SSL certificate

The AWS RDS SSL certificate is due to expire August 22, 2024. See [the documentation](https://docs.aws.amazon.com/documentdb/latest/developerguide/ca_cert_rotation.html) for information on updating the certificate closer to the date.

To update the certificate, update the Dockerfile to use the new intermediate (region specific) certificate (found [here](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.SSL.html)), and update the `config/database.yml` to point to the new certificate file path.
