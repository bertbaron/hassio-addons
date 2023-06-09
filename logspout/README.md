# Home Assistant Add-on: Logspout add-on

_Send HA logging to remote log management systems_

Add-on providing [Logspout](https://github.com/gliderlabs/logspout), including the following adapters:
* [GELF](https://github.com/bertbaron/logspout-gelf)
* Loki
* [Logstash](https://github.com/looplab/logspout-logstash)

Logspout collects logs using the Docker API, forwarding them to a choice of destinations using, amongst others, the syslog or GELF protocol. The destination can be for example a logging service like Papertrail or Loggly, or a local running Elasticsearch or Graylog instance.

Because Logspout requires access to the Docker API, protection mode has to be disabled. Access to the Docker API virtually gives access to the whole system, resulting in a rating of 1 for this add-on. Logspout only uses the API to read container properties and the stdout/stderr output of the containers.

# Installation

1. Ensure that 'Advanced Mode' is enabled in your user profile (bottom-left in HA)
1. Click the Home Assistant My button below to add this repository to your Home Assistant

   [![Open your Home Assistant instance and show the add add-on repository dialog with a specific repository URL pre-filled.](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Fbertbaron%2Fhassio-addons)

1. Install the Logspout add-on
1. Disable 'protection mode' (lowest toggle on the Information tab)
1. Review the configuration (on the Configuration tab)
1. Start the add-on
1. Verify the log output on the Log tab

# Configuration

See the Documentation tab or [DOCS.md](./DOCS.md) for for more information.

# More information

**Issue tracker** https://github.com/bertbaron/hassio-addons/issues

**Discussions** https://community.home-assistant.io/t/logspout-add-on-for-sending-ha-logs-to-log-management-systems/423152

The build setup is based on the [logspout-gelf](https://github.com/Vincit/logspout-gelf) container.

![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]
![Supports armhf Architecture][armhf-shield]
![Supports armv7 Architecture][armv7-shield]
![Supports i386 Architecture][i386-shield]
![privileged][privileged-shield]

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[armhf-shield]: https://img.shields.io/badge/armhf-yes-green.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-green.svg
[i386-shield]: https://img.shields.io/badge/i386-yes-green.svg
[privileged-shield]: https://img.shields.io/badge/privileged-required-orange.svg
