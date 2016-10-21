#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

if [ -f /root/.profile ]; then
    rm /root/.profile
fi

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF > /etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF

cat <<EOF > /etc/hosts
127.0.0.1	localhost
192.168.50.2 master
192.168.50.11 slave1
192.168.50.12 slave2
EOF

# tune the rest
touch /home/ubuntu/.hushlogin
cp /vagrant/files/bash_profile /home/ubuntu/.bash_profile
chown ubuntu:ubuntu /home/ubuntu/.bash_profile
chown ubuntu:ubuntu /home/ubuntu/.hushlogin

# install software
apt-get -qq -y update
apt-get -qq -y install -y docker.io kubelet kubeadm kubectl kubernetes-cni jq

# fix docker
cp /vagrant/files/daemon.json /etc/docker/daemon.json
chown root:root /etc/docker/daemon.json
mkdir -p /etc/systemd/system/docker.service.d
cp /vagrant/files/docker.override.conf /etc/systemd/system/docker.service.d/docker.conf

systemctl daemon-reload
systemctl restart docker
