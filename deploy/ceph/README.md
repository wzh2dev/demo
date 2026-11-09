# Ceph 部署（Ansible + Vagrant）

在 CentOS 7 上使用 Ansible 手工部署 Ceph Nautilus（14.2.x），包含 3 个 mon/mgr/OSD 节点，每节点一块独立数据盘。

## 目录结构

```
deploy/ceph/
├── Vagrantfile              # 3 台 CentOS 7 VM + 每台一块 20GB 数据盘
├── inventory.ini            # mons / mgrs / osds 分组
├── site.yml                 # 部署入口
├── group_vars/all/
│   ├── connection.yml       # SSH 连接信息
│   ├── versions.yml         # Ceph 版本与 yum 源
│   └── cluster.yml          # fsid、网络、OSD 设备、默认副本数
├── playbooks/               # 01_base → 05_verify
├── tasks/                   # 各阶段具体任务
└── templates/
    └── ceph.conf.j2
```

## 前置要求

- VMware Workstation 与 Vagrant、`vagrant-vmware-desktop` 插件
- 宿主机桥接网卡名与本机一致；否则修改 `Vagrantfile` 中的 `bridge`
- 10.0.0.111 ~ 10.0.0.113 未被占用

## 快速开始

在 `deploy/ceph` 目录执行：

```bash
vagrant up
```

`vagrant up` 会依次创建 ceph1、ceph2、ceph3，每台通过 `config.vm.disk` 自动创建并挂载一块数据盘（默认 20GB）。ceph3 最后启动，在其上通过 `ansible_local` 执行 `site.yml` 完成部署。

手动重跑（在宿主机执行）：

```bash
vagrant ssh ceph3 -c "cd /vagrant && ansible-playbook site.yml"
```

按阶段执行：

```bash
vagrant ssh ceph3 -c "cd /vagrant && ansible-playbook site.yml --tags base"
```

## 验证

```bash
vagrant ssh ceph1 -c "sudo ceph -s"
vagrant ssh ceph1 -c "sudo ceph osd tree"
vagrant ssh ceph1 -c "sudo ceph df"
```

期望结果：`3 mons ... quorum`、`3 mgr`、`3 osd up/in`，health 为 `HEALTH_OK`（刚部署完成可能短暂 `HEALTH_WARN`）。

## 关键变量

| 变量 | 默认值 | 说明 |
| :--- | :--- | :--- |
| `ceph_release` | `nautilus` | el7 最后一个受支持的版本线，安装跟随源内最新版本（14.2.22） |
| `ceph_repo_baseurl` | 官方源 | 国内访问慢时可改 `group_vars/all/versions.yml` 为阿里云镜像 |
| `ceph_fsid` | 固定 UUID | 重跑/扩容时保持不变 |
| `ceph_osd_device` | `/dev/sdb` | 数据盘设备名，可通过 `lsblk` 确认 |
| `ceph_pool_default_size` | `3` | 默认 3 副本 |

## 注意事项

- 数据盘会被 `ceph-volume` 清空并重建分区，OSD 任务的 `blkid` 检查会在磁盘非空时直接失败，避免误删。
- 调整数据盘大小：`CEPH_DISK_SIZE=50GB vagrant up`，仅对新建机器生效；已创建的机器需 `vagrant destroy` 后重建，或修改后 `vagrant reload`。
- 内存按每台 4GB 配置（Ceph 守护进程较多），可在 `Vagrantfile` 中调整 `memsize`。
- 防火墙已关闭、SELinux 已禁用，仅适用于内网实验环境。
- 销毁环境：

```bash
vagrant destroy -f
```
