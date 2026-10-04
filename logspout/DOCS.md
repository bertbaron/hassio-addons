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

A route can get a name with `#name`, for example `gelf://graylog.home:12201#graylog`. Rules can then apply to that route only (see [Route names](#route-names)).

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

Detects the log level of Home Assistant, its core containers and common apps, and sets it on the message. Without it, a message is `info` (stdout) or `error` (stderr).

 * `off`: no detection. This is also what you get when the option is not set.
 * `v1`: the first rule set. It is a preview: it may still change until a release note says it is final. After that it never changes.
 * `latest`: the newest rule set. A new app version can change the levels that you receive.

Default rules only set the level and extra fields. They never remove messages. The GELF and syslog outputs always send a level (the default one when none is set). Splunk sends a level only when one is set. Loki sends none unless you use `level_label`. So your log system can show different data after you switch this on. Loki only gets a `level` label when you add `?level_label=true` to the route.

### Option `exclude_containers`

Container names that are not sent to any route. Wildcards (`*`, `?`) are allowed. The container name is the Docker name, for example `homeassistant` or `addon_core_mosquitto`. Excluded containers also disappear from the HTTP `/logs` stream. Spaces around a name and empty entries are ignored. An invalid value is logged as an error and the option is ignored, so logging keeps working.

```yaml
exclude_containers:
  - homeassistant
  - addon_*_mosquitto
```

# Filtering and log levels

By default every message is `info` (stdout) or `error` (stderr), and everything is sent to every route. You can change this in three ways. Use any of them or none; without them nothing changes:

1. App options `default_rules` and `exclude_containers` (see above). No file needed.
2. The rule file `logspout.yaml` for your own rules, also per route.
3. The web interface "Logspout" in the sidebar to edit, test and watch the rules.

## Quick examples

### Log levels (issue #75)

Home Assistant Core, the Supervisor and common apps are recognized by the default rules. Set the app option:

```yaml
default_rules: v1
```

An app that is not covered logs lines like `[ERROR] disk full`. Put a rule in the rule file so these arrive with the right level:

```yaml
rules:
  - name: myaddon levels
    when:
      container: addon_*_myaddon
      match: '^\[(?P<lvl>DEBUG|INFO|WARN|ERROR)\] (?P<text>.*)$'
    set:
      level: ${lvl}
      message: ${text}
```

`message: ${text}` also removes the `[ERROR] ` prefix. Leave that line out to keep the original text.

### Exclude Home Assistant Core from one route (discussion #102)

You already ship the Core log with the `remote_logger` integration, so the route `backup` should not get the `homeassistant` container. Give the routes a name in the app options:

```yaml
routes:
  - gelf://graylog.home:12201#graylog
  - syslog+tcp://10.0.0.5:514#backup
```

Then add a rule for that route only in `logspout.yaml`:

```yaml
targets:
  backup:
    rules:
      - name: core is already shipped by remote_logger
        when: { container: homeassistant }
        drop: true
```

To leave the container out of all routes, use the option `exclude_containers` instead.

## The rule file

The file is `/config/logspout.yaml` inside the app. Without it there are no rules of your own. You find it on the host as `addon_configs/<slug>/logspout.yaml` (the slug of this app ends with `logspout`; the exact folder name is shown in the File editor, Samba or Studio Code Server). You can also edit it in the web interface. Set the environment variable `PIPELINE_FILE` (option `env`) to use another path.

Full format, all keys are optional:

```yaml
defaults: v1                 # off, latest or a version; wins over the app option
disable_defaults:            # switch off single rules of the default set
  - addon-bashio

rules:                       # global rules: run once per message, for all routes
  - name: my rule            # a name is optional but helps in traces and errors
    when: { container: addon_*_myaddon }
    unless: { source: stderr }
    parse: bashio
    set: { level: warning }
    drop: false
    stop: false

targets:                     # rules for one route only
  graylog:                   # the name of the route, see "Route names"
    rules:
      - name: no debug here
        when: { level: '<info' }
        drop: true
```

The file must be one YAML document. Unknown keys are errors, so a typo cannot silently change what a rule does. Use single-quoted strings for regular expressions: no backslash escaping is needed.

### Order

1. Option `exclude_containers`.
2. The default rules (`default_rules` or `defaults`).
3. Your global `rules`, in the order of the file.
4. For each route its own `targets.<name>.rules`. A change made here only affects that route.

A message is first changed by earlier steps, so your rules see the level that the default rules set.

### Conditions

`when` and `unless` hold conditions. All keys that you give must match. `unless` is the negation: the rule is skipped when it matches. A rule without `when` applies to every message. An empty `when: {}` or an empty value is an error.

| Key | Meaning |
|-----|---------|
| `container` | Container name with wildcards (`*` and `?`, also called a glob), or a list of such names. For example `homeassistant`, `addon_*_zigbee2mqtt`. |
| `image` | Image name with wildcards (`*` also matches `/`). |
| `source` | `stdout` or `stderr`. |
| `level` | A level (`warning`) or a comparison (`<info`, `>=warning`, also `<=`, `>`). |
| `match` | Regular expression (see the [syntax](https://github.com/google/re2/wiki/Syntax)) on the message text, without ANSI color codes. Named groups, like `(?P<lvl>\w+)`, become variables. |
| `expr` | An [expr-lang](https://expr-lang.org/docs/language-definition) expression that gives true or false, for cases the other keys cannot express. Variables: `container`, `image`, `source`, `level`, `message` and `fields` (a map). |

Example with `expr`: a message on stderr that says `info` is a warning:

```yaml
rules:
  - name: stderr info is a warning
    when: { expr: 'source == "stderr" && message contains "info"' }
    set: { level: warning }
```

Allow list: drop everything that is not from these containers:

```yaml
rules:
  - name: only keep these containers
    unless: { container: [homeassistant, addon_core_mosquitto] }
    drop: true
```

If an `expr` fails while it runs, the rule does not apply (also in `unless`) and the error shows in the trace.

### Levels

The levels are `debug`, `info`, `notice`, `warning`, `error` and `critical`. Other names are converted: `warn` to `warning`, `err` and `eror` to `error`, `fatal`, `crit`, `emerg`, `emergency` and `alert` to `critical`, `information` to `info`, `trace` and `verbose` to `debug`. Case does not matter. A fixed level in `set` that is unknown (`set: { level: loud }`) is an error in the file. A level that comes from a variable or a parser and is unknown is ignored, and the level stays as it was.

The effective level is what `level` conditions and `expr` see. When no level is set, it is `error` for stderr and `info` for stdout, which is what the outputs use too.

### Actions

Actions of one rule run in this order: `parse`, `set`, `drop`, `stop`.

 * `parse: <parser>`: read the level (and more) from the line. Only the level and fields are set, never the text. If the line does not have the format of the parser, nothing is changed.
 * `set`: `level`, `message` and `fields.<name>`, for example `set: { level: warning, fields.room: kitchen }`. Write the field as one key `fields.room`; a nested `fields: { room: kitchen }` is not supported. A field name may contain `A-Z a-z 0-9 _ . -` and cannot be `id`. Values may use variables. All values of one rule are calculated before any is set.
 * `drop: true`: the message is not sent. The rest of the list is skipped.
 * `stop: true`: skip the remaining rules of this list. Rules of the next step still run. Note that `stop` also works when a `parse` did not match, so combine it with a `match` condition.

Parsers (each looks at the start of the line):

| Parser | Example line |
|--------|--------------|
| `homeassistant` | `2026-10-04 12:00:00.123 INFO (MainThread) [homeassistant.core] started` (sets fields `thread` and `logger`) |
| `bashio` | `[12:00:00] INFO: Starting service` |
| `logfmt` | `time=... level=warn msg="..."` (`level` or `lvl`) |
| `json` | `{"level":"warn","msg":"..."}` (`level` or `severity`, field `logger`) |
| `bracket` | `[warn] something happened` |
| `generic` | a level word (`error`, `warn`, ...) in the first 40 characters |

### Variables

Values in `set` can use `${name}`:

 * a named group of the `match` in the `when` of the same rule (not in `unless`). It wins over a built-in variable of the same name, and is empty when an optional group did not take part.
 * `container`, `image`, `source`, `level` and `message` (`message` and groups have no ANSI codes).

Use `$$` for a literal `$`. An unknown variable is an error.

## Route names

A route can get a name with a URI fragment: `syslog+tcp://10.0.0.5:514#backup`. Allowed characters are `A-Z a-z 0-9 _ . -`. Without a fragment the name is the adapter type (`gelf`, `syslog`, `loki`). The name is only used to give a route its own rules in `targets:`.

 * The app always starts, whatever the names are. A problem with a name is a warning in the app log, and only that name cannot be used as a target.
 * A fragment with characters that are not allowed is ignored, as before this feature existed; you now get a warning in the log. The route works and has its default name, so `targets:` can use the adapter type.
 * Two routes with the same name (two routes of the same type without `#name`, a duplicate `#name`, or a `#name` equal to the default name of another route) both keep working. The name is ambiguous, so a `targets:` entry for it is an error. Give the routes unique names. The app logs a warning at start only when a `#name` is part of the clash; two routes of the same type without `#name` stay silent.
 * Routes that you create with the routes API or load from `ROUTESPATH` are not known when the file is checked, so a `targets:` entry for such a route is an unknown target. If such a route has the same name as another route, the name is ambiguous while the app runs: the target rules of that name are not applied to any of the routes with that name, including the configured one, and a warning is logged once. The messages are sent as if there were no target rules for that name. The Playground and Live view do not show this case; the status shows the name as ambiguous. A route added through the routes API with an invalid `name` ignores the name with a warning and uses the default name.
 * A `targets:` entry for an unknown or ambiguous name is an error in the file. The file is then not loaded and the previous rules stay active.

## Default rule sets

`default_rules` (or `defaults:` in the rule file, which wins) selects a set of rules that only classify messages: they set level and fields, and never drop or rewrite messages. User rules run after them, so your `set` wins. Use `disable_defaults` to switch off a single rule by name. You find the names of the default rules in the trace of the Playground or Live view (shown as `defaults/v1: <name>`), and in the lines of `DEBUG_PIPELINE` (shown as `defaults/v1:"<name>"`).

`v1` contains rules for:

 * Home Assistant Core and the Supervisor (`homeassistant`, `hassio_supervisor`)
 * the other core containers (`hassio_dns`, `hassio_audio`, `hassio_multicast`, `hassio_observer`, `hassio_cli`)
 * s6-overlay messages
 * Zigbee2MQTT, Node-RED, Z-Wave JS UI, Matter Server, ESPHome, Whisper, Piper, openWakeWord, Grafana and InfluxDB
 * every other app that logs in the bashio format (`[12:00:00] INFO: text`)

Apps from community repositories have a hash in the container name (`addon_45df7312_zigbee2mqtt`), so the rules match with a wildcard name like `addon_*_zigbee2mqtt`.

Versions:

 * `v1`, `v2`, ...: a released version never changes, so you will not see different levels after an update. `v1` is still a preview (see `default_rules` above) until it is checked against more real logs.
 * `latest`: always the newest set. A new app version can change the levels you receive.
 * `off`: no default rules. This is also what you get without the option.

The option is not set to `latest` for you, because that would change the output of existing installs. The web interface shows a banner only when you use a pinned version (like `v1`) that is not the newest. With `latest` or `off` there is no banner. Its button puts `defaults: <newer version>` in the draft in the Config view; you still validate and save it yourself.

## Reload and errors

Changes of the file are picked up within a few seconds, without restart. The app checks the file every 2 seconds and loads it when it was the same on two checks in a row, so a half-written file is not loaded. Saving from the web interface loads at once. The file can be at most 1 MiB.

 * An invalid file is ignored as a whole. The rules that were active stay active. At start-up an invalid file means start without the file rules: logging never stops because of a typo.
 * Errors, with line and column, are written to the app log and shown in the web interface. After each load with rules, one summary line is logged.
 * `disable_defaults` with an unknown rule name only gives a warning.

## Web interface

Open "Logspout" in the sidebar of Home Assistant. It is only visible for administrators. Access is only possible through the Home Assistant ingress.

 * **Config**: edit the rule file, Validate, Save (written safely, never half, and loaded at once) or reload it from disk. Shows the status: active default set, routes and their names, and the banner for a newer default set. Save overwrites the file without checking if someone else changed it in the meantime.
 * **Playground**: run the draft from the Config view on test messages: recent messages, or lines that you paste (with a container name). For every message you see which rules matched, the captured groups, the final level and text, and per route whether it is sent or dropped. Nothing is saved or applied. It also has a regex tester that shows the named groups.
 * **Live**: a stream of messages after the rules, with the same trace. Filter on a container name with wildcards and show dropped messages if you want. At most 8 viewers at the same time.

While the app runs, the web interface keeps the last 500 raw messages (each cut at 16 KiB), so it uses up to about 8 MiB of memory, even when nobody looks at it. The Playground uses at most 1000 messages and 4 MiB per run.

## Debugging

Add `DEBUG_PIPELINE=true` in the `env` option to log a trace line for every message: which rules matched and what changed. This is noisy and limited to 50 lines per second (a line tells how many were skipped). Trace lines are never traced themselves. Without rules the app only says that there is nothing to trace. The web interface Live view is usually easier.

The `env` option accepts these variables: `PIPELINE_FILE` (path of another rule file) and `DEBUG_PIPELINE` (`true` or `false`). `DEFAULT_RULES` and `EXCLUDE_CONTAINERS` can also be set there, and then win over the app options `default_rules` and `exclude_containers`. The app resets these four variables at start, so a value that is set in any other way (for example in the container environment) is ignored.

## Things to know

 * Rules are written by the administrator and trusted. A regular expression cannot get slow, but an `expr` can still loop for a long time or use much memory and slow down shipping. The expr function `repeat` is switched off because it can use a lot of memory.
 * Excluded containers also disappear from the `/logs` stream on port 80.
 * The Loki `level` label is not added automatically, because it changes the streams in Loki. Use `?level_label=true` on the route.
 * Messages that have no level (no rules, or no rule matched) are sent exactly as before, also the raw `toJSON` output.
 * The rules run before multiline joining, so continuation lines of a multiline message are classified or dropped on their own.
 * With a changed level, the syslog severity follows the level. The facility still follows stdout/stderr.
 * Messages with fields get extra GELF fields (`_<name>`) and Splunk `fields`. Built-in GELF fields such as `_container_name` are never overwritten by a rule field with the same name.
 * With a level or fields set, the raw output `toJSON` also has the keys `Level` and `Fields`, and a `RAW_FORMAT` template can use `{{.Level}}` and `{{.Fields}}` (for example `{{.Fields.logger}}`).
 * Web interface: save before you leave the panel. Switching to another page in the sidebar does not warn about unsaved changes.
 * The Playground and Live view show traces for the first 16 KiB of a very long line.
 * A replace of the rule file with exactly the same size and modification time is not noticed until the next real change.
 * A stored route (routes API or `ROUTESPATH`) with a name that another route has is loaded anyway. The name is ambiguous, see [Route names](#route-names).
 * YAML anchors and aliases work for a whole rule (`&a {...}` and `*a`). The merge key `<<` is rejected as an unknown key, and so is a top-level helper key that only holds an anchor, because unknown keys are errors.

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
