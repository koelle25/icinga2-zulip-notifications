FROM jordan/icinga2:latest

RUN apt-get update && apt-get install -y --no-install-recommends \
    python \
    python-pip \
    python-setuptools \
    python-wheel \
 && rm -rf /var/lib/apt/lists/*

RUN pip install zulip

COPY ./test/50-icinga2 /opt/setup/

COPY ./src/zulip-notifications /extra-files/zulip-notifications
COPY ./test/conf.d /extra-files
