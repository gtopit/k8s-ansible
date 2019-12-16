目的：
    使用ansible-playbook实现基于centos7系统下k8s集群的自动化部署

准备：
    1、需要所有服务器的用户名和密码一致。
    2、在使用之前，请确保groups/all.yml的software_dir下已解压好所需要的安装包，需要的包如下
    密钥生成工具：
      |-- cfssl.tar.gz（包名称必须为cfssl.tar.gz）
          |-- cfssl
          |-- cfss-certinfo
          |-- cfssljson
    etcd安装包：
      |-- etcd-v3.3.13-linux-amd64.tar.gz（正则匹配etcd-v*.tar.gz）
    docker安装rpm：
      |-- container-selinux-2.107-3.el7.noarch.rpm（正则匹配container-selinux-2.*.rpm）
      |-- containerd.io-1.2.6-3.3.el7.x86_64.rpm（正则匹配containerd.io-*.rpm）
      |-- docker-ce-18.09.9-3.el7.x86_64.rpm（正则匹配docker-ce-*.rpm）
      |-- docker-ce-cli-18.09.9-3.el7.x86_64.rpm（正则匹配docker-ce-*.rpm）
    kubernetes安装包：
      |-- kubernetes-server-linux-amd64-1.16.tar.gz（正则匹配kubernetes-server-linux-amd64-*.tar.gz）
    docker镜像：
      |-- image.tar.gz（包名称必须为image.tar.gz）
          |-- coredns.tar（域名解析）
          |-- dashboard.tar（管理k8s资源的web UI）
          |-- flannel.tar（网络插件）
          |-- metrics-scraper.tar（管理k8s资源的web UI相关）
          |-- nginx-ingress-controller.tar（网络入口控制器）
          |-- pause.tar（pod网络通讯）
    nginx安装rpm：
      |-- nginx-1.16.1-1.el7.ngx.x86_64.rpm（正则匹配nginx-*.rpm）
    keepalived安装rpm：
      |-- net-snmp-libs-5.7.2-43.el7.x86_64.rpm（正则匹配net-snmp-*.rpm）
      |-- net-snmp-agent-libs-5.7.2-43.el7.x86_64.rpm（正则匹配net-snmp-*.rpm）
      |-- keepalived-1.3.5-16.el7.x86_64.rpm（正则匹配keepalived-*.rpm）

安装ansible（如果需要安装最新版的ansible，需要安装epel-release）
  yum install -y epel-release
  yum install -y ansible

使用示例1（单master）：
         ip                 软件安装
    192.168.233.111    master01-k8s、etcd01、docker
    192.168.233.112    node01-k8s、etcd02、docker
    192.168.233.113    node02-k8s、etcd03、docker
    步骤一-修改配置文件：
      1、groups/all.yml
        cert_hosts:
          etcd:
            - 192.168.233.111
            - 192.168.233.112
            - 192.168.233.113
          # 本地主机、service_cidr的第一个IP和k8s master ip
          k8s:
            - 10.0.0.1
            - 127.0.0.1
            - 192.168.233.111
      2、hosts
        [etcd]
        192.168.233.111 etcd_hostname=etcd01
        192.168.233.112 etcd_hostname=etcd02
        192.168.233.113 etcd_hostname=etcd03

        [k8s_master]
        192.168.233.111 node_hostname=master01-k8s

        [k8s_node]
        192.168.233.112 node_hostname=node01-k8s
        192.168.233.113 node_hostname=node02-k8s
    步骤二-下载解压执行
      1、下载本项目
      2、解压进入项目
      3、执行 ansible-playbook -i hosts -t standalone k8s-deploy.yml -uroot -k
    提示：如果etcd安装在另外三台服务器，则只需要将groups/all.yml文件的cert_hosts.etcd和hosts文件的[etcd]修改为那三台服务器地址即可

使用示例2（多master）：
         ip                 软件安装
    192.168.233.111    etcd01
    192.168.233.112    etcd02
    192.168.233.113    etcd03
    192.168.233.114    master01-k8s
    192.168.233.115    master02-k8s
    192.168.233.117    node01-k8s
    192.168.233.118    node02-k8s
    192.168.233.30     lb1-k8s
    192.168.233.40     lb2-k8s
    步骤一-修改配置文件：
      1、groups/all.yml
        cert_hosts:
          etcd:
            - 192.168.233.111
            - 192.168.233.112
            - 192.168.233.113
          # 包含所有LB、VIP（192.168.233.250）、本地主机、service_cidr的第一个IP和k8s master ip（可以不需要）
          k8s:
            - 10.0.0.1
            - 127.0.0.1
            - 192.168.233.114
            - 192.168.233.115
            - 192.168.233.30
            - 192.168.233.40
            - 192.168.233.250
      2、hosts
        [etcd]
        192.168.233.111 etcd_hostname=etcd01
        192.168.233.112 etcd_hostname=etcd02
        192.168.233.113 etcd_hostname=etcd03

        [k8s_master]
        192.168.233.114 node_hostname=master01-k8s
        192.168.233.115 node_hostname=master02-k8s

        [k8s_node]
        192.168.233.117 node_hostname=node01-k8s
        192.168.233.118 node_hostname=node02-k8s
    步骤二-下载解压执行
      1、下载本项目
      2、解压进入项目
      3、执行 ansible-playbook -i hosts -t multi k8s-deploy.yml -uroot -k

集群扩展：
  一、node节点扩展
    1、修改hosts文件，将需要扩展的节点加入[k8s_extend_node]下，如：
        [k8s_extend_node]
        192.168.233.119 node_hostname=node03-k8s
    2、执行  ansible-playbook -i hosts k8s-extend-node.yml -uroot -k
