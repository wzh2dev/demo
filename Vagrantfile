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

  config.vm.provision "shell", name: "install_containerd", inline: <<-'SH'
    set -e
    mkdir -p /cluster/containerd
    mkdir -p /cluster/runc

    curl -x http://10.0.0.1:7897 -fsSL -o /tmp/containerd.tar.gz https://github.com/containerd/containerd/releases/download/v1.7.36/containerd-1.7.36-linux-amd64.tar.gz
    tar -xzf /tmp/containerd.tar.gz -C /cluster/containerd

    curl -x http://10.0.0.1:7897 -fsSL -o /cluster/runc/runc https://github.com/opencontainers/runc/releases/download/v1.4.3/runc.amd64
    chmod +x /cluster/runc/runc
  SH

  config.vm.provision "shell", name: "install_kubernetes", inline: <<-'SH'
    set -e
    curl -x http://10.0.0.1:7897 -fsSL -o /tmp/kubernetes-node-linux-amd64.tar.gz https://dl.k8s.io/v1.27.16/kubernetes-node-linux-amd64.tar.gz
    tar -xzf /tmp/kubernetes-node-linux-amd64.tar.gz -C /cluster

    curl -x http://10.0.0.1:7897 -fsSL -o /tmp/kubernetes-server-linux-amd64.tar.gz https://dl.k8s.io/v1.27.16/kubernetes-server-linux-amd64.tar.gz
    tar -xzf /tmp/kubernetes-server-linux-amd64.tar.gz -C /cluster
  SH

  config.vm.provision "shell", name: "install_etcd", inline: <<-'SH'
    set -e
    mkdir -p /cluster/etcd
    curl -x http://10.0.0.1:7897 -fsSL -o /tmp/etcd.tar.gz https://github.com/etcd-io/etcd/releases/download/v3.5.13/etcd-v3.5.13-linux-amd64.tar.gz
    tar -xzf /tmp/etcd.tar.gz -C /cluster/etcd --strip-components=1
  SH

  config.vm.provision "shell", name: "generate_ca", inline: <<-'SH'
    set -e

    mkdir -p /cluster/pki/{certs,newcerts,private}
    touch /cluster/pki/index.txt
    echo 1000 > /cluster/pki/serial
    cat > /cluster/pki/ca.cnf <<'EOF'
[ ca ]
default_ca = CA_default

[ CA_default ]
dir               = /cluster/pki
certs             = $dir/certs
new_certs_dir     = $dir/newcerts
database          = $dir/index.txt
serial            = $dir/serial
private_key       = $dir/private/ca.key
certificate       = $dir/ca.crt
default_md        = sha256
default_days      = 3650
policy            = policy_any
x509_extensions   = v3_ca

[ policy_any ]
commonName = supplied
countryName = optional
stateOrProvinceName = optional
organizationName = optional
organizationalUnitName = optional

[ req ]
default_bits       = 4096
distinguished_name = req_distinguished_name

[ req_distinguished_name ]
C  = CN
ST = Beijing
L  = Beijing
O  = MyCluster
OU = CA
CN = mycluster-ca

[ v3_ca ]
basicConstraints = critical,CA:TRUE
keyUsage = critical,keyCertSign,cRLSign
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always
EOF

    openssl genrsa -out /cluster/pki/ca.key 4096
    openssl req -x509 -new -nodes \
      -key /cluster/pki/ca.key \
      -sha256 -days 3650 \
      -config /cluster/pki/ca.cnf \
      -extensions v3_ca \
      -out /cluster/pki/ca.crt
    openssl x509 -in /cluster/pki/ca.crt -noout -subject -issuer -dates
  SH
end
