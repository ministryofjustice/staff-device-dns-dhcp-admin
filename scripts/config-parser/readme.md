# Performing pre-golive data checks

The ruby code in this directory will allow you to check reservations found in the export of the legacy dhcp server, against what is in our current KEA config.

## Getting Started

Before you begin you will need the following data:
- The FITS ID of the site  for which you wish to perform a data check.
  - Login to the DNS DHCP admin portal.
  - click DHCP.
  - `ctrl + f` the site you are looking for
  - copy the the FITS_#### to `lib/dhcp_config_parser` line 12 (shared_network_id variable).
- A list of subnets for that site.
  - Populate `lib/dhcp_config_parser` line 13 with your subnet list.
- A copy of the latest KEA config (downloaded from S3). (see below).
- A full or partial export dhcp server export from the incumbent provider.

### Obtaining the current KEA config :

- Log into the AWS console and download manually from s3.
- Run `./get_kea_config.sh <<your-production-aws-vault-profile>>` from this directory.
  - This requires `aws-vault` setup with a production account profile.
  - This script will drop the latest KEA config into your data directory.

### Obtaining the legacy data export :

- Legacy data exports will be provided as .zip files from the current provider, usually with a `sitenameVLAN##.txt` file for each subnet (VLAN).
- You can use the below line of powershell to quickly convert those files into an export.txt, which you can copy into your data directory.
- `Get-Content .\sitenameVLAN10.txt, .\sitenameVLAN20.txt | Set-Content export.txt`
- save the export.txt file in the data directory.
---
**Important**

The data directory is .gitignored, so be sure to use it.

---
<br>

### Running the script

1. Ensure you are in the correct directory `staff-device-dns-dhcp-admin/scripts/config-parser`

1. Ensure you've completed the prerequisites as above.

1. Run `ruby bin/dhcp_config_parser.rb`

This will create a `reservation_diff.json` in your data directory. A `kea` or `legacy` key with a value of `null` means that reservation is missing from the associated config. 

You'll also see the exclusion information output directly into the terminal.

