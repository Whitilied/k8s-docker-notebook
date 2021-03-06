# 下载或编译Kubernets

**@Getting Started**

下载源码进行编译或直接下载已编译版本进行Kubernetes安装。如果不打算对Kubernets进行二次开发，建议直接下载已编译的版本。

本地开发测试建议使用`Minikube`进行安装。`Minikube`启动一个本地虚拟机运行Kubernetes集群，可以轻松的进行工作。



### 已编译二进制版本

[猛戳这](https://github.com/kubernetes/kubernetes/releases)下载已编译二进制发布版本。下载最新的版本并解压（Linux或者OSX平台），OSX还可以使用[homebrew](http://brew.sh/)包管理进行安装：`brew install kubernetes-cli`



### 源码编译

获取Kubernetes源码，如果只是简单编译一个发布版本，并不需要完整的golang环境，因为所有的编译操作均在一个容器内完成。编译很简单。

```shell
git clone https://github.com/kubernetes/kubernetes.git
cd kubernetes
make release
```

更多编译细节参考[编译工具](http://releases.k8s.io/master/build-tools/)目录



### 下载Kubernetes并自动启动一个默认集群

使用wget或curl从`https://get.k8s.io`获取bash脚本，自动下载kubernets，并根据给定的云服务商创建集群。

```shell
# wget version
export KUBERNETES_PROVIDER=YOUR_PROVIDER; wget -q -O - https://get.k8s.io | bash

# curl version
export KUBERNETES_PROVIDER=YOUR_PROVIDER; curl -sS https://get.k8s.io | bash
```

目前支持的云服务供应商如下：

* `gce` - Google Compute Engine [default]
* `gke` - Google Container Engine
* `aws` - Amazon EC2
* `azure` - Microsoft Azure
* `vagrant` - Vagrant (on local virtual machines)
* `vsphere` - VMWare VSphere
* `rackspace` - Rackspace

Kubernets代码库[/cluster](https://github.com/kubernetes/kubernetes/tree/master/cluster)目录下提供所有支持的驱动，如果在改目录下没有发现适合自己的安装驱动，查看[引导教程](http://kubernetes.io/docs/getting-started-guides)