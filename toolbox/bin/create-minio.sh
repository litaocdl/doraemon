#!/bin/bash

# This script is used to deploy minio into development env in one script, for backup and restore testing purpose. 
#
# Usage: Create minio and its service in a namespace
#    create-minio.sh -n <namespace> 
#
# Usage: Create minio secrets in a namespace only
#    create-minio.sh -n <namespace> -s

# standard bash error handling
set -eEuo pipefail

MINIO_IMAGE=minio/minio:${MINIO_VERSION:-RELEASE.2022-06-20T23-13-45Z}
MINIO_CLIENT_IMAGE=minio/mc:${MINIO_CLIENT_VERSION:-RELEASE.2022-06-11T21-10-36Z}
MINIO_STORAGE_CLASS=${MINIO_STORAGE_CLASS:-standard}
MINIO_SERVICE_NAME=${MINIO_SERVICE_NAME:-minio-service}
MINIO_SECRETS_NAME=${MINIO_SECRETS_NAME:-minio-secrets}
MINIO_PVC_NAME=${MINIO_PVC_NAME:-minio-pv-claim}
MINIO_DP_NAME=${MINIO_DP_NAME:-minio}
MINIO_USERNAME=$(echo -n ${MINIO_USERNAME:-minio} | base64)
MINIO_PASSWORD=$(echo -n ${MINIO_PASSWORD:-minio123} | base64)

minio_secrets=$(
cat <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: $MINIO_SECRETS_NAME
data:
  ACCESS_KEY_ID: $MINIO_USERNAME
  ACCESS_SECRET_KEY: $MINIO_PASSWORD
EOF
)

minio_service=$(
cat <<EOF
apiVersion: v1
kind: Service
metadata:
  name: $MINIO_SERVICE_NAME
spec:
  ports:
    - port: 9000
      targetPort: 9000
      protocol: TCP
  selector:
    app: minio
EOF
)

minio_pvc=$(
cat <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: $MINIO_PVC_NAME
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
  storageClassName: $MINIO_STORAGE_CLASS
EOF
)

minio=$(
cat <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $MINIO_DP_NAME
spec:
  selector:
    matchLabels:
      app: minio
  template:
    metadata:
      labels:
        app: minio
    spec:
      volumes:
      - name: data
        persistentVolumeClaim:
          claimName: $MINIO_PVC_NAME
      containers:
      - name: minio
        resources: {}
        volumeMounts:
        - name: data
          mountPath: "/data"
        image: $MINIO_IMAGE
        args:
        - server
        - /data
        env:
        - name: MINIO_ACCESS_KEY
          valueFrom:
            secretKeyRef:
              name: $MINIO_SECRETS_NAME
              key: ACCESS_KEY_ID
        - name: MINIO_SECRET_KEY
          valueFrom:
            secretKeyRef:
              name: $MINIO_SECRETS_NAME
              key: ACCESS_SECRET_KEY
        ports:
        - containerPort: 9000
        readinessProbe:
          httpGet:
            path: /minio/health/ready
            port: 9000
          initialDelaySeconds: 30
        livenessProbe:
          httpGet:
            path: /minio/health/live
            port: 9000
          initialDelaySeconds: 30
EOF
)

minio_client=$(
cat <<EOF
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: mc
  name: mc
spec:
  containers:
  - name: mc
    env:
    - name: MC_HOST_minio
      value: "http://$(echo $MINIO_USERNAME | base64 -d):$(echo $MINIO_PASSWORD | base64 -d)@$MINIO_SERVICE_NAME:9000"
    - name: MC_URL
      value: "http://$MINIO_SERVICE_NAME:9000"
    command: ["sleep","3600"]
    image: $MINIO_CLIENT_IMAGE
  restartPolicy: Never
EOF
)

createMinio() {
    if [[ "$namespace" != "" ]]; then
       option="-n $namespace"
    fi
    echo "create minio deployment with option $option"
    kubectl $option apply -f - <<< "$minio"
    echo ""
    echo ""
    echo ""
    echo ""
    echo "******************************************************************"
    echo "Minio is deployed successfully in namespace \"$namespace\""
    echo ""
    echo "Minio can be access through http://minio-service.<namespace>:9000"
    echo ""
    echo "username is `echo $MINIO_USERNAME | base64 -d`"
    echo "password is `echo $MINIO_PASSWORD | base64 -d`"
    echo ""
    echo "If you want access minio in a different namespace, use the following command to create secrets"
    echo "create_minio.sh -n <namespace> -s"
    echo ""
    echo "******************************************************************"
}

createMinioSecrets() {
    if [[ "$namespace" != "" ]]; then
       option="-n $namespace"
    fi
    echo "create minio secrets with option $option"
    kubectl $option apply -f - <<< "$minio_secrets"
}

createMinioPVC(){
    if [[ "$namespace" != "" ]]; then
       option="-n $namespace"
    fi
    echo "create minio pvc with option $option"
    kubectl $option apply -f - <<< "$minio_pvc"
}

createMinioClient() {
    if [[ "$namespace" != "" ]]; then
       option="-n $namespace"
    fi
    echo "create minio client with option $option"
    kubectl $option apply -f - <<< "$minio_client"
}

createMinioService() {
    if [[ "$namespace" != "" ]]; then
       option="-n $namespace"
    fi
    echo "create minio service with option $option"
    kubectl $option apply -f - <<< "$minio_service"
}

checkNamespace() {
  ns=$(kubectl get ns $namespace -o jsonpath='{.metadata.name}' 2>/dev/null || true)
  if [[ -z "$ns" ]]; then
    echo "namespace \"$namespace\" does not exist"
    exit 1
  fi
}

checkMinio() {
  if [[ "$namespace" != "" ]]; then
       option="-n $namespace"
  fi
  md=$(kubectl $option get deployment $MINIO_DP_NAME -o jsonpath='{.metadata.name}' 2>/dev/null || true)
  if [[ "$md" == "$MINIO_DP_NAME" ]]; then
    echo "minio $md is already exists in namespace \"$namespace\""
    exit 1
  fi
}

usage() {
  cat >&2 <<EOF
Usage: $0 [ -n NAMESPACE ] [ -s | --secrets-only ]

    -n  The namespace minio and its resources will be created in.
          
    -s|--secrets-only  Only create the secrets for minio.
                       This is useful if you want to use secrets to access minio.

    -h|--help display this
EOF
  exit 1
}

confirm() {
  if [[ "$namespace" == "" ]]; then
    read -p "Confirm to create minio in current namespace? (y/N): " confirm
  else 
    read -p "Confirm to create minio in namespace "$namespace"? (y/N): " confirm
  fi
  if [[ -z "$confirm" ]] || [[ "$confirm" =~ ^[yY]|[yY][eE][sS]$ ]]; then
    echo "checking minio under namespace before install"
    return 0 
  else
    exit 1
  fi
}
parseArgs() {
  while [[ $# -gt 0 ]]; do
    case $1 in
      -n)
        namespace="$2"
        shift 
        shift
        ;;
      -c|client-only)
        clientOnly=true
        shift
        ;;
      -s|secrets-only)
        secretsOnly=true
        shift 
        ;;
      -h|--help)
        displayHelp=true
        shift 
        ;;
      -*|--*)
        echo "Unknown option $1"
        exit 1
        ;;
      *)
        shift # past argument
        ;;
    esac
  done
}

main(){
  option=
  namespace=
  secretsOnly=false
  displayHelp=false
  parseArgs $@

  if [[ $displayHelp == true ]]; then
    usage
  fi

  confirm
  
  if [[ "$namespace" != "" ]]; then
    checkNamespace
  fi

  if [[ $secretsOnly == true ]]; then
    createMinioSecrets
    exit 0
  fi
  if [[ $clientOnly == true ]]; then
    createMinioClient
    exit 0
  fi

  checkMinio
  createMinioPVC 
  createMinioSecrets 
  createMinioService 
  createMinioClient
  createMinio 

}


main $@





