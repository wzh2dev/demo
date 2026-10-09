#!/usr/bin/env bash

set -e

mkdir -p /cluster/pki/etcd
cat > /cluster/pki/etcd/etcd.cnf <<'EOF'
[ req ]
prompt             = no
distinguished_name = req_distinguished_name

[ req_distinguished_name ]
C  = CN
ST = Jiangsu
L  = Nanjing
O  = Wuzhenhua
OU = ETCD
CN = ETCD CA
EOF

cat > /cluster/pki/etcd/etcd.ext <<'EOF'
[ v3_ca ]
basicConstraints       = critical, CA:true, pathlen:0
keyUsage               = critical, keyCertSign, cRLSign
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid:always
EOF

openssl genrsa -aes256 -out /cluster/pki/etcd/etcd.key -passout pass:etcd 4096
openssl req -new \
  -passin pass:etcd \
  -config /cluster/pki/etcd/etcd.cnf \
  -key /cluster/pki/etcd/etcd.key \
  -out /cluster/pki/etcd/etcd.csr \
  -sha256
openssl ca \
  -config /cluster/pki/root_ca.cnf \
  -extfile /cluster/pki/etcd/etcd.ext \
  -extensions v3_ca \
  -cert /cluster/pki/root.crt \
  -keyfile /cluster/pki/root.key \
  -passin pass:root \
  -in /cluster/pki/etcd/etcd.csr \
  -out /cluster/pki/etcd/etcd.crt \
  -days 1825 \
  -md sha256 \
  -batch

openssl verify -CAfile /cluster/pki/root.crt /cluster/pki/etcd/etcd.crt
