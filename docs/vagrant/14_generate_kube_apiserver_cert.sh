#!/usr/bin/env bash

set -e

cat > /cluster/pki/k8s/apiserver-node1.cnf <<'EOF'
[ req ]
prompt             = no
distinguished_name = req_distinguished_name

[ req_distinguished_name ]
C  = CN
ST = Jiangsu
L  = Nanjing
O  = Wuzhenhua
OU = K8S
CN = kube-apiserver-node1
EOF

cat > /cluster/pki/k8s/apiserver-node1.ext <<'EOF'
[ v3_ext ]
basicConstraints       = critical, CA:false
keyUsage               = critical, digitalSignature, keyEncipherment
extendedKeyUsage       = serverAuth
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid,issuer
subjectAltName = @SubjectAlternativeName

[ SubjectAlternativeName ]
DNS.1 = localhost
DNS.2 = node1
DNS.3 = kubernetes
DNS.4 = kubernetes.default
DNS.5 = kubernetes.default.svc
DNS.6 = kubernetes.default.svc.cluster
DNS.7 = kubernetes.default.svc.cluster.local
IP.1 = 127.0.0.1
IP.2 = 10.0.0.1
IP.3 = 10.96.0.1
EOF

openssl genrsa -out /cluster/pki/k8s/apiserver-node1.key 4096
openssl req -new \
  -config /cluster/pki/k8s/apiserver-node1.cnf \
  -key /cluster/pki/k8s/apiserver-node1.key \
  -out /cluster/pki/k8s/apiserver-node1.csr \
  -sha256
openssl ca \
  -config /cluster/pki/k8s/k8s_ca.cnf \
  -extfile /cluster/pki/k8s/apiserver-node1.ext \
  -extensions v3_ext \
  -cert /cluster/pki/k8s/k8s.crt \
  -keyfile /cluster/pki/k8s/k8s.key \
  -passin pass:k8s \
  -in /cluster/pki/k8s/apiserver-node1.csr \
  -out /cluster/pki/k8s/apiserver-node1.crt \
  -days 365 \
  -md sha256 \
  -batch \
  -notext

openssl verify \
  -CAfile /cluster/pki/root.crt \
  -untrusted /cluster/pki/k8s/k8s.crt \
  /cluster/pki/k8s/apiserver-node1.crt
