# Functional K8s + TF config

Note the resource requirements in the respective files `k8s_master.sh` and `k8s_worker.sh`.

## `k8s_master.sh`

Create a VM with the following specs.  TF will not run with less resources than this, so don't try to skimp.

```bash
# CentOS 7.4
# Kernel: 3.10.0-862.14.4
# CPU: 8 vCPU
# RAM: 32GB
# Root Drive: 60GB (or more)
```

SCP the `k8s_master.sh` file to the master node and run the following:

```bash
./k8s_master.sh <master_ip> <underlay_gateway_ip>
```

Wait for the services to come up.  You can check the status of the respective elements with:

```bash
# kubernetes nodes
kubectl get nodes

# kubernetes and tungsten fabric pods
kubectl get pods --all-namespaces

# tungsten fabric status (once pods are up)
sudo contrail-status
```

Once the pods are all up, note the `kubeadm join` command from the `$HOME/kubeadm_init.log` file on the master node and move on the the worker nodes.

## `k8s_worker.sh`

Create a couple VMs with the following specs.  Expect to have to troubleshoot if you use resources than specified.

```bash
# CentOS 7.4
# Kernel: 3.10.0-862.14.4
# CPU: 8 vCPU
# RAM: 16GB
# Root Drive: 40GB (or more)
```

SCP the `k8s_worker.sh` file to the worker nodes and run the following:

```bash
./k8s_worker.sh
```

Once the script finishes, copy the `kubeadm join` command from the `$HOME/kubeadm_init.log` file on the `master` node and run it on each of the workers using `sudo`.

## Checking the TF Web UI

Assuming you have a VPN connection to the network your `master` node is running on, you can now view the TF Web UI as follows.  If you don't, you will likely have to create a public IP and setup port forwarding to access the TF Web UI.

```bash
# TF Web UI
https://<k8s_master_ip>:8143

# Default Login Credentials
admin / contrail123
```