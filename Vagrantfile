# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "centos/7"
  config.vm.box_version = "2004.01"
  config.vm.provider "vmware_desktop" do |v|
    v.vmx["memsize"] = "4096"
    v.vmx["numvcpus"] = "2"
  end
  config.ssh.insert_key = false

  config.vm.provision "shell", name: "disable_swap", inline: <<-'SH'
    set -e
    swapoff -a
    sed -i '/^[^#].*swap/s/^/#/' /etc/fstab
    swapon --show
  SH

  config.vm.provision "shell", name: "disable_selinux", reboot: true, inline: <<-'SH'
    set -e
    setenforce 0 2>/dev/null || true
    sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config
  SH

  config.vm.provision "shell", name: "setup_root_ssh", inline: <<-'SH'
    set -e
    echo 'root:root' | chpasswd
    sed -ri 's/^[[:blank:]#]*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
    sed -ri 's/^[[:blank:]#]*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
    sshd -t && systemctl reload sshd
  SH

  # config.vm.provision "shell", name: "install_containerd", inline: <<-'SH'
  #   set -e
  #   mkdir -p /cluster/containerd
  #   mkdir -p /cluster/runc
  #
  #   curl -x http://10.0.0.1:7897 -fsSL -o /tmp/containerd.tar.gz https://github.com/containerd/containerd/releases/download/v1.7.36/containerd-1.7.36-linux-amd64.tar.gz
  #   tar -xzf /tmp/containerd.tar.gz -C /cluster/containerd
  #
  #   curl -x http://10.0.0.1:7897 -fsSL -o /cluster/runc/runc https://github.com/opencontainers/runc/releases/download/v1.4.3/runc.amd64
  #   chmod +x /cluster/runc/runc
  # SH
  #
  # config.vm.provision "shell", name: "install_kubernetes", inline: <<-'SH'
  #   set -e
  #   curl -x http://10.0.0.1:7897 -fsSL -o /tmp/kubernetes-node-linux-amd64.tar.gz https://dl.k8s.io/v1.27.16/kubernetes-node-linux-amd64.tar.gz
  #   tar -xzf /tmp/kubernetes-node-linux-amd64.tar.gz -C /cluster
  #
  #   curl -x http://10.0.0.1:7897 -fsSL -o /tmp/kubernetes-server-linux-amd64.tar.gz https://dl.k8s.io/v1.27.16/kubernetes-server-linux-amd64.tar.gz
  #   tar -xzf /tmp/kubernetes-server-linux-amd64.tar.gz -C /cluster
  # SH
  #
  # config.vm.provision "shell", name: "install_etcd", inline: <<-'SH'
  #   set -e
  #   mkdir -p /cluster/etcd
  #   curl -x http://10.0.0.1:7897 -fsSL -o /tmp/etcd.tar.gz https://github.com/etcd-io/etcd/releases/download/v3.5.13/etcd-v3.5.13-linux-amd64.tar.gz
  #   tar -xzf /tmp/etcd.tar.gz -C /cluster/etcd --strip-components=1
  # SH

  config.vm.provision "shell", name: "generate_ca_root", inline: <<-'SH'
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
      -passin pass:root \
      -config /cluster/pki/root.cnf \
      -extensions v3_ca \
      -key /cluster/pki/root.key \
      -out /cluster/pki/root.crt \
      -days 3650

    openssl verify -CAfile /cluster/pki/root.crt /cluster/pki/root.crt
  SH

  config.vm.provision "shell", name: "generate_ca_root_config", inline: <<-'SH'
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
  SH

  config.vm.provision "shell", name: "generate_ca_etcd", inline: <<-'SH'
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
  SH

  config.vm.provision "shell", name: "generate_ca_etcd_config", inline: <<-'SH'
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
  SH

  config.vm.provision "shell", name: "generate_ca_etcd_server", inline: <<-'SH'
    set -e

    cat > /cluster/pki/etcd/server.cnf <<'EOF'
[ req ]
prompt             = no
distinguished_name = req_distinguished_name

[ req_distinguished_name ]
C  = CN
ST = Jiangsu
L  = Nanjing
O  = Wuzhenhua
OU = ETCD
CN = ETCD Server
EOF

    cat > /cluster/pki/etcd/server.ext <<'EOF'
[ v3_ca ]
basicConstraints       = critical, CA:false
keyUsage               = critical, digitalSignature, keyEncipherment
extendedKeyUsage       = serverAuth, clientAuth
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid:issuer
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = localhost
IP.1 = 127.0.0.1
EOF

    openssl genrsa -aes256 -out /cluster/pki/etcd/server.key -passout pass:etcd 4096
    openssl req -new \
      -passin pass:etcd \
      -config /cluster/pki/etcd/server.cnf \
      -key /cluster/pki/etcd/server.key \
      -out /cluster/pki/etcd/server.csr \
      -sha256

  SH
end
