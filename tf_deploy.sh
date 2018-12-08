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

## change the `VROUTER_GATEWAY` to the underly gateway or network connectivity to the master will be lost
sed -i "s/VROUTER_GATEWAY: $1/VROUTER_GATEWAY: $2/g" tf.yaml

## define the build we want to deploy
sed -i "s/:latest/:$BUILD_TAG/g" tf.yaml

## uncomment to change the default `pod` and `service` networks
#sed -i 's|KUBERNETES_API_SECURE_PORT: "6443"|KUBERNETES_API_SECURE_PORT: "6443"\n  KUBERNETES_POD_SUBNETS: 10.48.0.0/12\n  KUBERNETES_SERVICE_SUBNETS: 10.112.0.0/12\n  KUBERNETES_IP_FABRIC_SUBNETS: 10.80.0.0/12|g' tf.yaml

kubectl apply -f tf.yaml