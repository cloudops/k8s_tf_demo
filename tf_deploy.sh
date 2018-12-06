#!/usr/bin/env bash

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

K8S_MASTER_IP=$1 
sudo mkdir -pm 777 /var/lib/contrail/kafka-logs
curl https://github.com/Juniper/contrail-controller/wiki/contrail.yml | awk '/<pre><code>/{flag=1;next}/<\/pre>/{flag=0}flag' | sed "s/{{ K8S_MASTER_IP }}/$K8S_MASTER_IP/g" >> tf.yaml

# change the `VROUTER_GATEWAY` to the underly gateway or network connectivity to the master will be lost
sed -i "s/VROUTER_GATEWAY: $1/VROUTER_GATEWAY: $2/g" tf.yaml
sed -i "s/:latest/:$BUILD_TAG/g" tf.yaml

kubectl apply -f tf.yaml