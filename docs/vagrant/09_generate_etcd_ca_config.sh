#!/usr/bin/env bash

set -e

touch /cluster/pki/etcd/index.txt
echo 1000 > /cluster/pki/etcd/serial
echo 1000 > /cluster/pki/etcd/crlnumber
chmod 600 /cluster/pki/etcd/index.txt /cluster/pki/etcd/serial /cluster/pki/etcd/crlnumber
mkdir -p /cluster/pki/etcd/{newcerts,crl}

cat > /cluster/pki/etcd/etcd_ca.cnf <<'EOF'
[ ca ]
default_ca = ca_default

[ ca_default ]
dir               = /cluster/pki/etcd
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
