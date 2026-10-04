# Home Assistant App: Logspout

_Send HA logging to remote log management systems_

App providing [Logspout](https://github.com/gliderlabs/logspout), including the following adapters:
* [GELF](https://github.com/bertbaron/logspout-gelf)
* Loki
* [Logstash](https://github.com/looplab/logspout-logstash)
* [Splunk](https://github.com/chakrabortymrinal/logspout-splunk)

Logspout collects container logs, forwarding them to a choice of destinations using, amongst others, the syslog or GELF protocol. The destination can be for example a logging service like Papertrail or Loggly, or a local running Elasticsearch or Graylog instance.

By default, builds use the local checkout in `logspout/local/logspout`. CI switches to `LOGSPOUT_SOURCE=git` and records the upstream Logspout version in two parts: `LOGSPOUT_VERSION` keeps the readable tag, while `LOGSPOUT_REF` pins the expected commit SHA. CI verifies that the tag still resolves to that SHA before the image build starts.

The log source depends on protection mode:

* **Protection mode enabled** (default): logs are read from the systemd journal. This gives the app a better security rating. Some container properties (`image_id`, `command`, `created` and labels) are not available.
* **Protection mode disabled**: logs are read using the Docker API, which gives access to all container properties. Access to the Docker API virtually gives access to the whole system, resulting in a rating of 1 for this app. Logspout only uses the API to read container properties and the stdout/stderr output of the containers.

New: detect log levels, exclude containers and filter or change messages per route, with optional rules and a web interface. Nothing changes unless you opt in. See [DOCS.md](./DOCS.md).

# Installation

1. Ensure that 'Advanced Mode' is enabled in your user profile (bottom-left in HA)
1. Click the Home Assistant My button below to add this repository to your Home Assistant

   [![Open your Home Assistant instance and show the add add-on repository dialog with a specific repository URL pre-filled.](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Fbertbaron%2Fhassio-addons)

1. Install the Logspout app
1. Optionally disable 'protection mode' (lowest toggle on the Information tab) to use the Docker API instead of the journal
1. Review the configuration (on the Configuration tab)
1. Start the app
1. Verify the log output on the Log tab

# Configuration

See the Documentation tab or [DOCS.md](./DOCS.md) for for more information.

# More information

**Issue tracker** https://github.com/bertbaron/hassio-addons/issues

**Discussions** https://community.home-assistant.io/t/logspout-add-on-for-sending-ha-logs-to-log-management-systems/423152

The build setup is based on the [logspout-gelf](https://github.com/Vincit/logspout-gelf) container.

![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]
![privileged][privileged-shield]

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[privileged-shield]: https://img.shields.io/badge/privileged-required-orange.svg
