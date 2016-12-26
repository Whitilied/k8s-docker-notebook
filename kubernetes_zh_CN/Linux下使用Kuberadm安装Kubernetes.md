# Linux下使用Kuberadm安装Kubernetes

**@Getting Started**



## 概览

使用kubeadm在Ubuntu16.04，CentOS7，HypriotOS v1.0.1+机器上安装Kubernetes集群。

安装过程在物理机/虚拟机/云服务器上均可进行。并且可以轻松的集成到自动化工具中(Terraform, Chef, Puppet, etc)。

[kubeadm参考文档](http://kubernetes.io/docs/admin/kubeadm)获取更多kubeadm相关信息，如命令行参数和自动化部署建议。

kubeadm目前还不成熟，请仔细阅读限制条件，特别注意kubeadm还没有很好地支持自动化配置云服务器，若在云服务上配置，请仔细参阅相关厂商提供的文档，或者选择另外的配置方案。

kubeadm被设计用来进行大规模配置的一部分，或者进行简单的手动配置。如果拥有自己的基础设施(裸机环境)或者要和已存在的编排系统进行交互，kubeadm是非常好的选择。

建立在kubeadm上的一些其他工具可以为你提供完整的集群：

* [Google Container Engine](https://cloud.google.com/container-engine/) for GCE
* [kops](https://github.com/kubernetes/kops) for AWS




## 依赖

1. 一台以上机器（Ubuntu16.04，CentOS7，HypriotOS v1.0.1+）
2. 每台机器至少1GB内存
3. 机器集群可以进行正常网络通信





## 目标

* 在机器上安装一个安全的Kubernetes集群
* 集群里安装pod网络，使应用组件(pods)可以互相通信
* 集群里安装一个简单的微服务应用(socks shop)




## 步骤

##### (1/4)在主机上安装kubelet和kubeadm

需要在所有的机器上安装以下软件包

* ```docker```:  运行容器，建议v1.11.2版本，v1.10.3&v1.12.1也是ok的

* ```kubelet```:  Kubernetes核心组件，启动pods和containers等，集群种所有主机都要运行kubelet

* ```kubectl```:  命令行工具与集群交互，只需要在master运行，其余节点运行有利无弊

* ```kubeadm```:  集群引导指令

  注意：如果已经安装过kubeadm软件包，需要执行apt-get update && apt-get upgrade或者yum update获取最新版本的kubeadm。[查看release文档了解版本差异](https://github.com/kubernetes/kubeadm/blob/master/CHANGELOG.md)。

* 以**root**用户登录主机

* Ubuntu或HypriotOS执行以下指令

  ```sh
  curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
  cat <<EOF > /etc/apt/sources.list.d/kubernetes.list
  deb http://apt.kubernetes.io/ kubernetes-xenial main
  EOF
  apt-get update
  # Install docker if you don't have it already.
  apt-get install -y docker.io
  apt-get install -y kubelet kubeadm kubectl kubernetes-cni
  ```

* CentOS执行以下指令

  ```shell
  cat <<EOF > /etc/yum.repos.d/kubernetes.repo
  [kubernetes]
  name=Kubernetes
  baseurl=http://yum.kubernetes.io/repos/kubernetes-el7-x86_64
  enabled=1
  gpgcheck=1
  repo_gpgcheck=1
  gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
         https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
  EOF
  setenforce 0
  yum install -y docker kubelet kubeadm kubectl kubernetes-cni
  systemctl enable docker && systemctl start docker
  systemctl enable kubelet && systemctl start kubelet
  ```

安装完成后，**kubelet**一直循环重启等待**kubeadm**下发指令

注意：为了允许容器访问主机文件系统（例如，pod网络需要），需要通过运行setenforce 0来禁用SELinux。你必须这样做，现在kubelet还不能很好处理SELinux上的这个问题



##### (2/4)初始化master服务器

master服务器是控制中心，运行包括`etcd`(集群服务器)和`apiserver`(`kubectl`交互)组件。所有组件都运行在kubelet启动的pod里。

`kubeadm init`初始化集群，只需运行一次，不能在集群释放前再次运行。如果尝试运行`kubeadm init`，并且主机处于与启动Kubernetes集群不兼容的状态，kubeadm将会警告甚至直接报错。

选择一个已经安装了`kubelet`和`kubeadm`的机器进行初始化作为master

```
# kubeadm init
```

注意：该指令自动为master选择网络接口与网关，可以使用`--api-advertise-addresses=<ip-address>`作为`kubeadm init`参数来指定网络接口，[更多kubeadm init参数信息](http://kubernetes.io/docs/admin/kubeadm/)

自动下载安装集群数据库和控制组件需要一些时间，正常输出如下：

```
[kubeadm] WARNING: kubeadm is in alpha, please do not use it for production clusters.
[preflight] Running pre-flight checks
[init] Using Kubernetes version: v1.5.1
[tokens] Generated token: "064158.548b9ddb1d3fad3e"
[certificates] Generated Certificate Authority key and certificate.
[certificates] Generated API Server key and certificate
[certificates] Generated Service Account signing keys
[certificates] Created keys and certificates in "/etc/kubernetes/pki"
[kubeconfig] Wrote KubeConfig file to disk: "/etc/kubernetes/kubelet.conf"
[kubeconfig] Wrote KubeConfig file to disk: "/etc/kubernetes/admin.conf"
[apiclient] Created API client, waiting for the control plane to become ready
[apiclient] All control plane components are healthy after 61.317580 seconds
[apiclient] Waiting for at least one node to register and become ready
[apiclient] First node is ready after 6.556101 seconds
[apiclient] Creating a test deployment
[apiclient] Test deployment succeeded
[token-discovery] Created the kube-discovery deployment, waiting for it to become ready
[token-discovery] kube-discovery is ready after 6.020980 seconds
[addons] Created essential addon: kube-proxy
[addons] Created essential addon: kube-dns

Your Kubernetes master has initialized successfully!

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
    http://kubernetes.io/docs/admin/addons/

You can now join any number of machines by running the following on each node:

kubeadm join --token=<token> <master-ip>
```

记录下最后输出的`kubeadm join`指令，可以使用该指令向集群中添加节点，token信息用来master和node互相认证，确保该指令安全保密

出于安全考虑，默认情况下集群不会在master部署pods，但可以使用下面指令解除该限制，执行成功后可以在集群任何节点部署pods

```
# kubectl taint nodes --all dedicated-
node "test-01" tainted
taint key="dedicated" and effect="" not found.
taint key="dedicated" and effect="" not found.
```



##### (3/4)安装一个pod网络

需要安装一个pod网络插件使不同pod互相通信。**必须在部署application和`kube-dns`启动前安装pod网络插件。另外kubeadm仅仅提供基础的CNI网络，因此基于kubenet的网络不会工作。**

很多项目基于CNI提供Kubernetes pod网络，有些还支持网络策略，[参考pod网络插件列表](http://kubernetes.io/docs/admin/addons/)

使用如下指令安装pod网络插件：

```# kubectl apply -f <add-on.yaml>```

详细安装细节参考相关网络插件文档。一个集群只能安装一个pod网络。如果不是amd64架构，需要使用[flannel overlay网络](http://kubernetes.io/docs/getting-started-guides/kubeadm/#kubeadm-is-multi-platform)

pod网络安装完成后，使用`kubectl get pods --all-namespaces`指令检查`kube-dns` pod是否running状态，running则成功安装。可以继续加入节点。



##### (4/4)加入节点

nodes是pods&containers工作载体，以root权限在主机上执行(2/4)步记录的kubeadm join指令，示例:

```
# kubeadm join --token <token> <master-ip>
[kubeadm] WARNING: kubeadm is in alpha, please do not use it for production clusters.
[preflight] Running pre-flight checks
[preflight] Starting the kubelet service
[tokens] Validating provided token
[discovery] Created cluster info discovery client, requesting info from "http://192.168.x.y:9898/cluster-info/v1/?token-id=f11877"
[discovery] Cluster info object received, verifying signature using given token
[discovery] Cluster info signature and contents are valid, will use API endpoints [https://192.168.x.y:6443]
[bootstrap] Trying to connect to endpoint https://192.168.x.y:6443
[bootstrap] Detected server version: v1.5.1
[bootstrap] Successfully established connection with endpoint "https://192.168.x.y:6443"
[csr] Created API client to obtain unique certificate for this node, generating keys and certificate signing request
[csr] Received signed certificate from the API server:
Issuer: CN=kubernetes | Subject: CN=system:node:yournode | CA: false
Not before: 2016-12-15 19:44:00 +0000 UTC Not After: 2017-12-15 19:44:00 +0000 UTC
[csr] Generating kubelet configuration
[kubeconfig] Wrote KubeConfig file to disk: "/etc/kubernetes/kubelet.conf"

Node join complete:
* Certificate signing request sent to master and response
  received.
* Kubelet informed of new secure connection details.

Run 'kubectl get nodes' on the master to see this machine join.
```

几秒钟之后再master执行`kubectl get nodes`查看集群和节点信息



##### (可选)在主机上对集群进行控制

在笔记本上使用kubectl对集群进行控制，需要从master复制KubeConfig文件到本地

```
# scp root@<master ip>:/etc/kubernetes/admin.conf .
# kubectl --kubeconfig ./admin.conf get nodes
```



##### (可选)连接API Server

使用kubectl proxy指令开放集群外部连接API Server访问dashboard(默认没安装)

```
# scp root@<master ip>:/etc/kubernetes/admin.conf .
# kubectl --kubeconfig ./admin.conf proxy
```

现在可以通过`http://localhost:8001/api/v1`访问本地API Server