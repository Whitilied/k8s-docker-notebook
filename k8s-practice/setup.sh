#!/bin/bash

ROOT_DIR=$(dirname "${BASH_SOURCE}")
HOST_CONF_DIR="/etc/kubernetes"
HOST_BIN_DIR="/usr/local/bin"

OS_RELEASE=$(cat /etc/*elease | grep ^ID=)
OS_VERSION=$(cat /etc/*elease | grep VERSION_ID)

if [[ ${OS_RELEASE##*=} =~ "ubuntu" ]]; then
  if [[ ${VERSION##*=} =~ "16" ]]; then
    echo "Starting install k8s for ubuntu xenial!"
  else
    echo "Doesn't support you OS version!"
    exit 1
  fi
elif [[ ${RELEASE##*=} =~ "centos" ]]; then
  if [[ ${VERSION##*=} =~ "7" ]]; then
    echo "Starting install k8s for centos 7"
  else
    echo "Doesn't support you OS version!"
    exit 1
  fi
else
    echo "Doesn't support you OS version!"
    exit 1
fi

prepare_certs() {
  echo -e "\nGenerate kubernetes certificates."
  if [ ! -d "${HOST_CONF_DIR}/pki" ]; then
    mkdir -p /etc/kubernetes/pki
  fi
    
  # create openssl config
  cat << EOF > openssl.cnf
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = kubernetes
DNS.2 = kubernetes.default
DNS.3 = kubernetes.default.svc
DNS.4 = kubernetes.default.svc.cluster.local
IP.1 = 10.96.0.1
IP.2 = ${1}
EOF
  # ca
  openssl genrsa -out ca-key.pem 2048
  openssl req -x509 -new -nodes -key ca-key.pem -days 10000\
    -out ca.pem -subj "/CN=kube-ca"
  # apiserver
  openssl genrsa -out apiserver-key.pem 2048
  openssl req -new -key apiserver-key.pem\
    -out apiserver.csr -subj "/CN=kube-apiserver" -config openssl.cnf
  openssl x509 -req -in apiserver.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial\
    -out apiserver.pem -days 365 -extensions v3_req -extfile openssl.cnf
  # admin
  openssl genrsa -out admin-key.pem 2048
  openssl req -new -key admin-key.pem -out admin.csr -subj "/CN=kube-admin"
  openssl x509 -req -in admin.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial\
    -out admin.pem -days 365
    
  mv *.pem *.csr *.srl openssl.cnf ${HOST_CONF_DIR}/pki
}

prepare_tokens() {
  echo -e "\nGenerate kubernetes tokens file."
  touch ${HOST_CONF_DIR}/pki/tokens.csv
}

prepare_components_config() {
  echo -e "\nPrepare components config files."
  if [ ! -d "${HOST_CONF_DIR}/manifests" ]; then
    mkdir -p ${HOST_CONF_DIR}/manifests
  fi
    
  for conf in ${ROOT_DIR}/cluster-config/manifests/*
  do
    sed "s/192.168.3.48/${1}/g" ${conf} > ${HOST_CONF_DIR}/manifests/${conf##*/}
  done
  if [ ! -d "${HOST_CONF_DIR}/addons" ]; then
    mkdir -p ${HOST_CONF_DIR}/addons
  fi
  cp ${ROOT_DIR}/cluster-config/addons/* ${HOST_CONF_DIR}/addons
  sed "s/192.168.3.48/${1}/g"\
    ${ROOT_DIR}/cluster-config/kubelet.conf > ${HOST_CONF_DIR}/kubelet.conf
}

prepare_components_images() {
  echo -e "\nLoad components docker images."
  for image in $(ls ${ROOT_DIR}/images/*)
  do
    docker load -i $image
  done
}

prepare_bin() {
  echo -e "\nInstall kubelet, kubectl and cni."
  tar -zxf ${ROOT_DIR}/bin/kubectl-amd64-v1.5.1.tgz -C ${HOST_BIN_DIR}
  tar -zxf ${ROOT_DIR}/bin/kubelet-amd64-v1.5.1.tgz -C ${HOST_BIN_DIR}
    
  #TODO
  case ${RELEASE} in
    ubuntu)
      dpkg -i ${ROOT_DIR}/bin/16.04-xenial/ebtables_2.0.10.4.deb
      dpkg -i ${ROOT_DIR}/bin/16.04-xenial/socat_1.7.3.1.deb
      dpkg -i ${ROOT_DIR}/bin/16.04-xenial/kubernetes-cni_0.3.0.1.deb
      ;;
    centos)
      rpm -ivh ${ROOT_DIR}/bin/centos7/ebtables-2.0.10-15.el7.x86_64.rpm
      rpm -ivh ${ROOT_DIR}/bin/centos7/socat-1.7.2.2-5.el7.x86_64.rpm
      rpm -ivh ${ROOT_DIR}/bin/centos7/kubernetes-cni-0.3.0.1-0.07a8a2.x86_64.rpm
      ;;
  esac
}

start_kubelet() {
  echo -e "\nStarting kubelet services."
  screen -dmS kubeletsession ${HOST_BIN_DIR}/kubelet\
    --kubeconfig=/etc/kubernetes/kubelet.conf\
    --require-kubeconfig=true\
    --pod-manifest-path=/etc/kubernetes/manifests\
    --allow-privileged=true\
    --network-plugin=cni\
    --cni-conf-dir=/etc/cni/net.d\
    --cni-bin-dir=/opt/cni/bin\
    --cluster-dns=10.96.0.10\
    --cluster-domain=cluster.local
}

install_addons() {
  echo -e "\nInstall enssial addons."
  ${HOST_BIN_DIR}/kubectl apply -f ${HOST_CONF_DIR}/addons/kube-proxy.yaml
  ${HOST_BIN_DIR}/kubectl apply -f ${HOST_CONF_DIR}/addons/flannel.yaml
}


if [ -z $1 ]; then
  echo "usage: ./setup.sh ip"
else
  prepare_certs ${1}
  prepare_components_config ${1}
  prepare_tokens
  prepare_bin
  prepare_components_images
  start_kubelet
  sleep 30
  install_addons
fi

process() {
  b=''
  for ((i=0;$i<=100;i+=2))
  do
    printf "progress:[%-50s]%d%%\r" $b $i
    sleep 0.1
    b=#$b  
  done
  echo 
}