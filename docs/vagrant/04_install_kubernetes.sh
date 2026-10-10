#!/usr/bin/env bash

set -e

curl -x http://192.168.1.1:7897 -fsSL -o /tmp/kubernetes-node-linux-amd64.tar.gz https://dl.k8s.io/v1.27.16/kubernetes-node-linux-amd64.tar.gz
tar -xzf /tmp/kubernetes-node-linux-amd64.tar.gz -C /cluster

curl -x http://192.168.1.1:7897 -fsSL -o /tmp/kubernetes-server-linux-amd64.tar.gz https://dl.k8s.io/v1.27.16/kubernetes-server-linux-amd64.tar.gz
tar -xzf /tmp/kubernetes-server-linux-amd64.tar.gz -C /cluster
