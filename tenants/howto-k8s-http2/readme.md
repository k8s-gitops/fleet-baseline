How to test the colorapp?
---------

Get thjis?

I couldn't make this one work without using cloudmaps (cloudmap is broken)

https://github.com/k8s-gitops/aws-app-mesh-examples/blob/master/walkthroughs/eks/base.md

```
kubectl get all -n howto-k8s-http2
```

Clean this up
```
kubectl delete -f manifest.yaml
kubectl delete ns howto-k8s-http2
```
