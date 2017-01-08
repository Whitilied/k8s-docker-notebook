# 创建多容器pod



### 创建一个pod

多容器pod的创建必须使用create指令创建。create指令读取yaml或者json配置文件设置pod属性。

create指令可以直接创建pod，也可以通过deployment创建一个或多个pod。强烈建议使用deployment创建pod，deployment可以在pod失败后进行重启

如果不想创建deployment监控pod，可以使用create指令直接创建pod



### 使用create指令

建议使用deployment创建pod。如果pod中含有多个容器，或者不想创建deployment，使用kubectl create指令并传递一个json或者yaml配置文件

```
$ kubectl create -f FILE
```

* `-f FILE`或者`--filename FILE` 是pod配置文件

成功创建后会返回pod的名称，使用kubectl get命令进行查看



### pod配置文件

pod配置文件可以是yaml格式或者json格式，文件中指定了pod的配置信息

```
apiVersion: v1
kind: Pod
metadata:
  name: ""
  labels:
    name: ""
  namespace: ""
  annotations: []
  generateName: ""
spec:
  ? "// See 'The spec schema' for details."
  : ~
```

* kind: pod
* apiVersion: v1
* metadata: 对象元信息
  * name: 必须提供如果generateName没有设定。是pod的名称，必须在namespace中唯一
  * labels: 可选的key/value键值对，deployment和services使用labels分组和标记pod
  * generateName:：如果name没有给定则必须提供值，用于生成唯一名称的前缀
  * namespace: 必须提供，pod的命名空间
  * annotations：可选的，key/value映射，外部工具使用该值进行存储对象元信息



### spec模式

spec模式通常有以下字段

```
spec:
  containers:
    -
      args:
        - ""
      command:
        - ""
      env:
        -
          name: ""
          value: ""
      image: ""
      imagePullPolicy: ""
      name: ""
      ports:
        -
          containerPort: 0
          name: ""
          protocol: ""
      resources:
        cpu: ""
        memory: ""
  restartPolicy: ""
  volumes:
    -
      emptyDir:
        medium: ""
      name: ""
      secret:
        secretName: ""
```

containers[]

pod内的容器列表，pod创建后不能增加或删除容器，pod至少含有一个容器

containers对象必须包含：

* name：容器名称，在pod内必须唯一且不能更新，该名称也是dns解析名
* image：镜像名称

containers对象可选字段：

* command[]：命令不能在shell中运行，如果不设置则使用docker镜像默认entrypoint，不能被更新
* args[]：entrypoint参数数组，如果不设置则使用docker镜像默认cmd指令，不能被更新
* env[]：环境变量列表，key:value格式，不能被更新
  * name：环境变量名称
  * value：环境变量值，默认空字符串
* imagePullPolicy：镜像拉取策略，支持的值有：
  * Always
  * Nerver
  * IfNotPresent
* ports[]：容器开放端口列表，不能被更新
  * containerPort：端口
  * name：port的名称，service可以使用，必须在pod内唯一
  * protocol：port的协议，UDP或者TCP，默认TCP
* resources：容器申请的主机资源
  * cpu：容器的cpu资源，默认整个cpu，支持扩展。如果主机没有足够的资源，pod将不会被调度
  * memory：容器内存，不能修改，如果主机没有足够的资源，pod不会被调度

restartPolicy

pod内容器重启策略，支持参数

* Always
* OnFailure
* Nerver

volumes[]

pod内容器可挂载的存储卷，必须给存储卷指定名称和路径。容器必须包含volumeMount匹配name

* emptyDir：pod生命周期内的临时目录
  * medium：回滚数据卷的存储类型，必须是空字符串或者Memory
* hostPath：主机路径
  * path：host目录路径
* secret：
  * secretName：pod命名空间内secret的名称



### 配置文件示例

配置文件示例包含2个容器，一个redis和一个django

```
apiVersion: v1
kind: Pod
metadata:
  name: redis-django
  labels:
    app: web
spec:
  containers:
    - name: key-value-store
      image: redis
      ports:
        - containerPort: 6379
    - name: frontend
      image: django
      ports:
        - containerPort: 8000
```



