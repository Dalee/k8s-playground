#!/usr/bin/env bash

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

apt-get -qq -y update > /dev/null 2>&1
apt-get -qq -y install -y docker.io kubelet kubeadm kubectl kubernetes-cni jq

