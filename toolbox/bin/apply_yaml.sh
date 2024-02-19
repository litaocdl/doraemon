#!/bin/bash

api_cnpg=postgresql.cnpg.io/v1
api_cnp=postgresql.k8s.enterprisedb.io/v1

apiVersion=$api_cnp

fileName=$1

envsubst < $DRM/toolbox/yaml/backup_restore/cluster-with-backup.yaml | kubectl apply -f - 
