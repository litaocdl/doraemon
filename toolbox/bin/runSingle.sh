#!/usr/bin/env bash
## --skip-file
export TEST_DEPTH=${TEST_DEPTH:-4}
HOME=${HOME:-CNP}
#export file="(upgrade_test).*"
if [[ -n $1 ]]; then
   file=$1
else
   file="cluster_setup_test"
fi
export file
ginkgo --nodes=1 --timeout=2h --slow-spec-threshold=5m   --focus-file="$file" -v --trace "${HOME}/tests/e2e/..."   #PRESERVE_NAMESPACES=xxx
echo $?