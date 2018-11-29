#!/usr/bin/env bash

# worker node on centos 7.4

## SPECS
# CentOS 7.4
# Kernel: 3.10.0-862.14.4
# CPU: 8 vCPU
# RAM: 16GB
# Root Drive: 40GB


swapoff -a
sudo setenforce 0
sudo sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config

sudo yum install -y docker
sudo systemctl enable docker.service
sudo service docker start

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

sudo yum update -y
sudo yum install -y kubelet-1.10.4-0 kubeadm-1.10.4-0

sudo systemctl enable kubelet && sudo systemctl start kubelet

sudo sysctl -w net.bridge.bridge-nf-call-iptables=1
sudo systemctl stop firewalld
sudo systemctl disable firewalld

echo "Ready to run the 'kubeadm join' command on this node which was output on the 'master' node..."