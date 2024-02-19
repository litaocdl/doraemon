#!/bin/bash

usage() {
  echo "Update flux kustomization of UPM component with customized branch"
  echo
  echo "Usage:"
  echo "  $(basename "$0") [-h | -a component version | -r component"
  echo ""
  echo "Options:"
  echo "  -a component version      Apply a specific version to a component"
  echo "  -r component              Reset a specific component with default channel"
  echo ""
  echo "Example:"
  echo "  $(basename "$0") -a upm-api-admin branch"
  echo "  $(basename "$0") -a upm-api-admin v1.2.3"
  echo "  $(basename "$0") -r upm-api-admin"
  echo ""
  exit 1;
}

check_commands() {
  for cmd in "$@"; do
    check_command "$cmd"
  done
}

check_command() {
  local command=$1
  if ! command -v "$command" &> /dev/null; then
    echo -e "\033[1;31mERROR: command '$command' is required, please install it.\033[0m"
    exit 1
  fi
}

function update_ks() {
  local component=$1
  local branch=$2
  # shellcheck disable=SC2016
  kubectl get kustomizations.kustomize.toolkit.fluxcd.io -n flux-system -o json "${component}" | \
    jq --arg branch "${branch}" '.metadata.labels."kustomize.toolkit.fluxcd.io/reconcile" = "disabled" | .spec.path |= (split("/") | .[0:3] + [$branch] + .[4:6]) | .spec.path |= join("/")' | \
    kubectl replace  -f -
  flux reconcile kustomization "${component}" --with-source
}

function reset_ks() {
  local component=$1
  # remove label: kustomize.toolkit.fluxcd.io/reconcile 
  kubectl label kustomizations.kustomize.toolkit.fluxcd.io -n flux-system "${component}" \
    kustomize.toolkit.fluxcd.io/reconcile-
  # get bootstrap kustomization name
  bootstrap_kustomization=$(kubectl get kustomizations.kustomize.toolkit.fluxcd.io -n flux-system -o json "${component}" | \
    jq -r '.metadata.labels."kustomize.toolkit.fluxcd.io/name"')
  # reconcile kustomization
  flux reconcile kustomization "${bootstrap_kustomization}"
}

check_commands flux jq

while getopts "har" o; do
  case "${o}" in
    a)
      shift || true
      update_ks "$@"
      exit
      ;;
    r)
      shift || true
      reset_ks "$@"
      exit
      ;;
    *)
  esac
done

usage
