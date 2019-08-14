#!/usr/bin/env bash

if [[ $(pwd) == */test ]]; then
    is_in_testdir="true"
else
    is_in_testdir="false"
fi

if [ "$is_in_testdir" = "true" ]; then
    ./build_docker_image.sh
else
    ./test/build_docker_image.sh
fi

docker run \
  -p 8081:80 \
  --name zulip-enabled-icinga2 \
  --hostname zulip-enabled-icinga2 \
  -e ICINGAWEB2_ADMIN_USER=icingaadmin \
  -e ICINGAWEB2_ADMIN_PASS=icinga \
  -it \
  --rm \
  -d \
  zulip-enabled-icinga2:latest

echo "zulip-enabled-icinga2 started. Go to http://localhost:8081/ and sign in with user 'icingaadmin' and password 'icinga'"
echo "Note: It may take a few moments for the first startup, check 'docker logs -f zulip-enabled-icinga2'"
echo "      You should see entries like '[2019-08-14 16:17:24 +0000] information/HttpServerConnection' ..."
echo "      or '[2019-08-14 16:24:10 +0000] information/IdoMysqlConnection: Finished reconnecting to MySQL IDO database'"
