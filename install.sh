#! /bin/sh

set -eux
set -o pipefail

apk update
apk add --no-cache postgresql-client gnupg curl python3 py3-pip

pip3 install --no-cache-dir awscli

# install go-cron
curl -L https://github.com/ivoronin/go-cron/releases/download/v0.0.5/go-cron_0.0.5_linux_arm64.tar.gz -O
tar xvf go-cron_0.0.5_linux_arm64.tar.gz
rm go-cron_0.0.5_linux_arm64.tar.gz
mv go-cron /usr/local/bin/go-cron
chmod u+x /usr/local/bin/go-cron
