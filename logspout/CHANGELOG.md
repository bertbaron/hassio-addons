<!-- https://developers.home-assistant.io/docs/add-ons/presentation#keeping-a-changelog -->

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
