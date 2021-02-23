# fleet-baseline

What is this?

This is a template for fully compliant Kubernetes Fleet.

It aims to comply to NIST SP, CIS Docker Image, CIS Kubernetes, CIS Operating System.

## Supply Chain

This repo is secured by a supply chain mgmt process.

![Supply Chain Image](https://raw.githubusercontent.com/k8s-gitops/fleet-baseline/main/supply-chain.png)

**Validate**
Validate Kubernetes Manifests using [kubeval]

**Lint**
Lint Kubernetes Manifest for best practices using [kube-linter]

**Scan**
Get all images defined and scans them using [trivy]

## Prerequisites

* Running Kubernetes Clusters
## Structure

* **clusters** - clusters running
* **infrastructure** - common policies and addons across multiple clusters
* **tenants** - applications dev teams

## Cheatsheet

* flux reconcile now `flux reconcile kustomization flux-system`
* flux pause reconcilation `flux suspend kustomization flux-system`
* flux resume reoncilation `flux resume kustomization flux-system`
* flux logs `kubectl logs deploy/kustomize-controller -n flux-system`
* helm logs `kubectl logs deploy/helm-controller -n flux-system`
* flux kustomizations `flux get kustomizations -A`
* flux helmreleases `flux get helmreleases -A`
* view the weavescope `kubectl -n kube-system port-forward $(kubectl -n kube-system get endpoints weave-scope-weave-scope -o jsonpath='{.subsets[0].addresses[0].targetRef.name}') 8080:4040`
* helm list `helm list -A`
* helm get  `helm get <nameofrelease> -n <namespace>`
* kubei get `kubectl -n kubei get pod -lapp=kubei`
* kubei pf `kubectl -n kubei port-forward $(kubectl -n kubei get pods -lapp=kubei -o jsonpath='{.items[0].metadata.name}') 8080`
* kubei logs `kubectl -n kubei logs $(kubectl -n kubei get pods -lapp=kubei -o jsonpath='{.items[0].metadata.name}')`
* kubei open `open http://127.0.0.1:8080/view`



## Compliance

NIST


## Get Started

Fork this repo

Export your GitHub personal access token as an environment variable:


```
export GITHUB_TOKEN=<your-token>
export GITHUB_USER=k8s-gitops # change this to your username or orgname
export GITHUB_REPO=fleet-baseline
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

1. Create Gatekeeper templates
2. Apply them in the init-cluster or any other cluster by creating the constraint yaml.

Here's an example the template is on the [opa-templates](https://github.com/k8s-gitops/fleet-baseline/blob/main/infrastructure/opa-templates/constraint-template.yaml) dir and the contraint implementation is on [gatekeeper-system](https://github.com/k8s-gitops/fleet-baseline/blob/main/clusters/init-cluster/gatekeeper-system/allow-registry/constraint.yaml) dir in init-cluster.

## References
* [Flux App Mesh](https://www.youtube.com/watch?v=cB7iXeNLteE&t=2s&ab_channel=Weaveworks%2CInc.)
* [App Mesh Deep Dive](https://www.youtube.com/watch?v=FUpRWlTXDP8&ab_channel=AWSOnlineTechTalks)
* [Source for App mesh Gitops](https://github.com/k8s-gitops/k8s-appmesh)
* [App mesh Blue Green Examples](https://github.com/aws/aws-app-mesh-examples)



* [Attack this! A guide](https://medium.com/faun/attacking-kubernetes-clusters-using-the-kubelet-api-abafc36126ca)
* [accurics threat modeling](https://www.youtube.com/watch?v=fup0hCk46XE&t=5s&ab_channel=Accurics)

[kubeval]: https://www.kubeval.com/#full-usage-instructions
[kube-linter]: https://docs.kubelinter.io/#/
[trivy]: https://github.com/aquasecurity/trivy
