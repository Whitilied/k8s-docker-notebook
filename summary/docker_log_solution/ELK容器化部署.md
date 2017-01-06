# ELK容器化部署



### 测试环境

在一台安装有**docker v1.12.5**版本的主机上，测试ELK容器化运行，所需镜像及版本如下：

|     Host     |     OS      |   Dependence   |      Images       |
| :----------: | :---------: | :------------: | :---------------: |
| 192.168.3.48 | Ubuntu16.04 | Docker v1.12.5 |   logstash:5.1    |
| 192.168.3.48 | Ubuntu16.04 | Docker v1.12.5 | elasticsearch:5.1 |
| 192.168.3.48 | Ubuntu16.04 | Docker v1.12.5 |    kibana:5.1     |



### 启动elasticsearch容器

下载**elasticsearch**镜像

```
root@192.168.3.48:~# docker pull elasticsearch:5.1
```

启动**elasticsearch**容器，并开放**9200**端口

```
root@192.168.3.48:~# docker run -it --rm -p 9200:9200 --name elasticsearch elasticsearch
```

![](file:///24.png)



### 启动logstash容器

创建**logstash**配置文件，读取`/opt/logs`目录下的**testlog**文件，输出到**elasticsearch**和标准输出

```
root@192.168.3.48:~# mkdir -p /opt/configdir
root@192.168.3.48:~# vi /opt/configdir/logstash.conf
```

```
input {
  file {
    path => "/opt/logs/testlog"
    start_position => "beginning"
  }
#stdin {}
}

filter { }

output {
  elasticsearch {
    hosts => ["192.168.3.48:9200"]
  }
  stdout { codec => rubydebug }
}
```

创建测试日志文件（示例为syslog格式的web日志），修改文件权限使**logstash**可读

```
root@192.168.3.48:~# mkdir -p /opt/logs
root@192.168.3.48:~# touch /opt/logs/testlog
root@192.168.3.48:~# chmod 755 /opt/logs/testlog
root@192.168.3.48:~# vi /opt/logs/testlog
```

```
199.72.81.55 - - [01/Jul/1995:00:00:01 -0400] "GET /history/apollo/ HTTP/1.0" 200 6245
unicomp6.unicomp.net - - [01/Jul/1995:00:00:06 -0400] "GET /shuttle/countdown/ HTTP/1.0" 200 3985
199.120.110.21 - - [01/Jul/1995:00:00:09 -0400] "GET /shuttle/missions/sts-73/mission-sts-73.html HTTP/1.0" 200 4085
```

启动容器，挂载本地配置文件目录和日志文件目录。成功会自动读取日志文件并转发到标准输出和**elasticsearch**中，如下

```
root@192.168.3.48:~# docker run -it --rm -v /opt/configdir/:/configdir logstash -f /configdir/logstash.conf
```

![](file:///25.png)



### 启动kibana容器

**logstash**集中对日志进行收集过滤，**elasticsearch**提供日志存储与索引，**kibana**对elasticsearch中的数据进行可视化。

启动**kibana**容器，设置**elasticsearch**地址，开放**5601**端口

```
root@192.168.3.48:~# docker run -it --rm -p 5601:5601 --name kibana -e ELASTICSEARCH_URL=http://192.168.3.48:9200 kibana
```

![](file:///26.png)