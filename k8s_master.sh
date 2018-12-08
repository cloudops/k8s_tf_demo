#!/usr/bin/env bash

## master node on centos 7.4

## SPECS
# CentOS 7.4
# Kernel: 3.10.0-862.14.4
# CPU: 8 vCPU
# RAM: 32GB
# Root Drive: 60GB

if [ -z "$1" ]
then
      echo "Missing 'master' private IP as first argument..."
      exit 1
fi

if [ -z "$2" ]
then
      echo "Missing 'gateway' of the underlay network as second argument..."
      exit 1
fi

BUILD_TAG="latest"
if [ -n "$3" ]
then
      BUILD_TAG="$3"
fi

swapoff -a
sudo setenforce 0
sudo sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config

sudo bash -c 'cat > /etc/yum.repos.d/kubernetes.repo' << EOF
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
        https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

## just in case your template is ancient
#sudo yum update -y

sudo yum install -y ntp ntpdate
sudo ntpdate pool.ntp.org
sudo systemctl enable ntpd && sudo systemctl start ntpd

sudo yum install -y docker-1.13.1-75.git8633870.el7.centos
sudo systemctl enable docker.service
sudo service docker start

sudo yum install -y kubelet-1.10.11-0 kubeadm-1.10.11-0 kubectl-1.10.11-0

## disable the default CNI
sudo sed -i 's|Environment="KUBELET_NETWORK_ARGS=--network-plugin=cni --cni-conf-dir=/etc/cni/net.d --cni-bin-dir=/opt/cni/bin"|#Environment="KUBELET_NETWORK_ARGS=--network-plugin=cni --cni-conf-dir=/etc/cni/net.d --cni-bin-dir=/opt/cni/bin"|g' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
sudo systemctl daemon-reload
sudo service kubelet restart

sudo systemctl enable kubelet && sudo systemctl start kubelet

sudo sysctl -w net.bridge.bridge-nf-call-iptables=1
sudo systemctl stop firewalld
sudo systemctl disable firewalld

echo "source <(kubectl completion bash)" >> $HOME/.bashrc

sleep 60

sudo kubeadm init --apiserver-cert-extra-sans $1 >> $HOME/kubeadm_init.log
## uncomment to change the default `pod` and `service` networks
#sudo kubeadm init --apiserver-cert-extra-sans $1 --pod-network-cidr "10.48.0.0/12" --service-cidr "10.112.0.0/12" >> $HOME/kubeadm_init.log

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $USER:$USER $HOME/.kube/config

K8S_MASTER_IP=$1 
sudo mkdir -pm 777 /var/lib/contrail/kafka-logs
curl https://github.com/Juniper/contrail-controller/wiki/contrail.yml | awk '/<pre><code>/{flag=1;next}/<\/pre>/{flag=0}flag' | sed "s/{{ K8S_MASTER_IP }}/$K8S_MASTER_IP/g" >> tf.yaml

## change the `VROUTER_GATEWAY` to the underly gateway or network connectivity to the master will be lost
sed -i "s/VROUTER_GATEWAY: $1/VROUTER_GATEWAY: $2/g" tf.yaml

## define the build we want to deploy
sed -i "s/:latest/:$BUILD_TAG/g" tf.yaml

## uncomment to change the default `pod` and `service` networks
#sed -i 's|KUBERNETES_API_SECURE_PORT: "6443"|KUBERNETES_API_SECURE_PORT: "6443"\n  KUBERNETES_POD_SUBNETS: 10.48.0.0/12\n  KUBERNETES_SERVICE_SUBNETS: 10.112.0.0/12\n  KUBERNETES_IP_FABRIC_SUBNETS: 10.80.0.0/12|g' tf.yaml

kubectl apply -f tf.yaml