#!/bin/bash

## the token is exported in ~/.bashrc

echo "login docker"
echo $CS_TOKEN | docker login docker.enterprisedb.com -u tao-li --password-stdin
echo "login ghcr"
echo $CR_TOKEN | docker login https://ghcr.io/v2 -u litaocdl --password-stdin
echo "login quay"
echo $QUAY_TOKEN |  docker login quay.io -u tao_li --password-stdin
