#!/usr/bin/env bash

set -e

mkdir -p /cluster/etcd
curl -x http://10.0.0.1:7897 -fsSL -o /tmp/etcd.tar.gz https://github.com/etcd-io/etcd/releases/download/v3.5.13/etcd-v3.5.13-linux-amd64.tar.gz
tar -xzf /tmp/etcd.tar.gz -C /cluster/etcd --strip-components=1
