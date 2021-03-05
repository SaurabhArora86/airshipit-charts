#!/bin/bash
set -ex

# shellcheck disable=SC2046

# Deployment of Dex resources
kubectl apply -f ./tools/deployment/dex-resources

./tools/deployment/common/wait-for-pods.sh dex

# Deployment of Openldap
kubectl apply -f ./tools/deployment/openldap/Openldap-sample.yaml

function config_api_server() {
  sed -i '/    - kube-apiserver/a\    - --oidc-issuer-url=https://dex.jarvis.local:5556/dex' /etc/kubernetes/manifests/kube-apiserver.yaml
  sed -i '/    - kube-apiserver/a\    - --oidc-client-id=jarvis-kubernetes' /etc/kubernetes/manifests/kube-apiserver.yaml
  sed -i '/    - kube-apiserver/a\    - --oidc-username-claim=email' /etc/kubernetes/manifests/kube-apiserver.yaml
  sed -i '/    - kube-apiserver/a\    - --oidc-username-claim="oidc:"' /etc/kubernetes/manifests/kube-apiserver.yaml
  sed -i '/    - kube-apiserver/a\    - --oidc-groups-claim=groups' /etc/kubernetes/manifests/kube-apiserver.yaml
  sed -i '/    - kube-apiserver/a\    - --oidc-ca-file=/var/lib/minikube/certs/ca.crt' /etc/kubernetes/manifests/kube-apiserver.yaml
}
config_api_server
