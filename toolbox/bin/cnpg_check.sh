#!/bin/bash

# Dignose postgresql pod
# Usage: cnpg_pg_prob.sh <namespace> <instance>

usage() {
  cat >&2 <<EOF
Usage: $0 [ -n NAMESPACE ] [ pod ] [ command ]

    command: 
      checkpg
      status
      controldata
      metrics
      readyz
      healthz
      version
      mode/backup
      help
   
EOF
  exit 1
}

parseArgs() {
  POSITIONAL_ARGS=()
  namespace=
  option=
  secretsOnly=false
  displayHelp=false

  while [[ $# -gt 0 ]]; do
    case $1 in
      -n)
        namespace="$2"
        shift 
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
        POSITIONAL_ARGS+=("$1") 
        shift # past argument
        ;;
    esac
  done
  set -- "${POSITIONAL_ARGS[@]}"
}

declare namespace
parseArgs $@

if [[ "$namespace" != "" ]]; then
  namespace="-n $namespace"
fi

instance=$1
command=$2

if [[ "$command" == "checkpg" ]]; then
  kubectl $namespace exec -it $instance -c postgres -- pg_isready -q
  if [[ "$?" == "0" ]]; then
    echo "PostgreSQL is ready"
    exit 0
  else 
    echo "PostgreSQL is not ready"
    exit 0
  fi
fi

# check cnp version
if [[ "$command" == "version" ]]; then
  kubectl $namespace exec -it $instance -c postgres -- /controller/manager version 
  exit 0
fi

# get pg status|controldata｜backup
if [[ "$command" == "status" || "$command" == "controldata" || "$command" == "backup" || "$command" == "mode/backup"  ]]; then
  kubectl $namespace exec -it $instance -c postgres -- curl localhost:8000/pg/$command
  exit 0
fi

if [[  "$command" == "readyz" || "$command" == "healthz" ]]; then
  kubectl $namespace exec -it $instance -c postgres -- curl localhost:8000/$command
  exit 0
fi

# get pg metrics
if [[ "$command" == "metrics" ]] ; then
  kubectl $namespace exec -it $instance -c postgres -- curl localhost:9187/$command
  exit 0
fi

# # cache
# if [[ "$command" == "backup" ]] || [[ "$command" == "cache" ]]; then
#   kubectl $namespace exec -it $instance -c postgres -- curl localhost:8010/cache/cluster
#   kubectl $namespace exec -it $instance -c postgres -- curl localhost:8010/cache/wal-restore
#   kubectl $namespace exec -it $instance -c postgres -- curl localhost:8010/cache/wal-archive
#   exit 0
# fi
