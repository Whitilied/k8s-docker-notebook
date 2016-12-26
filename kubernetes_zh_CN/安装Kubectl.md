# 安装Kubectl

kubectl是与Kubernetes集群交互的命令行工具



### 下载发行版

[官方release版本下载](https://console.cloud.google.com/storage/browser/kubernetes-release/release/)

MacOS

```shell
wget https://storage.googleapis.com/kubernetes-release/release/v1.4.4/bin/darwin/amd64/kubectl
chmod +x kubectl
mv kubectl /usr/local/bin/kubectl
```

Linux

```shell
wget https://storage.googleapis.com/kubernetes-release/release/v1.4.4/bin/linux/amd64/kubectl
chmod +x kubectl
mv kubectl /usr/local/bin/kubectl
```

mv指令需要sudo权限，大多数人喜欢把kubectl安装到~/bin目录下，上面指令安装到/usr/local/bin目录下



### 备选方案

##### 从Google Cloud SDK安装

[点击下载Googel Cloud SDK](https://cloud.google.com/sdk/)，安装Google Cloud SDK，执行下面的指令从SDK安装kubectl

```shell
gcloud components install kubectl
```

##### 从brew安装

MacOS可以使用brew进行安装

```shell
brew install kubectl
```

**使用```kubectl version```检查版本是否为最新**



### 开启shell自动补全

kubectl提供自动补全功能，补全脚本是自带的，只需要在配置中调用

下面提供一个简单的示例，更多使用信息使用```kubectl completion -h```进行查看

##### Linux

当前shell加入自动补全，```source <(kubectl completion bash)```

自动补全加入profile中（shell启动自动加载）

```shell
echo "source <(kubectl completion bash)" >> ~/.bashrc
```

##### MacOS

安装bash-completion使bash支持自动补全

```
brew install bash-completion
```

添加到当前shell

```shell
source $(brew --prefix)/etc/bash_completion
source <(kubectl completion bash)
```

自动补全加入profile中（shell启动自动加载）

```shell
echo "source $(brew --prefix)/etc/bash_completion" >> ~/.bash_profile
echo "source <(kubectl completion bash)" >> ~/.bash_profile
```

使用```brew install kubectl```安装kubectl只显示当前工作，直接下载不会这样