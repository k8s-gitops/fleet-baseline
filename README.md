# fleet-build2

What is this?

This is a template for fully compliant Kubernetes Fleet.

It aims to comply to NIST SP, CIS Docker Image, CIS Kubernetes, CIS Operating System.

This is tied to a bigger `SecureByDefault PaaS` Project

## Prerequisites

* Running Kubernetes Clusters
## Structure

* **clusters** - clusters running
* **infrastructure** - common policies and addons across multiple clusters
* **tenants** - applications dev teams

## Cheatsheet

|----|
flux logs kubectl logs deploy/kustomize-controller -n flux-system
## Compliance

NIST


## Get Started

Export your GitHub personal access token as an environment variable:


```
export GITHUB_TOKEN=<your-token>
export GITHUB_USER=k8s-gitops
export GITHUB_REPO=fleet-build2
```

### Setup the Build Cluster
Run the bootstrap for a repository on your personal GitHub account:

```
flux bootstrap github \
  --owner=${GITHUB_USER} \
  --repository=${GITHUB_REPO} \
  --path=clusters/init-cluster
```

**Access Weave Scope**
```
kubectl -n kube-system port-forward $(kubectl -n kube-system get endpoints \
weave-scope-weave-scope -o jsonpath='{.subsets[0].addresses[0].targetRef.name}') 8080:4040
```

## Update Gatekeeper System
Go to 
