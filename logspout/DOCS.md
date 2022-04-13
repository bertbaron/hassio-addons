# Home Assistant Add-on: Logspout add-on

_Send HA logging to a remote log management systems._

Addon providing [Logspout](https://github.com/gliderlabs/logspout), including the [GELF module](https://github.com/micahhausler/logspout-gelf)

# Installation

1. Ensure that 'Advanced Mode' is enabled in your user profile (bottom-left in HA)
1. Add this repository to your Home Assistant add-on repositories:<br>
   [![Open your Home Assistant instance and show the add add-on repository dialog with a specific repository URL pre-filled.](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Fbertbaron%2Fhassio-addons)
1. Install the Logspout add-on
1. Disable 'protection mode' (lowest toggle on the Information tab)
1. Review the configuration (on the Configuration tab)
1. Start the add-on
1. Verify the log output on the Log tab

# Configuration

This add-on requires protection mode to be turned off in order to obtain access to the Docker API.

The configuration is pretty straightforward. See for example the following configuration:

```yaml
routes:
  - gelf://graylog.local:12201
env:
  - name: SYSLOG_HOSTNAME
    value: homeassistant
```      

This will send all logging using GELF to the server at `graylog.local` on port `12201` (UDP). The `source` field in Graylog will be set to `homeassistant`.

The list of routes is joined with `,` and passed as argument to `logspout`. The `env` list can be used to set environment variables passed to `logspout`. Please consult the documentation of [Logspout](https://github.com/gliderlabs/logspout) and the [GELF module](https://github.com/micahhausler/logspout-gelf) module for more information.
