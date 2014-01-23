sensu-check-stashes
===================

Note: As of Sensu 0.12.0 this check is no longer needed and does not work with newer versions of sensu-cli.  If you have an old version of sensu running use sensu-cli 0.2.5 or lower.

A plugin to support sensu-cli and expires field for silenced checks

The sensu-cli has a command `sensu silence HOST -e 30` which will place an expires key in the stash.  This plugin checks the silenced stashes and deletes them when they have expired.

Usage
-----------
1. Drop this file in your sensu plugins directory.
2. Configure the check on the sensu-server

````json
{
  "checks": {
    "check-stashes": {
      "command": "check-stashes.rb -a http://localhost:4567",
      "subscribers": [
        "sensu-server"
      ],
      "interval": 120
    }
  }
}
````
