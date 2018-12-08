#!/usr/bin/env bash

## worker node on centos 7.4

## SPECS
# CentOS 7.4
# Kernel: 3.10.0-862.14.4
# CPU: 8 vCPU
# RAM: 16GB
# Root Drive: 40GB

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
sudo systemctl enable kubelet && sudo systemctl start kubelet

sudo sysctl -w net.bridge.bridge-nf-call-iptables=1
sudo systemctl stop firewalld
sudo systemctl disable firewalld

echo "Ready to run the 'kubeadm join' command on this node which was output on the 'master' node..."
echo "You may have to add '--ignore-preflight-errors=CRI' to your 'kubeadm join' command."