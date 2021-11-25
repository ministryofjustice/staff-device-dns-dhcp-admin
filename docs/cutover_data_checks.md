# Pre Go live checks

Follow the instructions below

## Pre-requisites

_This process can take ~30 minutes._

### Required Information

- export data (save attachment from current provider as export.txt)
    - Note that this file should be UTF-8
    - To ensure this, open the provided file in notepad and save as UTF-8.
    - By default the file will be ANSI encoded when saved from Outlook.
- FITS ID
- List of subnets. (Detailed in the email with the export.)

### DHCP Admin Procedure

1. Navigate to the [portal](https://dhcp-dns-admin.staff.service.justice.gov.uk/sign_in).
1. Click on 'Sign In'.
    (If you don't have access to this please contact Cloud Ops via the [#ask-cloud-ops](https://mojdt.slack.com/archives/C026AFE617T) Slack channel).
1. Click on 'DHCP'.
1. Find (Ctrl + F), on the DHCP page, the site in question.
1. Click on 'Manage' for this site.
1. In each subnet, delete existing reservations.
    - Click Manage for each Subnet
    - Click the 'Delete All Reservations' button.
    - Confirm this action.
1. Click on 'Site' to return to the page for the site.
1. Confirm each of the subnets specified by the current supplier are listed.
    - If they are not, click 'create a new subnet'.
        1. Populate each of the fields (all mandatory).  
        Defaults are:
            | Item          | Value      |
            |---------------|------------|
            | CIDR          | x.x.x.0/24 |
            | Start Address | x.x.x.1    |
            | End Address   | x.x.x.254  |
            | Routers       | x.x.x.1    |
        1. Click on 'Create'.
1. Confirm an exclusion range in each subnet.
    - Ensure the range is `1..39`.
1. Confirm any Super scopes.
    - Open export.txt.
    - Find (Ctrl + F) `superscope` and note any entries that specify the subnet's for the site.
    - Example Super Scope

        ```bash
        Dhcp Server server.domain.name scope 192.168.48.0 set superscope "Site Name"
        Dhcp Server server.domain.name scope 192.168.49.0 set superscope "Site Name"
        ```

    - For any superscopes:
        - Site > Subnet > Add a subnet to this shared network.
        - Select the corresponding subnet from the drop down list.
1. Click on Import
1. Populate the fields (subnet list should be comma separated)
1. Click Submit
