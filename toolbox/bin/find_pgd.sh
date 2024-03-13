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

skip=
if [[ x"$2" != "x" ]]; then
  skip=$2
fi
for dp in $dps
do
  echo "tsh kube login $dp"
  if [[ $dp == $skip ]]; then 
       echo "skip $dp"
       continue
  fi
  tsh kube login $dp
  result=$(kubectl get $find -A)
  if [[ $result != "" ]]; then
    echo "find"
    echo $dp
    exit 0
  fi
done
