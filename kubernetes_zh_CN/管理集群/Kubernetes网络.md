# Kubernetes网络



Kurbernetes网络实现与Docker默认网络实现有些不同，主要有如下4个问题需要解决：

1. 高度关联的**容器间**通信`container-to-container`，通过`pods`解决，`pod`内容器使用`localhost`通信
2. **Pod**间通信`Pod-to-Pod`，本文详细介绍
3. **Pod与Service**通信`Pod-to-Service`，[services里阐述](http://kubernetes.io/docs/user-guide/services/)
4. **外部与Service**通信`External-to-Service`，[services里阐述](http://kubernetes.io/docs/user-guide/services/)




### 概述

Kubernetes假定所有的pod可以相互通信，不论pod在哪台主机。它为pod提供自己的IP地址，pod间不需要建立link，也不需要处理容器与主机端口映射的问题。这创建了一个干净，向后兼容的模型，从端口分配，命名，服务发现，负载平衡，应用程序配置和迁移的角度来看，pod就像虚拟机或物理机一样。



### Docker模型

Docker默认使用主机私有网络host-private。Docker默认创建docker0网桥，并为该网桥分配一个私有子网地址。Docker会为创建的每个容器分配veth虚拟网卡，veth网卡在容器中被映射为eth0，docker0网桥会为veth分配一个私有IP，从而实现互相通信。

Docker网络模型只能使容器在同一台主机通信，不能进行跨主机通信，因为他们可能拥有完全相同的子网和IP地址。

为了使容器能够跨主机通信，必须为容器分配端口，使用主机IP:Port方式，即主机端口映射进行通信。很显然，容器间需要协调好端口使用情况，或者进行动态端口分配。



### Kubernetes模型

处理端口映射问题非常复杂，不同开发人员，不同应用之间维护端口映射会非常困难。Kubernetes使用一种不同的实现方式。

Kubernetes在网络实现上添加以下几点策略（禁止任何刻意的网络分段策略）

* 所有container可以互相通信不使用NAT
* 所有node可与所有container通信不使用NAT
* container所见自己IP与其他container或者node看到的相同

实际上，Kubernetes为Pod分配IP。Pod内的container共享网络命名空间包括IP地址。这意味着同一个Pod内的container可以通过`localhost:port`互相访问，Pod内的container需要协调端口使用。我们称这种为“IP-per-Pod”模型。`app containers`需要加入Docker的网络命名空间使用`--net=container:<id>`

使用`IP:Port`请求时，Port是Node端口，Node会把特定端口的流量转发到特定Pod，Pod本身不知晓主机端口情况。



### 实现

有很多实现方式，下面列出一些实现方式仅供参考

##### Contiv

##### Flannel



