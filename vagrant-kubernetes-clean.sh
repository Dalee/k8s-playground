#!/bin/bash

systemctl stop kubelet;
docker rm -f $(docker ps -q); mount | grep "/var/lib/kubelet/*" | awk '{print $3}' | xargs umount 1>/dev/null 2>/dev/null;
rm -rf /var/lib/kubelet /etc/kubernetes /var/lib/etcd /etc/cni /etc/kubernetes;
mkdir -p /etc/kubernetes
systemctl start kubelet
