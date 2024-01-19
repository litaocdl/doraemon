#!/usr/bin/bash

## Get the number of data-collector rule used in cnp e2e test
c=$(az monitor data-collection rule list --subscription "Cloud Native Development" --resource-group cloud-native-e2e -o json | jq ".[].name" | grep "cnp-test" | wc -l)
echo "$c"

## clean it 
az monitor data-collection rule list --resource-group cloud-native-e2e -o json | jq ".[].name"  | grep "cnp-test" | xargs -0 -I {} az monitor data-collection rule delete -y --name {} --verbose --resource-group cloud-native-e2e --subscription "Cloud Native Development"

c=$(az monitor data-collection rule list --subscription "Cloud Native Developmen    t" --resource-group cloud-native-e2e -o json | jq ".[].name" | grep "cnp-test" |     wc -l)
echo "$c"
