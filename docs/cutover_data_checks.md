### Pre Go live checks 

Follow the instructions below 

### Pre-requisuites 

_This process can take ~30 minutes._

Gather the following data: 
- export data (save attachment from current provider as export.txt)
    * Note that this file should be UTF-8
    * To ensure this, open the provided file in notepad and save as UTF-8.
    * By default the file will be ANSI encoded if directly pulled from Outlook. 
- FITS ID 
- List of subnets



1. Navigate to the [portal](https://dhcp-dns-admin.staff.service.justice.gov.uk/sign_in).
1. Click on 'Sign In'. 
    (If you don't have access to this please contact Cloud Ops via the [#ask-cloud-ops](https://mojdt.slack.com/archives/C026AFE617T) Slack channel).
1. Click on 'DHCP'.
1. Find (Ctrl + F) on the DHCP page search for the site in question.
1. Click on 'Manage' for this site.
1. Delete each of the existing Reservations. 
    * Click Manage for each Subnet
    * Click the 'Delete All Reservations' button.
    * Confirm this action.
1. Click on 'Site' to return to the page for the site in question.
1. Confirm each of the subnets specified by the current supplier are listed. (The information is usually provided via email, with the export).
    * If they are not, click 'create a new subnet'.
        1. Populate each of the fields (all mandatory).
        1. Click on 'Create'.
1. Confirm all exclusion ranges.
    * Open export.txt.
    * Find (Ctrl + F) `Site Name`.
    * Find (Ctrl + F) `excluderange`.
    * Populate the exclusion (Site > Subnet (Manage) > Create exclusion).
    * Repeat for all subnets in your subnet list.
1. Confirm any Super scopes.
    * Open export.txt.
    * Find (Ctrl + F) `superscope`.
    * Look in the superscopes for any subnets in the list.
    * Example Super Scope.
        * `Dhcp Server server.domain.name scope 192.168.48.0 set superscope "Site Name"`
        * `Dhcp Server server.domain.name scope 192.168.49.0 set superscope "Site Name"`
    * For any superscopes.
        * Site > Subnet > Add a subnet to this shared network.
        * Select the corresponding subnet from the drop down list.
1. Click on Import 
1. Populate the fields (subnet list should be comma separated)
1. Click Submit
