# fleet-baseline

What is this?

This is a template for fully compliant Kubernetes Fleet on AWS.

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

* Running Kubernetes Clusters (ver at least 1.18)
* [direnv](https://github.com/direnv/direnv)
* [envsubst](https://github.com/a8m/envsubst)
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
* view the weavescope `kubectl -n monitoring port-forward $(kubectl -n monitoring get endpoints weave-scope-weave-scope -o jsonpath='{.subsets[0].addresses[0].targetRef.name}') 8080:4040`
* helm list `helm list -A`
* helm get  `helm get <nameofrelease> -n <namespace>`
* kubei get `kubectl -n kubei get pod -lapp=kubei`
* kubei pf `kubectl -n kubei port-forward $(kubectl -n kubei get pods -lapp=kubei -o jsonpath='{.items[0].metadata.name}') 8080`
* kubei logs `kubectl -n kubei logs $(kubectl -n kubei get pods -lapp=kubei -o jsonpath='{.items[0].metadata.name}')`
* kubei open `open http://127.0.0.1:8080/view`
* grafana pf `kubectl -n flux-system port-forward svc/grafana 3000:3000`
* grafana control plane dash `open http://127.0.0.1:3000/d/gitops-toolkit-control-plane`
* grafana reconciliation dash `open http://127.0.0.1:3000/d/gitops-toolkit-cluster`

## Compliance

NIST


## Get Started

Fork this repo

Export your GitHub personal access token as an environment variable:

or setup an `.envrc`

```
export GITHUB_TOKEN=<your-token>
export GITHUB_USER=k8s-gitops # change this to your username or orgname
export GITHUB_REPO=fleet-baseline

export ELASTICSEARCH_PASSWORD=<password>
export ELASTICSEARCH_USER=<user>
export ELASTICSEARCH_HOST=<host>

export AWS_ACCOUNT_ID=<aws account id>
export AWS_DEFAULT_REGION=eu-west-1
export AWS_PROFILE=<aws account>

export VPC_ID=<eks vpc id>

export CLUSTER_NAME=<eks>
```

create eks cluster
```
brew tap weaveworks/tap
brew install weaveworks/tap/eksctl
brew upgrade eksctl && brew link --overwrite eksctl

eksctl create cluster -f ./.eksctl/init-cluster.yaml

eksctl utils associate-iam-oidc-provider \
    --region=$AWS_REGION \
    --cluster $CLUSTER_NAME \
    --approve

eksctl create iamserviceaccount \
    --cluster $CLUSTER_NAME \
    --namespace appmesh-system \
    --name appmesh-controller \
    --attach-policy-arn  arn:aws:iam::aws:policy/AWSCloudMapFullAccess,arn:aws:iam::aws:policy/AWSAppMeshFullAccess \
    --override-existing-serviceaccounts \
    --approve
```

setup elastic search credentials

```
direnv allow
kubectl create ns monitoring
cat clusters/init-cluster/monitoring/event-exporter/01-configmap.yaml.template | envsubst | kubectl apply -f -
```

cleanup my tenants. you need to create your own tenants later.
```
rm -rf tenants/
```

for more details on elasticsearch setup see this [blog](https://thechief.io/c/kenichishibata/exporting-kubernetes-events-aws-elastic-search/)

### Setup the Init Cluster
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

Here's an example the template is on the [opa-templates](https://github.com/k8s-gitops/fleet-baseline/blob/main/infrastructure/opa-templates/constraint-template.yaml) dir and the contraint implementation is on [gatekeeper-system](https://github.com/k8s-gitops/fleet-baseline/blob/main/infrastructure/policies/gatekeeper-system/allow-registry/constraint.yaml) dir in init-cluster.

## Secrets management

You need to setup KIAM or IRSA or manually attach policy the noderole with following policy

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetResourcePolicy",
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret",
        "secretsmanager:ListSecretVersionIds"
      ],
      "Resource": [
        "arn:aws:secretsmanager:<region>:<accountid>:somesecret-*"
      ]
    }
  ]
}
```

## Monitoring Stack

* https://toolkit.fluxcd.io/guides/monitoring/


## App mesh 

Once you bootstrap the cluster will have aws appmesh by default. The next step is to deploy the test application available at. 

https://github.com/aws/aws-app-mesh-examples/tree/master/walkthroughs/howto-k8s-http2

make sure to export these environment variables before doing a `./deploy.sh`

```
git clone git@github.com:aws/aws-app-mesh-examples
cd walkthrough/howto-k8s-http2

export AWS_ACCOUNT_ID=<>
export AWS_DEFAULT_REGION=<>
export AWS_PROFILE=<>
export VPC_ID=<>

```

make sure you comment out the `kubectl apply -f` part of the `deploy.sh script` and change it to `echo` to tell your where it stored your manifests.

Once you get the manifest delete the `Mesh` resource since it will conflict with the existing mesh here. For some reason only a single `Mesh` is allowed currently.

copy the `manifest.yaml` and move it to one of the tenants dir.

check the app mesh resources in

https://github.com/aws/aws-app-mesh-examples/blob/main/walkthroughs/eks/base.md


TODO:: add an ingress gateway for appmesh https://github.com/aws/aws-app-mesh-examples/tree/master/walkthroughs/howto-k8s-ingress-gateway

Installation of AppMesh Failed:: https://github.com/aws/aws-app-mesh-controller-for-k8s/issues/447

## Linkerd

https://linkerd.io/2/getting-started/


## Cleanup 

```
eksctl delete <cluster name>
```

## References
* [Flux App Mesh](https://www.youtube.com/watch?v=cB7iXeNLteE&t=2s&ab_channel=Weaveworks%2CInc.)
* [App Mesh Deep Dive](https://www.youtube.com/watch?v=FUpRWlTXDP8&ab_channel=AWSOnlineTechTalks)
* [Source for App mesh Gitops](https://github.com/k8s-gitops/gitops-appmesh)
* [App mesh Blue Green Examples](https://github.com/aws/aws-app-mesh-examples)


### Security Refs
* [Attack this! A guide](https://medium.com/faun/attacking-kubernetes-clusters-using-the-kubelet-api-abafc36126ca)
* [accurics threat modeling](https://www.youtube.com/watch?v=fup0hCk46XE&t=5s&ab_channel=Accurics)
* [security academy](https://portswigger.net/web-security/all-materials)

[kubeval]: https://www.kubeval.com/#full-usage-instructions
[kube-linter]: https://docs.kubelinter.io/#/
[trivy]: https://github.com/aquasecurity/trivy

## Troubleshooting

Q: Im getting on app mesh

```
  Error from server (failed to find matching mesh for namespace: howto-k8s-http2, expecting 1 but found 0): error when creating "58628260-0469-4e8d-b59e-3210e834bb6b.yaml": admission webhook "mvirtualservice.appmesh.k8s.aws" denied the request: failed to find matching mesh for namespace: howto-k8s-http2, expecting 1 but found 0
```

A: Make sure you add OIDC and Service Acccount Priviege needed. Step 7 and 8 in https://docs.aws.amazon.com/app-mesh/latest/userguide/getting-started-kubernetes.html

or

```
eksctl utils associate-iam-oidc-provider \
    --region=$AWS_REGION \
    --cluster $CLUSTER_NAME \
    --approve

eksctl create iamserviceaccount \
    --cluster $CLUSTER_NAME \
    --namespace appmesh-system \
    --name appmesh-controller \
    --attach-policy-arn  arn:aws:iam::aws:policy/AWSCloudMapFullAccess,arn:aws:iam::aws:policy/AWSAppMeshFullAccess \
    --override-existing-serviceaccounts \
    --approve
```


Q: Im getting TLS bad cert error for app mesh controller

A: It looks like this is normal. You have to wait for a while until envoy TLS resolves. To observe it follow the logs of appmesh controller. 

```
 kubectl logs -n appmesh-system deploy/appmesh-controller
```
