#!/bin/bash

ROOT_DIR=$(dirname "${BASH_SOURCE}")
HOST_CONF_DIR="/etc/kubernetes"
HOST_BIN_DIR="/usr/local/bin"

prepare_certs() {
    echo -e "prepare kubernetes certificates\n"
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
IP.2 = 192.168.3.48
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
    echo -e "generate kubernetes certificates done\n"
}

prepare_tokens() {
    echo -e "prepare kubernetes token files\n"
    touch ${HOST_CONF_DIR}/pki/tokens.csv
    echo -e "generate kubernetes token done\n"
}

prepare_bin() {
    echo -e "install kubelet, kubectl\n"
    cp ${ROOT_DIR}/bin/kubelet ${HOST_BIN_DIR}
    cp ${ROOT_DIR}/bin/kubectl ${HOST_BIN_DIR}
}

prepare_cluster_config() {
    echo -e "config cluser now\n"
    if [ ! -d "${HOST_CONF_DIR}/manifests" ]; then
        mkdir -p ${HOST_CONF_DIR}/manifests
    fi
    cp ${ROOT_DIR}/cluster-config/manifests/* ${HOST_CONF_DIR}/manifests
    cp ${ROOT_DIR}/cluster-config/kubelet.conf ${HOST_CONF_DIR}
    echo -e "config cluser down\n"
}

prepare_component_images() {
    for image in $(ls ${ROOT_DIR}/images/*.tar)
    do
        docker load -i $image
    done
    for image in $(ls ${ROOT_DIR}/images/*.gz)
    do
        docker load -i $image
    done
}

start_kubelet() {
    echo -e "starting kubelet"
    ${HOST_BIN_DIR}/kubelet\
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

#start_demo() {}

uninstall() {
    # kill -9 kubelet
    # docker rm -f $(docker ps -a --format={{.ID}})
    ip link set cni0 down
    ip link set flannel.1 down
    rm -rf /var/lib/cni/*
    rm -rf /var/lib/kubelet/*
    rm -rf /var/lib/etcd/*
}

#install() {}

prepare_certs
prepare_tokens
prepare_component_images
prepare_cluster_config