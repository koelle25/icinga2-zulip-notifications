<!--
  Title: Icinga Zulip Notifications
  Description: Icinga 2 notification integration with Zulip
  Author: koelle25
  -->

# icinga2-zulip-notifications
Icinga2 notification integration with Zulip

## Overview

Native, easy to use Icinga2 `NotificationCommand` to send Host and Service notifications to pre-configured Zulip stream - with only a few external dependencies: `python`, `pip`, `pip install zulip`

Also available on <a href="https://exchange.icinga.com/koelle25/icinga2-zulip-notifications" target="_blank">Icinga2 exchange portal</a>

## What will I get?
* Awesome Zulip notifications:

<p align="center">
  <img src="https://github.com/koelle25/icinga2-zulip-notifications/raw/master/docs/Notification-Examples.png" width="600">
</p>

<!--* Mobile Icinga monitoring alerts as well:

<p align="center">
  <img src="https://github.com/koelle25/icinga2-zulip-notifications/raw/master/docs/Notification-Examples-mobile.png" width="400">
</p>-->

* Notifications inside Zulip about your Host and Service state changes
* In case of failure get notified with the nicely-formatted output of the failing check
* Easy integration with Icinga2
* Debian ready-to-use package to reduce maintenance and automated installation effort
* Uses Lambdas

## Installation

### Installation using Debian package

We use [reprepro](https://mirrorer.alioth.debian.org/) to distribute our package from github.
You would need to install `apt-transport-https` that supports adding an `https` based repository to the debian repo list.

here are the steps to perform:

```
apt-get install -y apt-transport-https
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 95a6d27d7b8f41f1
add-apt-repository "deb https://raw.githubusercontent.com/koelle25/icinga2-zulip-notifications/master/reprepro general main"
apt-get update
```

You are now ready to install the plugin with

`apt-get install icinga2-zulip-notifications`

This will create the plugin files in the correct `icinga2` conf directory.

### Installation using git

1. clone the repository under your Icinga2 `/etc/icinga2/conf.d` directory

 `git clone git@github.com:koelle25/icinga2-zulip-notifications.git /etc/icinga2/conf.d/`

2. Use the `zulip-notifications-user-configuration.conf.template` file as reference to configure your Icinga2 Base URL to create your own
 `zulip-notifications-user-configuration.conf`

 `cp /etc/icinga2/conf.d/zulip-notifications/zulip-notifications-user-configuration.conf.template /etc/icinga2/conf.d/zulip-notifications/zulip-notifications-user-configuration.conf`

3. Do the same for the `zuliprc.example` file to configure your Zulip Site URL and Bot credentials

 `cp /etc/icinga2/conf.d/zulip-notifications/zuliprc.example /etc/icinga2/conf.d/zulip-notifications/zuliprc`

4. Fix permissions

 ```
    chown -R root:nagios /etc/icinga2/conf.d/zulip-notifications
    chmod 0750 /etc/icinga2/conf.d/zulip-notifications
    chmod 0640 /etc/icinga2/conf.d/zulip-notifications/*
 ```

### Configuration

#### Icinga2 features

In order for the zulip-notifications to work you need at least the following icinga2 features enabled

`checker command notification`

In order to see the list of currently enabled features execute the following command

`icinga2 feature list`

In order to enable a feature use

`icinga2 feature enable FEATURE_NAME`

#### Notification configuration

1. Configure your Icinga2 web URL in `/etc/icinga2/conf.d/zulip-notifications/zulip-notifications-user-configuration.conf`
```
template Notification "zulip-notifications-user-configuration" {
    import "zulip-notifications-default-configuration"

    vars.zulip_notifications_icinga2_base_url = "<YOUR ICINGA2 BASE URL>, e.g. http://icinga-web.yourcompany.com/icingaweb2"
}
...
```

2. Configure Zulip Site URL and Bot credentials in `/etc/icinga2/conf.d/zulip-notifications/zuliprc`
```
[api]
email=<YOUR BOT EMAIL ADDRESS>, e.g. icinga-bot@im.yourcompany.com
key=<YOUR BOT KEY>, e.g. AAAAABBBBBCCCCCDDDDDEEEEEFFFFFGG
site=<YOUR ZULIP SITE URL>, e.g. https://im.yourcompany.com
```
**Important**: The values **must not** be enclosed by quotes!

3. In order to enable the zulip-notifications **for Services** add `vars.zulip_notifications = "enabled"` to your Service template, e.g. in `/etc/icinga2/conf.d/templates.conf`

```
 template Service "generic-service" {
   max_check_attempts = 5
   check_interval = 1m
   retry_interval = 30s

   vars.zulip_notifications = "enabled"
 }
 ```

In order to enable the zulip-notifications **for Hosts** add `vars.zulip_notifications = "enabled"` to your Host template, e.g. in `/etc/icinga2/conf.d/templates.conf`

```
 template Host "generic-host" {
   max_check_attempts = 5
   check_interval = 1m
   retry_interval = 30s

   vars.zulip_notifications = "enabled"
 }
 ```

Make sure to restart icinga after the changes

`systemctl restart icinga2`

4. Further customizations [_optional_]

You can customize the following parameters of zulip-notifications :
  * zulip_notifications_stream [Default: `monitoring_alerts`]

In order to do so, place the desired parameter into `zulip-notifications-user-configuration.conf` file.

Note
> Objects as well as templates themselves can import an arbitrary number of other templates. Attributes inherited from a template can be overridden in the object if necessary.

The `zulip-notifications-user-configuration` section applies to both Host and Service, whereas the
`zulip-notifications-user-configuration-hosts` and `zulip-notifications-user-configuration-services` sections apply to Host and Service respectively


_Example channel name configuration for Service notifications_

```
template Notification "zulip-notifications-user-configuration" {
    import "zulip-notifications-default-configuration"

    vars.zulip_notifications_icinga2_base_url = "<YOUR ICINGA2 BASE URL>, e.g. http://icinga-web.yourcompany.com/icingaweb2"
}

template Notification "zulip-notifications-user-configuration-hosts" {
    import "zulip-notifications-default-configuration-hosts"

    interval = 1m
}

template Notification "zulip-notifications-user-configuration-services" {
    import "zulip-notifications-default-configuration-services"

    interval = 3m

    vars.zulip_notifications_stream = "monitoring_alerts_for_service"
}
```

If you, for some reason, want to disable the zulip-notifications from icinga2 change the following parameter inside the
corresponding Host or Service configuration object/template:

`vars.zulip_notifications == "disabled"`

Besides configuring the zulip-notifications parameters you can also configure other Icinga2 specific configuration
parameters of the Host and Service, e.g.:
* types
* user_groups
* interval
* period

## How it works
zulip-notifications uses the icinga2 native [NotificationCommand] (https://docs.icinga.com/icinga2/latest/doc/module/icinga2/chapter/object-types#objecttype-notificationcommand)
to collect the required data and send a message to configured zulip stream using [zulip](https://pypi.org/project/zulip/)

The implementation can be found in `zulip-notifications-command.conf` and it uses Lambdas!

## Testing

Since the official docker image of icinga2 seems not to be maintained, we've been using [jordan's icinga2 image](https://hub.docker.com/r/jordan/icinga2/)
to test the notifications manually.

Usual procedure for us to test the plugin is to

* configure a `test/conf.d/zulip-notifications/zuliprc` file according to documentation above
* run `test/run.sh`

```bash
 cp test/conf.d/zulip-notifications/zuliprc.example test/conf.d/zulip-notifications/zuliprc
 ./test/run.sh
```

after that navigate to `http://localhost:8081/icingaweb2` and try out some notifications.

We understand that this is far from automated testing, and we will be happy to any contributions that would improve the procedure.

## Troubleshooting
The zulip-notifications command provides detailed debug logs. In order to see them, make sure the `debuglog` feature of icinga2 is enabled.

`icinga2 feature enable debuglog`

After that you should see the logs in `/var/log/icinga2/debug.log` file. All the zulip-notifications specific logs are pre-pended with "debug/zulip-notifications"

Use the following grep for troubleshooting:

`grep "warning/PluginNotificationTask\|zulip-notifications" /var/log/icinga2/debug.log`

`tail -f /var/log/icinga2/debug.log | grep "warning/PluginNotificationTask\|zulip-notifications"`

## Credits
- [Nune Isabekyan](https://github.com/nisabek) for her work on [icinga2-slack-notifications](https://github.com/nisabek/icinga2-slack-notifications)
- [Zulip](https://zulipchat.com) for their native [Nagios integration](https://zulipchat.com/integrations/doc/nagios)

## Useful links
- [Create a Zulip Bot](https://zulipchat.com/help/add-a-bot-or-integration)
- [Enable Icinga2 Debug logging](https://icinga.com/docs/icinga2/latest/doc/15-troubleshooting/)
- [NotificationCommand of Icinga2](https://icinga.com/docs/icinga2/latest/doc/09-object-types/#notificationcommand)
- [Overriding template definitions of Icinga2](https://icinga.com/docs/icinga2/latest/doc/03-monitoring-basics/#multiple-templates)
- [Dockerized Icinga2](https://hub.docker.com/r/jordan/icinga2/)

