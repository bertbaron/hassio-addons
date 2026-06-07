<!-- https://developers.home-assistant.io/docs/apps/presentation#keeping-a-changelog -->

## 1.12.1

### 🐛 Bug fixes
- 🐛 Fix hostname bug in Gelf and Loki adapters (regression from 1.12.0) where the hostname was left as literal `{{.Container.Config.Hostname}}` instead of the configured hostname.

## 1.12.0

### 🐛 Bug fixes
- 🐛 Fixed empty GELF messages being forwarded to Graylog, which could trigger `has empty mandatory "short_message" field` errors as reported in issue #103.

### 🔄 Internal changes
- 🔄 Replaced the old shell-based startup wrapper with a native Home Assistant launcher inside Logspout. The launcher now reads `/data/options.json` directly, validates that `/run/docker.sock` is available, and starts Logspout without the previous bash/jq wrapper layer.
- 🔄 Switched the app image to a minimal Alpine runtime that directly runs the statically linked launcher binary, eliminating the s6-overlay.

## 1.11.0

### 🔭 Roadmap: journald as log source (replacing Docker API)

First of all, thanks to all users. I'm happy to see a growing user base that I'm able to support with the limited time available.

So far I mostly created maintenance releases with some small features here and there. In the coming period you can expect some more releases however working towards a change in the log source. 

Currently, the app reads logs from the Docker API, which requires access to the Docker socket. While the app is perfectly safe to use, this prevents the app from running in protection mode and this rightly results in a rating of 1 because Home Assistant cannot guarantee safety. For a long time I have been thinking about a change by using the **systemd-journald** instead of the Docker API. This would allow the app to run in protection mode and improve the security rating. I finally decided to go for this change, and this is the first release in the process of making this change.

The transition will be gradual and non-breaking: we will start by modernizing the project setup in this release and probably one other. Then we will introduce journal support, enabling it in protected mode only. This allows users to test the new mode while the current behavior is still used when protection mode is disabled. This will already provide the biggest advantage: using the app with protection mode enabled.

Only when we are confident that the new feature can fully replace the Docker API source, we will remove the Docker API support which should increase the security rating.

💬 **Does your setup still need the Docker API? Let us know in the discussion:**  
[Roadmap: switching from Docker API to journald — will this affect you?](https://github.com/bertbaron/hassio-addons/discussions/102)

### 🔄 Internal changes
- 🔄 Switched to a single multi-arch image, published as `ghcr.io/bertbaron/logspout`.
- 🔄 Updated the repository terminology and docs from add-on to app to match Home Assistant's rebranding.

### 🛠 Change in build setup
- 🛠 Replaced the old per-arch build setup with the new Home Assistant multi-arch builder workflow.

### ⬆️ Dependency updates
- ⬆️ Update the Logspout build metadata to `hassio-8`, which is focused on dependency updates and test improvements.

## 1.10.0
### 🗑️ Removed architectures
- 🗑️ Dropped support for armhf, armv7, and i386 architectures. Home Assistant stopped building base images for these architectures ([home-assistant/docker-base#324](https://github.com/home-assistant/docker-base/pull/324)).

### ⬆️ Dependency updates
- ⬆️ Update go to golang:1.26.3
- ⬆️ Update home-assistant base image to Alpine 3.22

## 1.9.0
### ✨ New features
- ✨ Added support for stripping ANSI color codes from log messages. This can be enabled by setting `strip_ansi: true` in the configuration.

### ⬆️ Dependency updates
- ⬆️ Update github workflow dependencies (dependabot)

## 1.8.1
### ⬆️ Dependency updates
- ⬆️ Update go to golang:1.24.3 (dependabot)
- ⬆️ Update github workflow dependencies (dependabot)
- ⬆️ Update home-assistant base image to 3.21

## 1.8.0
### ✨ New features
- ✨ Gelf TCP support

### ⬆️ Dependency updates
- ⬆️ Update go to golang:1.23.5

## 1.7.0

### ✨ New features
- ✨ Added Splunk Adapter. This adapter is based on the [logspout-splunk](https://github.com/chakrabortymrinal/logspout-splunk).
  Note that this adapter is not tested by me. Any issues can be [reported on this issue](https://github.com/bertbaron/hassio-addons/issues/68) as long as it is open. 

### ⬆️ Dependency updates
- ⬆️ Update go to golang:1.23.3

## 1.6.4

### 🛠 Change in build setup
- 🛠 Build with golang cross-compilation using only the amd64 image. This results in much faster builds. Without this the builds for some architectures would fail for some reason. If this version does not run on your architecture, please let me know.

### ⬆️ Dependency updates
- ⬆️ Updates to github workflow dependencies (dependabot)
- ⬆️ Update go to golang:1.23.0

## 1.6.3

### 🛠 Bug fixes
- 🛠 Fix bug with timestamps in loki adapter

### ⬆️ Dependency updates
- ⬆️ Update go to golang:1.22.3
- ⬆️ Updates to github workflow dependencies (dependabot)
- ⬆️ Update base image to 3.20

## 1.6.2

### 🛠 Change in build setup
- 🛠 Build with golang alpine image because armhf build would otherwise fail with new go version

### ⬆️ Dependency updates
- ⬆️ Updates to github workflow dependencies (dependabot)
- ⬆️ Update go to golang:1.22.1
- ⬆️ Update base image to 3.19

## 1.6.1

### ⬆️ Dependency updates
- ⬆️ Updates to github workflow dependencies (dependabot)
- ⬆️ Update go to golang:1.21.5

## 1.6.0

### ✨ New features
- ✨ Added support for Loki with Basic Authentication and `https`, supporting Loki on grafana.com

### ⬆️ Dependency updates
- ⬆️ Updates to github workflow dependencies (dependabot)
- ⬆️ Updated workflow yaml's using the latest from home-assistant/addon-example

## 1.5.1

### ⬆️ Dependency updates
- ⬆️ Updates to github workflow dependencies (dependabot)
- ⬆️ Build with golang:1.21.0

## 1.5.0

### ✨ New features
- ✨ Added Logstash adapter (https://github.com/looplab/logspout-logstash)

## 1.4.4

### ⬆️ Dependency updates
- ⬆️ Updates to github workflow dependencies (dependabot)
- ⬆️ Build with golang:1.20.4
- ⬆️ Bump base image to 3.18

## 1.4.3

### ⬆️ Dependency updates
- ⬆️ Updates to github workflow dependencies (dependabot)
- ⬆️ Build with golang:1.20.2

## 1.4.2

### ⬆️ Dependency updates
- ⬆️ Updates to github workflow dependencies (dependabot)
- ⬆️ Build with golang:1.19.4

## 1.4.1

### ⬆️ Dependency updates
 - ⬆️ Updates to github workflow dependencies (dependabot)
 - ⬆️ Build with golang:1.19.2
 - ⬆️ Update home-assistant base image to 3.16

## 1.4.0

### 🔨 Config
 - 🔨 Added `hostname` option (defaults to `homeassistant` if not specified)
 - 🔨 Default of 5m for inactivity timeout
Env variables for these options take precedence but may be removed to simplify the configuration.

### 🛠 Change in build setup
 - 🛠 Logspout is now build from a [forked repository](https://github.com/bertbaron/logspout). This simplifies the build and makes it easier to apply some patches specifically for this add-on

### ⬆️ Dependency updates
 - ⬆️ Update github workflow dependencies

## 1.3.0

### 🚀 New features
 - 🚀 Added loki adapter

### 🔨 Small changes
 - 🔨 Set SYSLOG_HOSTNAME to `homeassistant` by default

## 1.2.1

### 📚 Documentation updates
 - 📚 Added links to issue tracker and discussions topic
 - 📚 Some small other documentation changes

### ⬆️ Dependency updates
 - ⬆️ Update to base image 3.15
 - ⬆️ Update Golang builder image to 1.18.3-alpine3.16
 - ⬆️ Update github workflow dependencies

### 🧰 Maintenance
 - 🧰 Staring with CMD instead of s6 service

## 1.2.0

- Mount config folder 
- Document usage of custom TLS certificates

## 1.1.1

- Documentation updates

## 1.1.0

Forked and updated `logspout-gelf` so that it resolves the hostname just like the `syslog` module

## 1.0.1

- Documentation

## 1.0.0

- Initial release
