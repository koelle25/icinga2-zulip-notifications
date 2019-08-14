#!/usr/bin/env bash
set -u
set -e

VERSION='1.0.0'
DEBUG='false'

clean() {
    mkdir -p target
    rm -rf target/*
}

build_package() {
    cd target
    fpm \
        --force \
        --output-type deb \
        --input-type dir \
        --version "${VERSION}" \
        --deb-no-default-config-files \
        --deb-user 'root' \
        --deb-group 'nagios' \
        --depends 'icinga2' \
        --depends 'python' \
        --architecture 'all' \
        --name 'icinga2-zulip-notifications' \
        --description 'Icinga2 notification integration with Zulip' \
        --vendor 'https://www.kevinkoellmann.de/' \
        --maintainer 'Kevin Köllmann <mail@kevinkoellmann.de>' \
        --url 'https://github.com/koelle25/icinga2-zulip-notifications' \
        --license 'Apache License Version 2.0, January 2004' \
        --category 'universe/admin' \
        --deb-priority 'extra' \
        --deb-field 'Bugs: https://github.com/koelle25/icinga2-zulip-notifications/issues' \
        ../src/zulip-notifications=/etc/icinga2/conf.d

    if [ "${DEBUG}" = "true" ]; then
        mkdir debug
        cp "icinga2-zulip-notifications_${VERSION}_all.deb" debug/
        cd debug
        tar -xzf "icinga2-zulip-notifications_${VERSION}_all.deb"
        mkdir control
        mv control.tar.gz control/
        cd control
        tar -xzf control.tar.gz
        cd ..
        cd ..
    fi

    cd ..
}

clean
build_package

