FROM ubuntu:22.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends openssh-server curl \
    && mkdir -p /run/sshd \
    && echo 'root:root' | chpasswd \
    && sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && rm -rf /var/lib/apt/lists/*

CMD ["/usr/sbin/sshd", "-D", "-e"]
