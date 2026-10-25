# README.md

## 快捷命令

### 查询节点镜像

```bash
ansible nodes -b -m shell -a '/cluster/crictl/crictl images'
```

### 拉取镜像

```bash
ansible nodes -b -m shell -a 'env HTTPS_PROXY=http://10.0.0.1:7897 /cluster/containerd/bin/ctr --namespace k8s.io images pull registry.k8s.io/pause:3.8'
```

```bash
ansible nodes -b -m shell -a 'env HTTPS_PROXY=http://10.0.0.1:7897 /cluster/containerd/bin/ctr --namespace k8s.io images pull docker.io/calico/pod2daemon-flexvol:v3.27.5'
```

```bash
ansible nodes -b -m shell -a 'env HTTPS_PROXY=http://10.0.0.1:7897 /cluster/containerd/bin/ctr --namespace k8s.io images pull docker.io/calico/cni:v3.27.5'
```

```bash
ansible nodes -b -m shell -a 'env HTTPS_PROXY=http://10.0.0.1:7897 /cluster/containerd/bin/ctr --namespace k8s.io images pull docker.io/calico/node:v3.27.5'
```

```bash
ansible nodes -b -m shell -a 'env HTTPS_PROXY=http://10.0.0.1:7897 /cluster/containerd/bin/ctr --namespace k8s.io images pull docker.io/calico/typha:v3.27.5'
```

```bash
ansible nodes -b -m shell -a 'env HTTPS_PROXY=http://10.0.0.1:7897 /cluster/containerd/bin/ctr --namespace k8s.io images pull docker.io/calico/csi:v3.27.5'
```

```bash
ansible nodes -b -m shell -a 'env HTTPS_PROXY=http://10.0.0.1:7897 /cluster/containerd/bin/ctr --namespace k8s.io images pull docker.io/calico/node-driver-registrar:v3.27.5'
```

```bash
ansible nodes -b -m shell -a 'env HTTPS_PROXY=http://10.0.0.1:7897 /cluster/containerd/bin/ctr --namespace k8s.io images pull docker.io/calico/kube-controllers:v3.27.5'
```

```bash
ansible nodes -b -m shell -a 'env HTTPS_PROXY=http://10.0.0.1:7897 /cluster/containerd/bin/ctr --namespace k8s.io images pull registry.k8s.io/coredns/coredns:v1.10.1'
```

## 手动签发 kubelet serving 证书

### 1. 查看待审批的 serving CSR

```bash
/cluster/k8s/client/bin/kubectl --kubeconfig=/cluster/k8s/admin.kubeconfig get csr --field-selector=spec.signerName=kubernetes.io/kubelet-serving
```

### 2. 批量批准（CONDITION 从 Pending 变为 Approved,Issued 即完成）

```bash
/cluster/k8s/client/bin/kubectl --kubeconfig=/cluster/k8s/admin.kubeconfig certificate approve $(/cluster/k8s/client/bin/kubectl --kubeconfig=/cluster/k8s/admin.kubeconfig get csr --field-selector=spec.signerName=kubernetes.io/kubelet-serving -o jsonpath='{.items[*].metadata.name}')
```

注意事项：

- kubelet 本地有有效证书时不重复提交，已批准/已拒绝的 CSR 也会在 1 小时后被自动回收。
- 需要强制重新走一遍签发流程时（例如证书丢失或想验证首次部署路径），先删掉 kubelet 本地的 serving 证书并重启 kubelet：

```bash
ansible kubelet -b -m shell -a "rm -f /data/kubelet/pki/kubelet.crt /data/kubelet/pki/kubelet.key; tmux kill-session -t kubelet"
```

## 验证 CoreDNS

### 1. 查看 coredns pod 与 kube-dns Service

```bash
/cluster/k8s/client/bin/kubectl --kubeconfig=/cluster/k8s/admin.kubeconfig get pod -n kube-system -l k8s-app=kube-dns -o wide
```

```bash
/cluster/k8s/client/bin/kubectl --kubeconfig=/cluster/k8s/admin.kubeconfig get svc kube-dns -n kube-system
```

### 2. 集群内验证域名解析（需先预拉 busybox 镜像）

```bash
ansible nodes -b -m shell -a 'env HTTPS_PROXY=http://10.0.0.1:7897 /cluster/containerd/bin/ctr --namespace k8s.io images pull docker.io/library/busybox:1.36'
```

```bash
/cluster/k8s/client/bin/kubectl --kubeconfig=/cluster/k8s/admin.kubeconfig run dns-test --rm -it --restart=Never --image=docker.io/library/busybox:1.36 -- nslookup kubernetes.default.svc.wuzhenhua.com
```

### 3. 查看 coredns 日志（排查解析失败）

```bash
/cluster/k8s/client/bin/kubectl --kubeconfig=/cluster/k8s/admin.kubeconfig logs -n kube-system -l k8s-app=kube-dns --tail=50
```

## k8s 学习

### 1. 清理 calico-system 命名空间下的所有 pod

```bash
/cluster/k8s/client/bin/kubectl --kubeconfig=/cluster/k8s/admin.kubeconfig delete pod --all -n calico-system
```

### 2. 查看 calico-system 命名空间下的所有 pod

```bash
/cluster/k8s/client/bin/kubectl --kubeconfig=/cluster/k8s/admin.kubeconfig get pod -n calico-system -o wide
```

### 3. 查看 calico-system 命名空间下的 calico-typha pod 详情

```bash
/cluster/k8s/client/bin/kubectl --kubeconfig=/cluster/k8s/admin.kubeconfig describe pod -l k8s-app=calico-typha -n calico-system
```

### 4. 查看 calico-system 命名空间下的 calico-node pod 详情

```bash
/cluster/k8s/client/bin/kubectl --kubeconfig=/cluster/k8s/admin.kubeconfig describe pod -l k8s-app=calico-node -n calico-system
```

### 5. 查看 calico-system 命名空间下的 calico-node-driver-registrar 容器镜像

```bash
/cluster/k8s/client/bin/kubectl --kubeconfig=/cluster/k8s/admin.kubeconfig get ds csi-node-driver -n calico-system -o jsonpath='{range .spec.template.spec.containers[*]}{.image}{"\n"}{end}'
```

### 6. 查看 calico-system 命名空间下的 calico-node 滚动更新状态

```bash
/cluster/k8s/client/bin/kubectl --kubeconfig=/cluster/k8s/admin.kubeconfig rollout status ds/calico-node -n calico-system --timeout=120s
```

### 7. 查看所有命名空间下的事件（按时间倒序）

```bash
/cluster/k8s/client/bin/kubectl --kubeconfig=/cluster/k8s/admin.kubeconfig get events -A --sort-by=.lastTimestamp
```

### 8. 查看 calico-system 命名空间下的所有 Unhealthy 事件（按时间倒序）

```bash
/cluster/k8s/client/bin/kubectl --kubeconfig=/cluster/k8s/admin.kubeconfig get events -n calico-system --field-selector reason=Unhealthy | tail -n 10
```

## 清理 k8s

### 1. 停止并禁用 keepalived

```bash
ansible apiserver -b -m shell -a 'systemctl disable --now keepalived'
ansible apiserver -b -m file -a 'path=/etc/keepalived/keepalived.conf state=absent'
```

### 2. 清理 containerd 中旧集群的容器与沙箱

```bash
ansible nodes -b -m shell -a '/cluster/crictl/crictl ps -a -q | xargs -r /cluster/crictl/crictl rm -f; /cluster/crictl/crictl pods -q | xargs -r /cluster/crictl/crictl rmp -f; true'
```

### 3. 停止所有 tmux 会话

```bash
ansible nodes -b -m shell -a 'tmux kill-server 2>/dev/null; true'
```

### 4. 删除节点上的 k8s 二进制、证书、数据与配置

```bash
ansible nodes -b -m shell -a 'rm -rf /cluster/k8s /cluster/helm /cluster/pki /data/etcd /data/kubelet /etc/cni /etc/crictl.yaml /var/lib/cni /var/lib/calico /var/run/calico /cluster/etcd/etcd.config.yml'
```

### 5. 删除控制机上的 kubectl、证书签发源与 helm

```bash
ansible localhost -b -m shell -a 'rm -rf /cluster/pki'
```

### 6. 重启节点，清除 containerd-shim、netns、iptables 等内核态残留

```bash
ansible nodes -b -m reboot
```

### 7. 验证

```bash
ansible nodes -b -m shell -a 'tmux ls || true; ls -d /cluster/* /data/*; systemctl is-enabled keepalived 2>&1; true'
```

预期：`/cluster` 下只剩 `containerd`、`crictl`、`etcd`、`runc`；`/data` 下只剩 `containerd`；keepalived 为 `disabled`。

### 说明

- 保留：`/cluster/containerd`、`/cluster/runc`、`/cluster/crictl`、`/etc/containerd/config.toml`、`/data/containerd`（含镜像）、`/cluster/etcd/{etcd,etcdctl}`。
- 清除：`/cluster/k8s` 全部二进制与 kubeconfig、`/cluster/pki` 证书、etcd 数据 `/data/etcd` 与配置、kubelet 数据 `/data/kubelet`、CNI 与 Calico 残留、`/etc/crictl.yaml`。
- 重启后 containerd 与 etcd 保持停止（均由 tmux 启动，无 systemd 单元），需要时重新部署：

```bash
ansible-playbook site.yml
```

- `/etc/hosts` 里的集群主机名映射、swap、SELinux、yum 源等系统级变更由 base 角色写入，不在清理范围内。
