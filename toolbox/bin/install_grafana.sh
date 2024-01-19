#!/bin/bash

set -eu

echo "add prometheus-community"

helm repo add prometheus-community \
  https://prometheus-community.github.io/helm-charts

helm upgrade --install \
  -f https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/main/docs/src/samples/monitoring/kube-stack-config.yaml \
  prometheus-community \
  prometheus-community/kube-prometheus-stack

# as we reply on kubernetes metrics, install the kubernetes metrics server
# kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
# kubectl patch -n kube-system deployment metrics-server --type=json \
#  -p '[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'


# kubectl -n kube-system wait deployment metrics-server --for condition=available

echo "deploy a cluster with pod monitor enabled"

kubectl apply -f - <<EOF
---
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: cluster-with-metrics
spec:
  instances: 3

  storage:
    size: 1Gi
  walStorage:
    size: 1Gi
  tablespaces:
    - name: tbs1
      storage:
        size: 1Gi
    - name: tbs2
      storage:
        size: 2Gi
  monitoring:
    enablePodMonitor: true
EOF

echo "port forward prometheus"
echo "kubectl port-forward svc/prometheus-community-kube-prometheus 9090"

echo "install grafana board"
# kubectl apply -f \
#  https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/main/docs/src/samples/monitoring/grafana-configmap.yaml

echo "port forward granafa"
echo "kubectl port-forward svc/prometheus-community-grafana 3000:80"
echo "access dashboard http://localhost:3000/login"
echo "admin/prom-operator"


