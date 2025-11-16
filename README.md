# nfrastack/container-fusiondirectory

## About

This repository will build a container for Fusion Directory](<https://www.fusiondirectory.org/>) - an LDAP frontend.

## Maintainer

- [Nfrastack](https://www.nfrastack.com)

## Table of Contents


- [About](#about)
- [Maintainer](#maintainer)
- [Table of Contents](#table-of-contents)
- [Prerequisites and Assumptions](#prerequisites-and-assumptions)
- [Installation](#installation)
  - [Prebuilt Images](#prebuilt-images)
  - [Multi-Architecture Support](#multi-architecture-support)
  - [Quick Start](#quick-start)
  - [Persistent Storage](#persistent-storage)
- [Environment Variables](#environment-variables)
  - [Base Images used](#base-images-used)
  - [Core Configuration](#core-configuration)
  - [Connection profiles](#connection-profiles)
  - [Plugins](#plugins)
    - [Argonaut | User Reminders Plugin Specific Information](#argonaut--user-reminders-plugin-specific-information)
- [Maintenance](#maintenance)
  - [Shell Access](#shell-access)
- [Support & Maintenance](#support--maintenance)
- [References](#references)
- [License](#license)

## Prerequisites and Assumptions

* Assumes you are using some sort of SSL terminating reverse proxy such as:
  - [Traefik](https://github.com/nfrastack/container-traefik)
  - [Nginx](https://github.com/jc21/nginx-proxy-manager)
  - [Caddy](https://github.com/caddyserver/caddy)

- Require - Access to an LDAP Server w/ necessary fusiondirectory schemas loaded. - See [openldap-fusiondirectory](https://github.com/nfrastack/container-openldap-fusiondirectory)
- Optional - Access to a SMTP Server

## Installation

### Prebuilt Images

Feature limited builds of the image are available on the [Github Container Registry](https://github.com/nfrastack/container-fusiondirectory/pkgs/container/container-fusiondirectory) and [Docker Hub](https://hub.docker.com/r/nfrastack/fusiondirectory).

To unlock advanced features, one must provide a code to be able to change specific environment variables from defaults. Support the development to gain access to a code.

To get access to the image use your container orchestrator to pull from the following locations:

```
ghcr.io/nfrastack/container-fusiondirectory:(image_tag)
docker.io/nfrastack/fusiondirectory:(image_tag)
```

Image tag syntax is:

`<image>:<branch>-<optional tag>-<optional_distribution>_<optional_distribution_variant>`

Example:
`ghcr.io/nfrastack/container-fusiondirectory:1.5` or optionally

`ghcr.io/nfrastack/container-fusiondirectory:1.5-1.0` or optionally

`ghcr.io/nfrastack/container-fusiondirectory:1.5-1.0-alpine` or optinally

- The `branch` will relate to the MAJOR eg `1` and MINOR `.5` release.
- An optional `tag` may exist that matches the [CHANGELOG](CHANGELOG.md) - These are the safest
- If it is built for multiple distributions there may exist a value of `alpine` or `debian`
- If there are multiple distribution variations it may include a version - see the registry for availability

Have a look at the container registries and see what tags are available.

#### Multi-Architecture Support

Images are built for `amd64` by default, with optional support for `arm64` and other architectures.

### Quick Start

- The quickest way to get started is using [docker-compose](https://docs.docker.com/compose/). See the examples folder for a working [compose.yml](examples/compose.yml) that can be modified for your use.

- Map [persistent storage](#persistent-storage) for access to configuration and data files for backup.
- Set various [environment variables](#environment-variables) to understand the capabilities of this image.

### Persistent Storage

If you would like to add custom HTML such as themes into Fusiondirectory map your folder that follows the `/www/fusiondirectory/html` structure into `/assets/fusiondirectory` and the script will overwrite upon bootup.

If you have custom plugins, map a folder to `/assets/plugins-custom/` and they will be automatically added to the container upon startup.

### Environment Variables

#### Base Images used

This image relies on a customized base image in order to work.
Be sure to view the following repositories to understand all the customizable options:

| Image                                                            | Description     |
| ---------------------------------------------------------------- | --------------- |
| [OS Base](https://github.com/nfrastack/container-base/)          | Base Image      |
| [Nginx](https://github.com/nfrastack/container-nginx/)           | Nginx webserver |
| [PHP-FPM](https://github.com/nfrastack/container-nginx-php-fpm/) | PHP Interpreter |

Below is the complete list of available options that can be used to customize your installation.

- Variables showing an 'x' under the `Advanced` column can only be set if the containers advanced functionality is enabled.

#### Core Configuration

| Parameter                  | Description         | Default                  | Advanced |
| -------------------------- | ------------------- | ------------------------ | -------- |
| `FUSIONDIRECTORY_LOG_TYPE` | `FILE` or `CONSOLE` | `FILE`                   |          |
| `FUSIONDIRECTORY_LOG_PATH` | Where to store logs | `/logs/fusiondirectory/` |          |
| `FUSIONDIRECTORY_LOG_FILE` | Logfile name        | `fusiondirectory.log`    |          |

#### Connection profiles

| Parameter           | Description                                                                          | Default                     | `_FILE` |
| ------------------- | ------------------------------------------------------------------------------------ | --------------------------- | ------- |
| `LDAP_DEFAULT`      | The Default Instance to show on Login Page e.g. `production` - Default `LDAP01_NAME` |                             |         |
| `LDAP01_NAME`       | First LDAP instance name Name e.g. `production`                                      |                             |         |
| `LDAP01_HOST`       | Firest LDAP hostnmae e.g. `openldap-fusiondirectory`                                 |                             | x       |
| `LDAP01_TLS`        | (optional) Use TLS `TRUE` or `FALSE`                                                 | `FALSE`                     |         |
| `LDAP01_SSL`        | (optional) Use SSL (LDAPS) `TRUE` or `FALSE`                                         | `FALSE`                     |         |
| `LDAP01_PORT`       | (optional) Port number                                                               | `389` unless SSL=TRUE `636` | x       |
| `LDAP01_ADMIN_PASS` | cn=admin,dc=example,dc=org Password e.g. `password`                                  |                             | x       |
| `LDAP01_ADMIN_DN`   | First rimary DN to Manage e.g. `cn=admin,dc=example,dc=org`                          |                             | x       |
| `LDAP01_BASE_DN`    | First Base DN to Manage e.g. `dc=example,dc=org`                                     |                             | x       |
| `LDAP02_NAME`       | Second instance Name (e.g. `development`)                                            |                             |         |
| `LDAP02_HOST`       | Second LDAP hostname (e.g. `openldap-fusiondirectory`)                               |                             | x       |
| `LDAP02_SSL`        | Use SSL (LDAPS) `TRUE` or `FALSE`                                                    | `false`                     |         |
| `LDAP02_TLS`        | (optional) Use TLS `TRUE` or `FALSE`                                                 | `false`                     |         |
| `LDAP02_PORT`       | (optional) Port number                                                               | `389` unless TLS=TRUE `636` |         |
| `LDAP02_ADMIN_PASS` | cn=admin,dc=example,dc=org Password e.g. `password`                                  |                             | x       |
| `LDAP02_ADMIN_DN`   | Second Admin DN e.g. `cn=admin,dc=example,dc=org`                                    |                             | x       |
| `LDAP02_BASE_DN`    | Second BASE DN e.g. `dc=example,dc=org`                                              |                             | x       |

Advanced mode allows for more than 3 profiles

#### Plugins

To install plugins for use, set the appropriate variables in this syntax:

`PLUGIN_<pluginname>=TRUE`

| Variable                             | Description                                                               | Default                            |
| ------------------------------------ | ------------------------------------------------------------------------- | ---------------------------------- |
| `FUSIONDIRECTORY_PLUGIN_CUSTOM_PATH` | Store custom plugins that are not included in the image here to be loaded | `/custom/fusiondirectory/plugins/` |

Enter inside the container and type `plugin list` for available plugins.
You must have the appropriate schemas installed in your LDAP server before using the plugin within FusionDirectory.

##### Argonaut | User Reminders Plugin Specific Information

| Parameter                        | Description                                                       | Default     |
| -------------------------------- | ----------------------------------------------------------------- | ----------- |
| `ENABLE_ARGONAUT`                | Enable Argonaut Server                                            | `FALSE`     |
| `PLUGIN_ARGONAUT`                | Argonaut                                                          | `FALSE`     |
| `PLUGIN_AUDIT`                   | Audit Trail                                                       | `FALSE`     |
| `ENABLE_AUDIT_LOG_CLEANUP`       | Enable scheduled Audit Log Cleanups                               |             |
|                                  | Default `TRUE` if `PLUGIN_AUDIT` plugin enabled                   |             |
| `AUDIT_LOG_CLEANUP_CRON_EXP`     | Cron expression for when to run Audit log cleanup                 | `0 0 * * *` |
| `PLUGIN_USER_REMINDER`           | Password Expiry                                                   | `FALSE`     |
| `ENABLE_USER_REMINDER`           | Enable scheduled User Reminder emails                             |             |
|                                  | Default `TRUE` if `PLUGIN_USER_REMINDER` plugin enabled           |             |
| `USER_REMINDER_CLEANUP_CRON_EXP` | Cron expression for when to send user reminder emails log cleanup | `0 0 * * *` |

* * *

## Maintenance

### Shell Access

For debugging and maintenance, `bash` and `sh` are available in the container.

## Support & Maintenance

- For community help, tips, and community discussions, visit the [Discussions board](/discussions).
- For personalized support or a support agreement, see [Nfrastack Support](https://nfrastack.com/).
- To report bugs, submit a [Bug Report](issues/new). Usage questions will be closed as not-a-bug.
- Feature requests are welcome, but not guaranteed. For prioritized development, consider a support agreement.
- Updates are best-effort, with priority given to active production use and support agreements.

## References

- <https://www.fusiondirectory.org/>

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
