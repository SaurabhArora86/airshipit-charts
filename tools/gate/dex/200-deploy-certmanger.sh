#!/bin/bash
set -ex

kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.1.0/cert-manager.yaml

./tools/deployment/common/wait-for-pods.sh cert-manager

key=$(base64 -w0 /var/lib/minikube/certs/ca.key)
crt=$(base64 -w0 /var/lib/minikube/certs/ca.crt)
tee /tmp/ca-issuers.yaml <<EOF
---
apiVersion: v1
kind: Secret
metadata:
  name: jarvis-ca-key-pair
  namespace: cert-manager
data:
  tls.crt: $crt
  tls.key: $key
---
apiVersion: cert-manager.io/v1alpha3
kind: ClusterIssuer
metadata:
  name: jarvis-ca-issuer
spec:
  ca:
    secretName: jarvis-ca-key-pair
EOF
kubectl apply -f /tmp/ca-issuers.yaml

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.43.0/deploy/static/provider/baremetal/deploy.yaml

./tools/deployment/common/wait-for-pods.sh ingress-nginx
