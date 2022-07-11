<!-- https://developers.home-assistant.io/docs/add-ons/presentation#keeping-a-changelog -->

## 1.4.0

### Config
 - Added `hostname` option
 - Default of 5m for inactivity timeout (not sure if its needed but it doesn't hurt)

### 🛠 Change in build setup
 - 🛠 Logspout is now build from a [forked repository](https://github.com/bertbaron/logspout). This simplifies the build and, more importantly, makes it easier to apply some patches specifically for this add-on

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
