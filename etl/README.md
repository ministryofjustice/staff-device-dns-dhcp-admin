# ETL of DHCP Data

This folder contains ad-hoc scripts to extract the required DHCP info from extract files supplied by MoJ suppliers.

## Data Sources

| :warning: WARNING          |
|:---------------------------|
| **The source files contain potentially sensitive information and should never be committed to the repo**. The `/etl/data` directory has been configured with `.gitignore` for this purpose.|

The original data files are stored in MoJ Teams > TEAM - DNS-DHCP - Sec Logging > Files > DXC DNS-DHCP Info. You will need an invite to Teams.

### `Quantum DHCP DNS discovery Updated.xlsx` 

This file contains all of the sites and high level scope data as of August 2020.

### Reservations Directory

Several hundred, per scope extracts containing static reservations.

## Pre-Processing

- Save a copy of `Quantum DHCP DNS discovery Updated.xlsx` to `/etl/data/`
  - Save as CSV to `/etl/data/Quantum.csv`

- Copy all reservation txt files into `/etl/data/reservations`
  - From the data dir run:
  ```bash
  grep " Add reservedip " ./reservations/*.txt > all_reserved_ips.txt
  ```
  - Create `all_reserved_ips_stripped.txt`, with columns `scope,ip,mac,host,description`, by running:
  ```bash
  cut -d '"' -f 1,2,4 all_reserved_ips.txt --output-delimiter=',' |  sed -n 's/^.*Scope //p' | sed -n 's/ Add reservedip /,/p' | sed -n 's/ ,/,/p' | sed 's/ /,/' > all_reserved_ips_stripped.txt
  ```

## Generating Inserts

The ruby scripts write SQL inserts to stdout. The SQL can then be run against the admin db.

Saving the scripts to sql files can be done with redirection. Make sure they are created in the `data` dir to be ignored by git.

E.G. from the `etl` directory:
```bash
ruby generate_site_sql.rb > ./data/01-insert-sites.sql
ruby generate_subnet_sql.rb > ./data/02-insert-subnet.sql
ruby generate_reservations_sql.rb > ./data/03-insert-reservations.sql
```
