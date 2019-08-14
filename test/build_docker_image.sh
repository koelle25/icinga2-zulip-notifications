#!/usr/bin/env bash

if [[ $(pwd) == */test ]]; then
    docker build -t zulip-enabled-icinga2:latest -f Dockerfile ..
else
    docker build -t zulip-enabled-icinga2:latest -f test/Dockerfile .
fi
