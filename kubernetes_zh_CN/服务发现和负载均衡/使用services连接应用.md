# 使用services连接应用



### Kubernetes连接容器模型





### 在集群种发布pods

创建一个nginx pod，容器开放80端口

```
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: my-nginx
spec:
  replicas: 2
  template:
    metadata:
      labels:
        run: my-nginx
    spec:
      containers:
      - name: my-nginx
        image: nginx
        ports:
        - containerPort: 80
```

集群中的任何节点都可以访问，查看pod运行信息

```
$ kubectl create -f ./run-my-nginx.yaml
$ kubectl get pods -l run=my-nginx -o wide
NAME                        READY     STATUS    RESTARTS   AGE       NODE
my-nginx-3800858182-jr4a2   1/1       Running   0          13s       kubernetes-minion-905m
my-nginx-3800858182-kna2y   1/1       Running   0          13s       kubernetes-minion-ljyd
```

查看pod IP信息

```
$ kubectl get pods -l run=my-nginx -o yaml | grep podIP
    podIP: 10.244.3.4
    podIP: 10.244.2.5
```

