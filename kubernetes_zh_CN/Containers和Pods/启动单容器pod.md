# 启动单容器pod



### 创建一个pod

使用run指令创建单容器pod。读取命令行参数作为pod的参数。run指令创建一个deployment监控pod，一旦pod失败，deployment会根据参数设定的值重启pod。如果不想创建deployment监控pod，使用create指令。

使用run指令创建pod

```
$ kubectl run NAME
    --image=image
    [--port=port]
    [--replicas=replicas]
    [--labels=key=value,key=value,...]
```

* kubectl run创建一个名为nginx的deployment，k8s v1.2版本以下创建replication controller而不是deployment，使用--generator=run/v1创建replication controller

* NAME属性是必须要提供的，它不仅是即将创建容器的名称，也是deployment的名称，还是pod名的前缀

  ```
  $ kubectl run example --image=nginx
  deployment "example" created

  $ kubectl get pods -l run=example
  NAME                       READY     STATUS    RESTARTS   AGE
  example-1934187764-scau1   1/1       Running   0          13s
  ```

* `--image=IMAGE`必须提供，是容器的镜像

* `--port=PORT`对外暴露的端口

* `--replicas=NUM` 是pod副本的数量，如果不提供，默认只创建1个pod

* `--labels=key=value`指定一个或多个标签附加在pod上，除了指定的标签，run指令自动附加run=NAME标签

使用help指令查看更多附加属性

```
$ kubectl run --help
```



### 查看pod

使用kubect get查看指定pod

```
$ kubectl get pod NAME
NAME                       READY   STATUS    RESTARTS   AGE
example-1934187764-scau1   1/1     Running   0          2d
```

查看pod部署在哪个node上，使用-o wide参数

```
$ kubectl get pod NAME -o wide
NAME                       READY   STATUS    RESTARTS   AGE   NODE
example-1934187764-scau1   1/1     Running   0          2d    gke-example-c6a38-node-xij3
```

更多信息使用describe查看

```
$ kubectl describe pod NAME
Name:        example-1934187764-scau1
Namespace:   default
Image(s):    kubernetes/example-php-redis:v2
Node:        gke-example-c6a38461-node-xij3/10.240.34.183
Labels:      name=frontend
Status:      Running
Reason:
Message:
IP:          10.188.2.10
Replication Controllers:  example (5/5 replicas created)
Containers:
  php-redis:
    Image:   kubernetes/example-php-redis:v2
    Limits:
      cpu:   100m
    State:   Running
      Started:   Tue, 04 Aug 2015 09:02:46 -0700
    Ready:   True
    Restart Count: 0
Conditions:
  Type    Status
  Ready   True
```

查看集群中的所有pod

```
$ kubectl get pods

NAME                       READY     STATUS    RESTARTS   AGE
example-1934187764-scau1   1/1       Running   0          1m
frontend-7kdod             1/1       Running   0          1d
```



### 删除一个pod

如果使用run指令创建pod，k8s会创建deployment管理和调度pod。直接删除pod，deployment会重新调度pod，永久删除pod需要删除deployment。

先查找deployment

```
$ kubectl get deployment 
NAME      DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
example   1 
```

删除deployment

```
$ kubectl delete deployment DEPLOYMENT_NAME
```

