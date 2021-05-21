#!/usr/bin/env bash
set -u
set -e

./build_debian_package.sh
vagrant up
vagrant ssh -c 'cd project/reprepro && reprepro includedeb general ../target/icinga2-zulip-notifications_*_all.deb'
