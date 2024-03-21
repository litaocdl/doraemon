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

## as we set -u, need check $#
startWith=
if [[ $# -gt 1 && x"$2" != "x" ]]; then
  startWith=$2
fi
skip=false
for dp in $dps
do
  if [[ x"$skip" != "xtrue" && x"$startWith" != "x" ]]; then
    if [[ $dp != $startWith ]]; then
      echo "skip $dp"
      skip=next
      continue
    fi
  fi

  if [[ x"$skip" == "xnext" ]]; then
    echo "skip $dp"
    skip=true
    continue
  fi

  echo "tsh kube login $dp"
  tsh kube login $dp
  result=$(kubectl get $find -A)
  if [[ $result != "" ]]; then
    echo "find"
    echo $dp
    exit 0
  fi
done
