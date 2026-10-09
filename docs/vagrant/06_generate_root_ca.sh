#!/usr/bin/env bash

set -e

mkdir -p /cluster/pki
cat > /cluster/pki/root.cnf <<'EOF'
[ req ]
prompt             = no
distinguished_name = req_distinguished_name
x509_extensions     = v3_ca

[ req_distinguished_name ]
C  = CN
ST = Jiangsu
L  = Nanjing
O  = Wuzhenhua
OU = IT
CN = Root CA

[ v3_ca ]
basicConstraints       = critical, CA:true, pathlen:1
keyUsage               = critical, keyCertSign, cRLSign
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid:always

EOF

openssl genrsa -aes256 -out /cluster/pki/root.key -passout pass:root 4096
openssl req -x509 -new -sha256 \
  -config /cluster/pki/root.cnf \
  -extensions v3_ca \
  -key /cluster/pki/root.key \
  -passin pass:root \
  -out /cluster/pki/root.crt \
  -days 3650

openssl verify -CAfile /cluster/pki/root.crt /cluster/pki/root.crt
