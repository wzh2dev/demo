#!/usr/bin/env bash

set -e

cat > /cluster/pki/etcd/peer-node1.cnf <<'EOF'
[ req ]
prompt             = no
distinguished_name = req_distinguished_name

[ req_distinguished_name ]
C  = CN
ST = Jiangsu
L  = Nanjing
O  = Wuzhenhua
OU = ETCD
CN = etcd-peer-node1

EOF

cat > /cluster/pki/etcd/peer-node1.ext <<'EOF'
[ v3_ext ]
basicConstraints       = critical, CA:false
keyUsage               = critical, digitalSignature, keyEncipherment
extendedKeyUsage       = serverAuth, clientAuth
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid,issuer
subjectAltName = @SubjectAlternativeName

[ SubjectAlternativeName ]
DNS.1 = localhost
DNS.2 = node1
IP.1 = 127.0.0.1
IP.2 = 10.0.0.1

EOF

openssl genrsa -out /cluster/pki/etcd/peer-node1.key 4096
openssl req -new \
  -config /cluster/pki/etcd/peer-node1.cnf \
  -key /cluster/pki/etcd/peer-node1.key \
  -out /cluster/pki/etcd/peer-node1.csr \
  -sha256
openssl ca \
  -config /cluster/pki/etcd/etcd_ca.cnf \
  -extfile /cluster/pki/etcd/peer-node1.ext \
  -extensions v3_ext \
  -cert /cluster/pki/etcd/etcd.crt \
  -keyfile /cluster/pki/etcd/etcd.key \
  -passin pass:etcd \
  -in /cluster/pki/etcd/peer-node1.csr \
  -out /cluster/pki/etcd/peer-node1.crt \
  -days 365 \
  -md sha256 \
  -batch \
  -notext

openssl verify \
  -CAfile /cluster/pki/root.crt \
  -untrusted /cluster/pki/etcd/etcd.crt \
  /cluster/pki/etcd/peer-node1.crt
