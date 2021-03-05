Setup your users to be bound to an RBAC via IAM Auth
==============


* https://eksctl.io/usage/iam-identity-mappings/

These are created by default on EKS creation.

Get all mappings
```
❯ eksctl get iamidentitymapping --cluster dev-cluster-1000
ARN												USERNAME				GROUPS
arn:aws:iam::012345678901:role/eksctl-dev-cluster-1000-nodegroup-NodeInstanceRole-4ITFHC28ZVLV	system:node:{{EC2PrivateDNSName}}	system:bootstrappers,system:nodes
arn:aws:iam::012345678901:role/eksctl-dev-cluster-1000-nodegroup-NodeInstanceRole-AR2TCRJBEHF	system:node:{{EC2PrivateDNSName}}	system:bootstrappers,system:nodes

```

This is the same as getting it from the Configmap 
```
❯ kubectl get cm -n kube-system aws-auth -o yaml
apiVersion: v1
data:
  mapRoles: |
    - groups:
      - system:bootstrappers
      - system:nodes
      rolearn: arn:aws:iam::029718257588:role/eksctl-dev-cluster-1000-nodegroup-NodeInstanceRole-AR2TCRJBEHF
      username: system:node:{{EC2PrivateDNSName}}
    - groups:
      - system:bootstrappers
      - system:nodes
      rolearn: arn:aws:iam::029718257588:role/eksctl-dev-cluster-1000-nodegroup-NodeInstanceRole-4ITFHC28ZVLV
      username: system:node:{{EC2PrivateDNSName}}
  mapUsers: |
    - []
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
```

Create a mapping for my kshibata iam user. it can also be roles.
```
❯  eksctl create iamidentitymapping --cluster dev-cluster-1000 --arn arn:aws:iam::029718257588:user/kshibata --group system:users --username kshibata
```

Check again
```
❯ eksctl get iamidentitymapping --cluster dev-cluster-1000
ARN												USERNAME				GROUPS
arn:aws:iam::029718257588:role/eksctl-dev-cluster-1000-nodegroup-NodeInstanceRole-4ITFHC28ZVLV	system:node:{{EC2PrivateDNSName}}	system:bootstrappers,system:nodes
arn:aws:iam::029718257588:role/eksctl-dev-cluster-1000-nodegroup-NodeInstanceRole-AR2TCRJBEHF	system:node:{{EC2PrivateDNSName}}	system:bootstrappers,system:nodes
arn:aws:iam::029718257588:user/kshibata								kshibata				system:users
```

```
❯ kubectl get cm -n kube-system aws-auth -o yaml
apiVersion: v1
data:
  mapRoles: |
    - groups:
      - system:bootstrappers
      - system:nodes
      rolearn: arn:aws:iam::029718257588:role/eksctl-dev-cluster-1000-nodegroup-NodeInstanceRole-AR2TCRJBEHF
      username: system:node:{{EC2PrivateDNSName}}
    - groups:
      - system:bootstrappers
      - system:nodes
      rolearn: arn:aws:iam::029718257588:role/eksctl-dev-cluster-1000-nodegroup-NodeInstanceRole-4ITFHC28ZVLV
      username: system:node:{{EC2PrivateDNSName}}
  mapUsers: |
    - userarn: arn:aws:iam::029718257588:user/kshibata
      username: kshibata
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
```

Now if you try to login and get pods. you will still get the errors

```
❯ export AWS_PROFILE=kshibata
❯ kubectl get pods -A
error: You must be logged in to the server (Unauthorized)
```

You need to bind the user (username) `kshibata` to a `role` or `clusterrole`. Alternatively you can use the newly created group `system:users`.

```
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: kshibata-clusterrole
  namespace: rbac-system
rules:
- apiGroups:
  - ""
  resources:
  - pods
  verbs:
  - get
  - list
  - watch
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: kshibata-clusterrolebinding
  namespace: rbac-system
subjects:
- kind: User
  name: kshibata
  namespace: rbac-system
roleRef:
  kind: ClusterRole
  name: kshibata-clusterrole
  apiGroup: rbac.authorization.k8s.io

```
try again!
```
❯ kubectl get nodes
Error from server (Forbidden): nodes is forbidden: User "kshibata" cannot list resource "nodes" in API group "" at the cluster scope
❯ kubectl get pods
NAME                                    READY   STATUS    RESTARTS   AGE
kubernetes-dashboard-58c67fdb89-qtjhj   1/1     Running   0          24h
```
