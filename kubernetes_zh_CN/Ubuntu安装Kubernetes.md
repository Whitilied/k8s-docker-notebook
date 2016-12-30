# Ubuntu安装Kubernetes

**@Createing a Cluster**



### 依赖

1. 节点必须安装docker 1.2以上版本，和bridge-utils
2. 所有节点可以正常通信，master节点需要连接Internet下载必要文件
3. ubuntu14.04测试ok，暂不支持ubuntu 15及以上
4. etcd-2.2.1，flannel-0.5.5，k8s-1.2.0
5. 所有远程服务器可以使用key登录
6. 所有远程用户使用/bin/bash作为默认shell，并且拥有sudo权限





### 启动集群

##### 配置工作目录

```shell
$ git clone --depth 1 https://github.com/kubernetes/kubernetes.git
```

##### 配置并启动Kubernetes集群

启动程序首先会自动下载所有依赖的二进制文件。默认版本号etcd 2.2.1，flannel 0.5.5，k8s 1.2.0。改变相应的参数自定义版本

```shell
$ export KUBE_VERSION=1.2.0
$ export FLANNEL_VERSION=0.5.0
$ export ETCD_VERSION=2.2.0
```

这里使用flannel设置overlay网络。可以使用本机，flannel，open vSwitch或者任何SDN来构建k8s集群。下面是一个集群示例

```
| IP Address  |   Role   |
|-------------|----------|
|10.10.103.223|   node   |
|10.10.103.162|   node   |
|10.10.103.250| both master and node|
```

首先打开/ubuntu/config/config-default.sh文件，对集群基本信息进行配置，示例如下

```shell
export nodes="vcap@10.10.103.250 vcap@10.10.103.162 vcap@10.10.103.223"

export roles="ai i i"

export NUM_NODES=${NUM_NODES:-3}

export SERVICE_CLUSTER_IP_RANGE=192.168.3.0/24

export FLANNEL_NET=172.16.0.0/16
```

**nodes**变量定义了集群的所有节点，第一个是master节点，节点之间以空格分开，格式为**<<user_1@ip_1>> <<user_2@ip_2>> <<user_3@ip_3>>**

**roles**变量定义机器的角色，第一个为master节点，ai代表master node，a代表master，i代表node

**NUM_NODES**变量定义node节点数量

**SERVICE_CLUSTER_IP_RANGE**变量定义serviceIP范围，确保不要和本地私有IP冲突，可以根据rfc1918规定的地址范围进行选择。

```
10.0.0.0        -   10.255.255.255  (10/8 prefix)
172.16.0.0      -   172.31.255.255  (172.16/12 prefix)
192.168.0.0     -   192.168.255.255 (192.168/16 prefix)
```

**FLANNEL_NET**变量定义flannel overlay网络地址，确保不要与**SERVICE_CLUSTER_IP_RANGE**冲突。可以根据**cluster/ubuntu/config-default.sh**为Flannel网络提供额外的配置

在上述变量正确设置完成后，在**cluster**目录下执行下述指令构建整个集群

```shell
$ KUBERNETES_PROVIDER=ubuntu ./kube-up.sh
```

这个脚本使用scp自动复制二进制和配置文件到所有的机器上，并在所有机器上开启kubernetes服务。你只需要在交互过程中输入sudo密码

如果一切顺利完成，可以看到如下输出表示k8s集群正常启动

```
Cluster validation succeeded
```



### 测试

使用kubectl进行测试，kubectl在cluster/ubuntu/binaries目录下，可以把kubectl加入PATH更方便的使用。使用kubectl get nodes查看所有节点信息

```
$ kubectl get nodes
NAME            LABELS                                 STATUS
10.10.103.162   kubernetes.io/hostname=10.10.103.162   Ready
10.10.103.223   kubernetes.io/hostname=10.10.103.223   Ready
10.10.103.250   kubernetes.io/hostname=10.10.103.250   Ready
```



##### 添加插件

为一个正常运行的集群添加如DNS或者UI插件。DNS配置在cluster/ubuntu/config-default.sh脚本里。DNS_SERVER_IP必须在SERVICE_CLUSTER_IP_RANGE范围内，DNS_REPLICAS描述dns pod数量。

```shell
ENABLE_CLUSTER_DNS="${KUBE_ENABLE_CLUSTER_DNS:-true}"
DNS_SERVER_IP="192.168.3.10"
DNS_DOMAIN="cluster.local"
DNS_REPLICAS=1
```

添加UI插件

```shell
ENABLE_CLUSTER_UI="${KUBE_ENABLE_CLUSTER_UI:-true}"
```

配置完成后，执行如下指令

```shell
$ cd cluster/ubuntu
$ KUBERNETES_PROVIDER=ubuntu ./deployAddons.sh
```

正常完成后，可以使用`$ kubectl get pods --namespace=kube-system`查看DNS和UI插件运行情况



