![.github/workflows/format-code.yml](https://github.com/ministryofjustice/staff-device-dns-dhcp-admin/workflows/.github/workflows/format-code.yml/badge.svg)

# Staff Device DNS / DHCP Admin

This is the web frontend for managing Staff Device DNS / DHCP servers

## Development

1. Clone the repository
1. If this is the first time you have setup the project, setup the database.

```sh
make db-setup
```

1. Start the application

```sh
$ make serve
```

### Environment Variables

The following environment variables must be added to .env to authenticate against AWS Cognito.

```
COGNITO_CLIENT_ID
COGNITO_CLIENT_SECRET
COGNITO_USER_POOL_SITE
COGNITO_USER_POOL_ID
```
