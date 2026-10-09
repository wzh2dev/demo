#!/usr/bin/env bash

set -e
swapoff -a
sed -i '/^[^#].*swap/s/^/#/' /etc/fstab
swapon --show
