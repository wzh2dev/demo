#!/usr/bin/env bash

set -e

mkdir -p /cluster/pki/k8s
cat > /cluster/pki/k8s/k8s.cnf <<'EOF'
[ req ]
prompt             = no
distinguished_name = req_distinguished_name

[ req_distinguished_name ]
C  = CN
ST = Jiangsu
L  = Nanjing
O  = Wuzhenhua
OU = K8S
CN = K8S CA

EOF

cat > /cluster/pki/k8s/k8s.ext <<'EOF'
[ v3_ca ]
basicConstraints       = critical, CA:true, pathlen:0
keyUsage               = critical, keyCertSign, cRLSign
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid:always

EOF

openssl genrsa -aes256 -out /cluster/pki/k8s/k8s.key -passout pass:k8s 4096
openssl req -new \
  -config /cluster/pki/k8s/k8s.cnf \
  -key /cluster/pki/k8s/k8s.key \
  -passin pass:k8s \
  -out /cluster/pki/k8s/k8s.csr \
  -sha256
openssl ca \
  -config /cluster/pki/root_ca.cnf \
  -extfile /cluster/pki/k8s/k8s.ext \
  -extensions v3_ca \
  -cert /cluster/pki/root.crt \
  -keyfile /cluster/pki/root.key \
  -passin pass:root \
  -in /cluster/pki/k8s/k8s.csr \
  -out /cluster/pki/k8s/k8s.crt \
  -days 1825 \
  -md sha256 \
  -batch \
  -notext

openssl verify -CAfile /cluster/pki/root.crt /cluster/pki/k8s/k8s.crt
