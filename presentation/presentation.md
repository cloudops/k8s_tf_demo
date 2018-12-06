#### KubeCon / Tungsten Fabric Developers Summit

# Multi-Cloud Network Segmentation with Kubernetes and TF

### Will Stevens & Syed Ahmed

December 10th, 2018

---

#### About CloudOps

CloudOps is a services organization with a simple mission...

> Help our customers own their destiny in the cloud.

In order to realize this mission, we work to:

> Deliver future-proof cloud solutions that leverage open source, key partners and CloudOps software, optimizing how cloud services are delivered, consumed, and connected.

---

## Why Tungsten Fabric

Tungsten Fabric (TF) aligns well with our mission and vision in enabling organizations to consume and manage cloud services.

- **Open source** is a key enabler for organizations to own their destiny.  It provides a level of visibility and control not achievable with proprietary software, and provides the flexibility to extend the platform with community collaboration.
- **Orchestrator integrations** with both OpenStack and Kubernetes (as well as others) creates strong ecosystem alignment which caters to both the existing tooling as well as future-proofing for the next wave of SDN deployments.
- **Service chaining** is an area in the SDN landscape which is not well covered by most implementations.  However, TF stands out in this area with its elegant service chaining implementation.
- A **clean abstraction from the underlay network** enables TF to operate in a wide variety of contexts.

---

## Tungsten Fabric + Kubernetes

Leveraging Tungsten Fabric as a CNI for Kubernetes is a powerful combination, enabling network policies and the ability to extend the Kubernetes networking into other regions or underlay networks.

<div class="center-text"><img src="./img/tf.png" style="margin-right:40px; width:380px; padding-bottom:10px;"><img src="./img/kubernetes.png"></div>

---

## Let the journey begin...

It turns out that getting Kubernetes and Tungsten Fabric to work together is not trivial, so we wanted to give a little summary of our findings.

The [Deploy Tungsten Fabric on Kubernetes in 1-step command](https://github.com/tungstenfabric/website/blob/master/Tungsten-Fabric-one-line-install-on-k8s.md) tutorial is very useful, but we still ran into these issues.

- We needed the kernel version `3.10.0-862.14.4` instead of `3.10.0-862.3.2`.
- We needed 32GB of RAM and 50GB of disk on the Kubernetes master to have enough resources.

After we are back from KubeCon, I will open a PR to improve the documentation in these areas.

---

## The journey continues...

We also ran into these challenges when deploying Kubernetes and TF together:

- We needed to change the `VROUTER_GATEWAY` variable in the helm chart to be the gateway of the underlay network and not the master IP (which is what is documented), otherwise when TF came up, we would lose network access to the master node.
- We needed to pin the Kubernetes version to `1.10.4`, as version `1.12` does not seem to be supported yet.
- We needed to pin a specific version of `docker` to use in order for everything to come up correctly.

At this point, we were able to consistently deploy Kubernetes and TF together with the ability to launch workloads.

---

## Now the interesting stuff

So now that we can spin up K8s and TF together, we want to deploy two distinct stacks in two different public clouds.

The goal of this is to be able to enable pods in a namespace in one K8s deployment to be able to communicate with a service in a namespace in a K8s deployment in a different cloud.

<div class="center-text"><img src="./img/k8s_tf_multicloud1.png"></div>

---

## Bridging the gap

An interesting thing about Tungsten Fabric is that it is a BGP speaker and is able to communicate with other BGP speakers.

Basically, if you have connectivity between two sites in the underlay network, such as a direct connect or a Site-to-Site VPN connection, Tungsten Fabric can route between them.

<div class="center-text"><img src="./img/k8s_tf_multicloud2.png"></div>