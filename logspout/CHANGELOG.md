<!-- https://developers.home-assistant.io/docs/add-ons/presentation#keeping-a-changelog -->

## 1.6.4

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
