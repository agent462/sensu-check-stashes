sensu-check-stashes
===================

A plugin to support sensu-cli and expires field for silenced checks

The sensu-cli has a command `sensu silence HOST -e 30` which will place an expires key in the stash.  This plugin checks the silenced stashes and deletes them when they have expired.

Usage
-----------
1. Drop this file in your sensu plugins directory.
2. Configure the check on the sensu-server
~~~
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
~~~
