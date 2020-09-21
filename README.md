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

## Maintenance

### AWS RDS SSL certificate

The AWS RDS SSL certificate is due to expire August 22, 2024. See [the documentation](https://docs.aws.amazon.com/documentdb/latest/developerguide/ca_cert_rotation.html) for information on update the certificate closer to the date.

To update the certificate, update the Dockerfile to use the new intermediate (region specific) certificate (found [here](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.SSL.html)), and update the `config/database.yml` to point to the new certificate file path.
