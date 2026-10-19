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
