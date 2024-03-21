#!/bin/bash

if [[ $# != 2 ]]; then
  echo "view_secret.sh <namespace> <secrets> "
  exit 0
else
  NS1=$1
  SECRETS=$2
fi

kubectl -n $NS1 get secrets $SECRETS -o yaml | yq '.data.[] |  @base64d'

