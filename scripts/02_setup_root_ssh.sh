#!/usr/bin/env bash

set -e

echo 'root:root' | chpasswd
sed -ri 's/^[[:blank:]#]*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -ri 's/^[[:blank:]#]*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sshd -t && systemctl reload sshd
