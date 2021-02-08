#!/usr/bin/env bats
# vim: syntax=sh
@test "Team namespaces can get pods within their own namespace" {
    run kubectl auth can-i get pods --as="example-user" -n mynamespace
    [ "$status" -eq 0 ]
    [ "$output" == "yes" ]
}

@test "Default service accounts should not be able to delete nodes" {
    run kubectl auth can-i delete nodes --as="system:serviceaccount:kube-system:default"
    [ "$status" -eq 1 ]
}

@test "Public unathenticated user should not be able to access anything in the cluster" {
    run kubectl auth can-i get nodes --as="system:public-info-viewer"
    [ "$status" -eq 1 ]
    run kubectl auth can-i get pods --as="system:public-info-viewer"
    [ "$status" -eq 1 ]
    run kubectl auth can-i get secrets --as="system:public-info-viewer"
    [ "$status" -eq 1 ]
    run kubectl auth can-i get deployment --as="system:public-info-viewer"
    [ "$status" -eq 1 ]
    run kubectl auth can-i get service --as="system:public-info-viewer"
    [ "$status" -eq 1 ]
}

# Source: https://kubernetes.io/docs/reference/access-authn-authz/authentication/#user-impersonation
# Source: https://kubernetes.io/docs/reference/access-authn-authz/rbac/
