#!/bin/bash

if [[ $# != 3 ]]; then
  echo "secrets_copy.sh <from-namespace> <secrets> <to-namespace>"
  exit 0
else
  NS1=$1
  SECRETS=$2
  NS2=$3
fi

kubectl -n $NS1 get secrets $SECRETS -o yaml | yq eval '.metadata.namespace = "$NS2"' | kubectl apply -n $NS2  -f -

