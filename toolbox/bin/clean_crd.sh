#!/bin/bash

# clean crd
if [[ $1 == "cnpg" ]];then
  echo "clean cnpg crd"
  kubectl delete ns cnpg-system
  kubectl get crd | grep cnpg | cut -f1 -d " " | xargs kubectl delete crd
else 
  echo "clean cnp crd"
  kubectl delete ns postgresql-operator-system
  kubectl get crd | grep enterprisedb | cut -f1 -d " " | xargs kubectl delete crd
fi

