# Home Assistant App: Logspout

_Send HA logging to remote log management systems_

App providing [Logspout](https://github.com/gliderlabs/logspout), including the [GELF adapter](https://github.com/bertbaron/logspout-gelf) and a Loki adapter.

Logspout collects container logs, forwarding it to a choice of destinations using, amongst others, the syslog or GELF protocol. The destination can be for example a logging service like Papertrail or Loggly, or a local running Elasticsearch or Graylog instance.

The log source depends on protection mode:

 * **Protection mode enabled** (default): logs are read from the systemd journal, which Home Assistant maps read-only into the app. This gives the app a better security rating. The journal does not contain all container properties, so the fields `image_id`, `command` and `created` and the container labels are not sent. Filtering on container labels and `LOGSPOUT=ignore` are not available either. Other fields, like the container id, container name and image name, are the same as with the Docker API.
 * **Protection mode disabled**: logs are read using the Docker API, which gives access to all container properties. Access to the Docker API virtually gives access to the whole system, resulting in a rating of 1 for this app. Logspout only uses the API to read container properties and the stdout/stderr output of the containers.

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

The log source is selected automatically: the Docker API when protection mode is disabled, the journal otherwise.

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

### Option `strip_ansi`

Strip ANSI color codes from forwarded log messages before they are sent to the configured route. This is useful when the destination cannot handle colored terminal output cleanly.

### Option `env`

Environment variables passed to Logspout when more advanced options are needed which are not (yet) available as app options. For example:

```yaml
env:
  - name: SYSLOG_FORMAT
    value: rfc3164
```

### Option `default_rules`

Detects the log level of Home Assistant, its core containers and common add-ons, and sets it on the message. Without it, a message is `info` (stdout) or `error` (stderr).

 * `off`: no detection. This is also what you get when the option is not set.
 * `v1`: the first rule set. It is a preview: it may still change until a release note says it is final. After that it never changes.
 * `latest`: the newest rule set. A new add-on version can change the levels that you receive.

Default rules only set the level and extra fields. They never remove messages. Some outputs only use the level when it is set, so your log system can show different data after you switch this on. The Loki `level` label is not added automatically, use `?level_label=true` on the route.

### Option `exclude_containers`

Container names that are not sent to any route. Wildcards (`*`, `?`) are allowed. The container name is the Docker name, for example `homeassistant` or `addon_core_mosquitto`. Excluded containers also disappear from the HTTP `/logs` stream. Spaces around a name and empty entries are ignored. An invalid value is logged as an error and the option is ignored, so logging keeps working.

```yaml
exclude_containers:
  - homeassistant
  - addon_*_mosquitto
```

# Advanced rules

The file `/addon_configs/<slug>/logspout.yaml` on the host (`/config/logspout.yaml` inside the add-on; set the environment variable `PIPELINE_FILE` to use another path) holds advanced rules for filtering and classification. The environment variables `DEFAULT_RULES` and `EXCLUDE_CONTAINERS`, when set in the `env` option, win over the add-on options `default_rules` and `exclude_containers`.

# Custom TLS certificate

Custom certificates can be put in the Home Assistant config folder, which is mounted as `/homeassistant`.

For example, to use a custom CA certificate, create the file `<configdir>/logspout/ca.pem` using for example the Studio Code Server plugin. Then set environment variable `LOGSPOUT_TLS_CA_CERTS=/homeassistant/logspout/ca.pem`: 

```yaml
routes:
  - syslog+tls://graylog.local:6514
env:
  - name: LOGSPOUT_TLS_CA_CERTS
    value: /homeassistant/logspout/ca.pem
```      

It is also possible to specify a client key for mutual TLS client authentication. See the [Logspout documentation](https://github.com/gliderlabs/logspout/blob/master/README.md) for more information.

# More information

**Issue tracker** https://github.com/bertbaron/hassio-addons/issues

**Discussions** https://community.home-assistant.io/t/logspout-add-on-for-sending-ha-logs-to-log-management-systems/423152
