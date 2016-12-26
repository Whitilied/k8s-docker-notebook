# 安装设置kubectl

使用kubernetes的命令行工具kubectl部署和管理kubernetes应用。它可以检查集群资源，创建，删除，更新组件等。



### 使用curl获取二进制kubectl

使用下面指令获取最新版本

```shell
# OS X
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/darwin/amd64/kubectl

# Linux
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
```

如果想下载指定版本，修改上述curl指令，指定一个版本

修改kubectl二进制文件可执行，并放到指定路径中（如：/usr/local/bin）

```
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
```



### 从压缩包解压或从源码编译

