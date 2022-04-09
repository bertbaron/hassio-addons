# Home Assistant Add-on: Logspout add-on

_Send HA logging to a remote logging system._

Addon providing [Logspout](https://github.com/gliderlabs/logspout).
This image contains the [GELF module](github.com/micahhausler/logspout-gelf)

## How to use
This add-on requires protection mode to be turned of in order to obtain read-only access to the Docker API.

The configuration is pretty straightforward. See for example the following configuration:

```yaml
routes:
  - gelf://graylog.local:12201
env:
  - name: SYSLOG_HOSTNAME
    value: homeassistant
```      

This will send all logging using GELF to the server at `graylog.local` on port `12201` (UDP). The `source` field in graylog will be set to `homeassistant`.

The list of routes is joined with `,` and passed as argument to `logspout`. The `env` list can be used to set environment variables passed to `logspout`. Please consult the documentation of [Logspout](https://github.com/gliderlabs/logspout) and the [GELF module](github.com/micahhausler/logspout-gelf) module for more information.

The build setup is based on the [logspout-gelf](https://github.com/Vincit/logspout-gelf) container.



![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]
![Supports armhf Architecture][armhf-shield]
![Supports armv7 Architecture][armv7-shield]
![Supports i386 Architecture][i386-shield]

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[armhf-shield]: https://img.shields.io/badge/armhf-yes-green.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-green.svg
[i386-shield]: https://img.shields.io/badge/i386-yes-green.svg
