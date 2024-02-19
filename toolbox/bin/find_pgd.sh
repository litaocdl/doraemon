#!/bin/bash

# standard bash error handling
set -eEuo pipefail

# This tools is uesd for looking for the pdggroup in all dps
# need login first
dps=$(tsh kube ls | grep  "dp" | cut -f1 -d" ")
find=pgdgroup
if [[ x"$1" == "xcnp" ]]; then
  find=cluster
fi

for dp in $dps
do
  echo "tsh kube login $dp$ \n"
  tsh kube login $dp
  result=$(kubectl get $find -A)
  if [[ $result != "" ]];then
    echo "find\n"
    echo $dp
    exit 0
  fi
done
