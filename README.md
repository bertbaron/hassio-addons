# My Home Assistant app repository

![update-badge](https://img.shields.io/github/last-commit/bertbaron/hassio-addons?label=last%20update)
[![Codacy Badge](https://app.codacy.com/project/badge/Grade/9c6cf10bdbba45ecb202d7f579b5be0e)](https://www.codacy.com/gh/bertbaron/hassio-addons/dashboard?utm_source=github.com&utm_medium=referral&utm_content=bertbaron/hassio-addons&utm_campaign=Badge_Grade)
[![GitHub Super-Linter](https://github.com/bertbaron/hassio-addons/workflows/Lint/badge.svg)](https://github.com/marketplace/actions/super-linter)
[![Builder](https://github.com/bertbaron/hassio-addons/workflows/Builder/badge.svg)](https://github.com/bertbaron/hassio-addons/actions/workflows/builder.yaml)

## Installation

Follow [the official instructions](https://www.home-assistant.io/common-tasks/os#installing-third-party-add-ons) on the website of Home Assistant, and use the following URL:

```
https://github.com/bertbaron/hassio-addons
```

or use the badge below.

[![Open your Home Assistant instance and show the add add-on repository dialog with a specific repository URL pre-filled.](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Fbertbaron%2Fhassio-addons)

## Development / Testing

If you want to test changes before they are released, you can use the edge build from
the `develop` branch. Add the following URL as a custom repository in Home Assistant:

```
https://github.com/bertbaron/hassio-addons#develop
```

[![Open your Home Assistant instance and show the add add-on repository dialog with a specific repository URL pre-filled.](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Fbertbaron%2Fhassio-addons%23develop)

The `develop` branch publishes a pre-built `edge` Docker image on every push.
Since the version is always `edge`, Home Assistant will not automatically detect
updates — reinstall the app after a new push to pick up the latest changes.

## Releasing

To publish a new release:

1. Add a `## X.Y.Z` section at the top of `logspout/CHANGELOG.md` on the `develop` branch.
2. Run the release script from the repo root:
   ```bash
   ./release.sh X.Y.Z
   ```

The script validates the changelog, sets the version, merges `develop` → `main`, pushes
main (triggering the CI release build), then automatically restores `develop` to the
`edge` state.

## Apps

This repository contains the following apps

### [Logspout app](./logspout)

![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]
![privileged][privileged-shield]

_Logspout app for sending Home Assistant logs to remote log management systems._

<!--

Notes to developers after forking or using the github template feature:
- While developing comment out the 'image' key from 'example/config.yaml' to make the supervisor build the addon
  - Remember to put this back when pushing up your changes.
- When you merge to the 'main' branch of your repository a new build will be triggered.
  - Make sure you adjust the 'version' key in 'example/config.yaml' when you do that.
  - Make sure you update 'example/CHANGELOG.md' when you do that.
  - The first time this runs you might need to adjust the image configuration on github container registry to make it public
- Adjust the 'image' key in 'example/config.yaml' so it points to your username instead of 'home-assistant'.
  - This is where the build images will be published to.
- Rename the example directory.
  - The 'slug' key in 'example/config.yaml' should match the directory name.
- Adjust all keys/url's that points to 'home-assistant' to now point to your user/fork.
- Share your repository on the forums https://community.home-assistant.io/c/projects/9
- Do awesome stuff!
 -->

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[privileged-shield]: https://img.shields.io/badge/privileged-required-orange.svg
