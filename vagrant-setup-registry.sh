#!/usr/bin/env bash

if [ ! -d /data/registry ]; then
    mkdir -p /data/registry
    chmod 777 /data/registry
fi

cp /vagrant/files/registry.service /lib/systemd/system/docker.registry.service
chown root:root /lib/systemd/system/docker.registry.service
systemctl daemon-reload
systemctl enable docker.registry
systemctl start docker.registry
