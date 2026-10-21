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
ansible kubelet -b -m shell -a "rm -f /var/lib/kubelet/pki/kubelet.crt /var/lib/kubelet/pki/kubelet.key; tmux kill-session -t kubelet"
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
