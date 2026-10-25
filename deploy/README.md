# README.md

## 快捷命令

### 同步 PKI 产物到客户机（在 Windows 宿主机执行）
```bash
vagrant rsync client
```

### 重新配置客户机（在 Windows 宿主机执行）
```bash
vagrant provision client
```

### 拉取 PKI 产物到宿主机（在 Windows 宿主机执行）
```cmd
vagrant ssh client -c "sudo cat /cluster/pki/k8s/k8s.crt" > k8s.crt
vagrant ssh client -c "sudo cat /cluster/pki/k8s/admin-client.crt" > admin-client.crt
vagrant ssh client -c "sudo cat /cluster/pki/k8s/admin-client.key" > admin-client.key
```

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

```bash
ansible nodes -b -m shell -a 'env HTTPS_PROXY=http://10.0.0.1:7897 /cluster/containerd/bin/ctr --namespace k8s.io images pull docker.io/kubernetesui/dashboard:v2.7.0'
```

```bash
ansible nodes -b -m shell -a 'env HTTPS_PROXY=http://10.0.0.1:7897 /cluster/containerd/bin/ctr --namespace k8s.io images pull docker.io/kubernetesui/metrics-scraper:v1.0.8'
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

## 访问 Kubernetes Dashboard

### 1. 在 client 机上启动 kubectl proxy

```bash
/cluster/k8s/client/bin/kubectl --kubeconfig=/cluster/k8s/admin.kubeconfig proxy --address=0.0.0.0 --port=8001 --accept-hosts='.*'
```

### 2. 获取 admin-user 登录 token

```bash
/cluster/k8s/client/bin/kubectl --kubeconfig=/cluster/k8s/admin.kubeconfig create token admin-user -n kubernetes-dashboard
```

默认有效期 1 小时，可用 `--duration=24h` 延长（上限受 kube-apiserver 配置约束）。

### 3. 在 Windows 宿主机浏览器打开

```text
http://10.0.0.99:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
```

粘贴上一步的 token 登录。

### 4. 验证 Dashboard 与 metrics-scraper

```bash
/cluster/k8s/client/bin/kubectl --kubeconfig=/cluster/k8s/admin.kubeconfig get pod -n kubernetes-dashboard -o wide
```

### 5. 单独重新部署

```bash
ansible-playbook playbooks/10_dashboard.yml
```

## k8s 学习

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
