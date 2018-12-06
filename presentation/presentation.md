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

I personally feel that leveraging Tungsten Fabric as a CNI for Kubernetes is a powerful combination.  