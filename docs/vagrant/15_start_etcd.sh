#!/usr/bin/env bash

set -e

# CA bundle: root CA + etcd intermediate CA, used for client/peer TLS verification
cat /cluster/pki/root.crt /cluster/pki/etcd/etcd.crt > /cluster/pki/etcd/ca-bundle.crt

mkdir -p /var/lib/etcd

# clean up leftovers from a previous systemd-based provision, and stop any running etcd
systemctl stop etcd 2>/dev/null || true
systemctl disable etcd 2>/dev/null || true
rm -f /etc/systemd/system/etcd.service
pkill -x etcd 2>/dev/null || true

# Note: client-cert-auth (client certificate verification) is not enabled, because the etcd client certificate (apiserver-etcd-client) has not been generated yet;
# once the client certificate exists, add "client-cert-auth: true" to the config file below.
cat > /cluster/etcd/etcd.conf.yml <<'EOF'
name: node1
data-dir: /var/lib/etcd

# client TLS
cert-file: /cluster/pki/etcd/server-node1.crt
key-file: /cluster/pki/etcd/server-node1.key
trusted-ca-file: /cluster/pki/etcd/ca-bundle.crt

# peer TLS
peer-cert-file: /cluster/pki/etcd/peer-node1.crt
peer-key-file: /cluster/pki/etcd/peer-node1.key
peer-trusted-ca-file: /cluster/pki/etcd/ca-bundle.crt
peer-client-cert-auth: true

listen-client-urls:
  - https://10.0.0.1:2379
  - https://127.0.0.1:2379
advertise-client-urls:
  - https://10.0.0.1:2379

listen-peer-urls:
  - https://10.0.0.1:2380
initial-advertise-peer-urls:
  - https://10.0.0.1:2380
initial-cluster: node1=https://10.0.0.1:2380
initial-cluster-state: new
EOF

# Foreground process, no systemd: nohup keeps it alive after the provisioning SSH session closes,
# output goes to /var/log/etcd.log (a blocking foreground start would hang `vagrant provision`).
# Note: --config-file cannot be combined with other command-line flags.
nohup /cluster/etcd/etcd \
  --config-file /cluster/etcd/etcd.conf.yml \
  > /var/log/etcd.log 2>&1 &

# wait until the endpoint reports healthy
for i in {1..15}; do
  if /cluster/etcd/etcdctl \
    --endpoints=https://10.0.0.1:2379,https://127.0.0.1:2379 \
    --cacert=/cluster/pki/etcd/ca-bundle.crt \
    endpoint health; then
    echo "etcd is up"
    exit 0
  fi
  sleep 1
done

echo "etcd failed to become healthy, last log lines:"
tail -n 20 /var/log/etcd.log
exit 1
