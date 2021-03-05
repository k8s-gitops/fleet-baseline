How generate the manifest.yaml file?
-------

```
git clone git@github.com:k8s-gitops/aws-app-mesh-examples.git

export AWS_DEFAULT_REGION=eu-west-1
export AWS_ACCOUNT_ID=<acct id>
```

Skip building images. You only need to build them once

```
export SKIP_IMAGES=true
```

Generate the manifest file

```
./walkthroughs/howto-k8s-ingress-gateway/generate.sh
```

This will then give you the location where the file is generated. You can copy the file here.
