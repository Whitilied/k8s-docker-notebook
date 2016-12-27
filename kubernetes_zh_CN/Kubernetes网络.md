# Kubernetes网络

**@Administering Cluster**

> 2016-12-27  robin Lee <<miaomiao3312763@qq.com>>



Kurbernetes网络实现与Docker默认网络实现有些不同，主要有如下4个问题需要解决：

1. 高度关联的容器间通信container-to-container，通过`pods`解决，`pod`内容器使用`localhost`通信
2. Pod间通信Pod-to-Pod，本文详细介绍
3. Pod与Service通信Pod-to-Service，[services里阐述](http://kubernetes.io/docs/user-guide/services/)
4. 外部与Service通信External-to-Service，[services里阐述](http://kubernetes.io/docs/user-guide/services/)



### 概述

Kubernetes假定所有的pod可以相互通信，不论pod在哪台主机。它为pod提供自己的IP地址，pod间不需要建立link，也不需要处理容器与主机端口映射的问题。这创建了一个干净，向后兼容的模型，从端口分配，命名，服务发现，负载平衡，应用程序配置和迁移的角度来看，pod就像虚拟机或物理机一样。



### Docker模型

Docker默认使用主机私有网络host-private。

