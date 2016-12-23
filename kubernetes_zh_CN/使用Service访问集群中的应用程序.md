# 使用Service访问集群中的应用程序

@使用教程



本页展示如何创建一个Kubernetes Service对象，外部客户端通过service访问集群内的正在运行的应用。Service为一个运行2个实例的应用提供负载均衡。



### 目标

* 创建Hello World应用，开启2个实例
* 创建具有公共端口节点的Service对象
* 通过Service访问运行中的应用



### 准备工作

必须拥有一个Kubernetes集群，kubectl命令行工具可以正常与集群进行通信。如果没有这个环境，使用[Minikube](http://kubernetes.io/docs/getting-started-guides/minikube)进行创建。



### 为在两个pod中运行的应用创建service

1. 在集群中创建helloworld应用

   ```shell
   kubectl run hello-world --replicas=2 --labels="run=load-balancer-example" --image=gcr.io/google-samples/node-hello:1.0  --port=8080
   ```

   上述指令创建了一个deployment对象和一个replicaset对象，replicaset对象拥有2个pod，每个pod都运行一个helloworld应用

2. 查看deployment对象信息

   ```
   kubectl get deployments hello-world
   kubectl describe deployments hello-world
   ```

3. 查看replicaset对象信息

   ```
   kubectl get replicasets
   kubectl describe replicasets
   ```

4. 创建一个service对象开放deployment

   ```
   kubectl expose deployment hello-world --type=NodePort --name=example-service
   ```

5. 查看service信息

   ```
   kubectl describe services example-service
   ```

   需要留意NodePort信息

6. ​
