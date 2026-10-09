#!/usr/bin/env bash

set -e

touch /cluster/pki/index.txt
echo 1000 > /cluster/pki/serial
echo 1000 > /cluster/pki/crlnumber
chmod 600 /cluster/pki/index.txt /cluster/pki/serial /cluster/pki/crlnumber
mkdir -p /cluster/pki/{newcerts,crl}

cat > /cluster/pki/root_ca.cnf <<'EOF'
[ ca ]
default_ca = ca_default

[ ca_default ]
dir               = /cluster/pki
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
organizationalUnitName  = supplied
commonName              = supplied
emailAddress            = optional

EOF
