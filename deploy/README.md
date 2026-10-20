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

## 手动签发 kubelet serving 证书

# 1. 查看待审批的 serving CSR
```bash
/cluster/k8s/client/bin/kubectl --kubeconfig=/cluster/k8s/admin.kubeconfig get csr --field-selector=spec.signerName=kubernetes.io/kubelet-serving
```

# 2. 批量批准（CONDITION 从 Pending 变为 Approved,Issued 即完成）
```bash
/cluster/k8s/client/bin/kubectl --kubeconfig=/cluster/k8s/admin.kubeconfig certificate approve $(/cluster/k8s/client/bin/kubectl get csr --field-selector=spec.signerName=kubernetes.io/kubelet-serving -o jsonpath='{.items[*].metadata.name}')
```

注意事项：

- kubelet 本地有有效证书时不重复提交，已批准/已拒绝的 CSR 也会在 1 小时后被自动回收。
- 需要强制重新走一遍签发流程时（例如证书丢失或想验证首次部署路径），先删掉 kubelet 本地的 serving 证书并重启 kubelet：

```bash
ansible kubelet -b -m shell -a "rm -f /var/lib/kubelet/pki/kubelet.crt /var/lib/kubelet/pki/kubelet.key; tmux kill-session -t kubelet"
```

Warning  FailedCreatePodSandBox  78s (x188 over 41m)  kubelet  Failed to create pod sandbox: rpc error: code = InvalidArgument desc = failed to create containerd container: create container failed validation: container.Runtime.Name must be set: invalid argument
