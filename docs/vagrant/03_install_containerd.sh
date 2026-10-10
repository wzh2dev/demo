#!/usr/bin/env bash

set -e

mkdir -p /cluster/containerd
mkdir -p /cluster/runc

curl -x http://192.168.1.1:7897 -fsSL -o /tmp/containerd.tar.gz https://github.com/containerd/containerd/releases/download/v1.7.36/containerd-1.7.36-linux-amd64.tar.gz
tar -xzf /tmp/containerd.tar.gz -C /cluster/containerd

curl -x http://192.168.1.1:7897 -fsSL -o /cluster/runc/runc https://github.com/opencontainers/runc/releases/download/v1.4.3/runc.amd64
chmod +x /cluster/runc/runc
