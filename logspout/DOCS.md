# Home Assistant Add-on: Logspout add-on

_Send HA logging to remote log management systems_

Add-on providing [Logspout](https://github.com/gliderlabs/logspout), including the [GELF adapter](https://github.com/bertbaron/logspout-gelf) and a Loki adapter.

Logspout collects logs using the Docker API, forwarding it to a choice of destinations using, amongst others, the syslog or GELF protocol. The destination can be for example a logging service like Papertrail or Loggly, or a local running Elasticsearch or Graylog instance.

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

This add-on requires protection mode to be turned off in order to obtain access to the Docker API.

The configuration is pretty straightforward. See for example the following configuration:

```yaml
routes:
  - gelf://graylog.home:12201
hostname: homeassistant
```      

This will send all logging using GELF to the server at `graylog.home` on port `12201` (UDP). The `source` field in Graylog will be set to `homeassistant`.


### Option: `routes`

The Logspout routes. These are some example routes to get you started:

 * Graylog (GELF): `gelf://<graylog_host>:12201`
 * Syslog UDP: `syslog+udp://<syslog_host>:514`
 * Papertrail: `syslog+tls://logs3.papertrailapp.com:12345`
 * Loki: `loki://39bd2704-loki:3100` (setup for the [Loki addon](https://github.com/mdegat01/addon-loki))
 * Loki with authentication: `loki+https://<username>:<password-or-token>@<loki-host>[/loki-path]`

   To connect to Loki on grafana.com this basically means that you can prefix the URL you get to use in the Promptail configuration with `loki+`
 * Splunk HEC: See [this issue](https://github.com/bertbaron/hassio-addons/issues/68#issuecomment-2528901821) for configuration details.

Please consult the documentation of [Logspout](https://github.com/gliderlabs/logspout) and the [GELF module](https://github.com/bertbaron/logspout-gelf) module for more information.

### Option `hostname`

The hostname that will be send as part of the logs. Default is `homeassistant`.

### Option `env`

Envirionment variables passed to Logspout when more advanced options are needed which are not (yet) available as add-on options. For example:

```yaml
env:
  - name: SYSLOG_FORMAT
    value: rfc3164
```

# Custom TLS certificate

Custom certificates can be put in the Home Assistant config folder, which is mounted as `/config`.

For example, to use a custom CA certificate, create the file `<configdir>/logspout/ca.pem` using for example the Studio Code Server plugin. Then set environment variable `LOGSPOUT_TLS_CA_CERTS=/config/logspout/ca.pem`: 

```yaml
routes:
  - syslog+tls://graylog.local:6514
env:
  - name: LOGSPOUT_TLS_CA_CERTS
    value: /config/logspout/ca.pem
```      

It is also possible to specify a client key for mutual TLS client authentication. See the [Logspout documentation](https://github.com/gliderlabs/logspout/blob/master/README.md) for more information.

# More information

**Issue tracker** https://github.com/bertbaron/hassio-addons/issues

**Discussions** https://community.home-assistant.io/t/logspout-add-on-for-sending-ha-logs-to-log-management-systems/423152
