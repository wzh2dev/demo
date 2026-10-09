#!/usr/bin/env bash

set -e

touch /cluster/pki/k8s/index.txt
echo 1000 > /cluster/pki/k8s/serial
echo 1000 > /cluster/pki/k8s/crlnumber
chmod 600 /cluster/pki/k8s/index.txt /cluster/pki/k8s/serial /cluster/pki/k8s/crlnumber
mkdir -p /cluster/pki/k8s/{newcerts,crl}

cat > /cluster/pki/k8s/k8s_ca.cnf <<'EOF'
[ ca ]
default_ca = ca_default

[ ca_default ]
dir               = /cluster/pki/k8s
crl_dir           = $dir/crl
new_certs_dir     = $dir/newcerts
database          = $dir/index.txt
serial            = $dir/serial
crlnumber         = $dir/crlnumber

policy            = policy_strict

unique_subject    = yes
copy_extensions   = none

[ policy_strict ]
countryName             = match
stateOrProvinceName     = match
localityName            = match
organizationName        = match
organizationalUnitName  = match
commonName              = supplied
emailAddress            = optional

EOF
