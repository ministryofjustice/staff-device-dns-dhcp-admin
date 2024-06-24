# Altering Logging Verbosiuty 

Logs for the DHCP server (in Cloudwatch with log group staff-device-development-dhcp-server-log-group) are sent to MIP via Kinesis Firehose.

If MIP request the verbosity of the logging to be altered, the files below will need to be changed:

1. app/lib/use_cases/generate_kea_config.rb
2. spec/fixtures/kea_configs/kea.json
3. spec/lib/data/kea.json

Logs are currently set to INFO e.g. :

```
        "severity": "INFO",
        "debuglevel": 0
      
```

If MIP request them to be reverted to DEBUG:

```
        "severity": "DEBUG",
        "debuglevel": 99
      
```

Once the changes have been merged and the pipeline has ran, further actions need to be taken to deploy these changes. 

The config bucket (mojo-{environment}-nac-config-bucket) will only pick up the new changes once it has been updated. 
To update the config.json file in the bucket a change needs to be made on the admin portal. Once a change is made the new config will be picked up and the changes will be implemented.