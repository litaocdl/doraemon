#!/bin/bash

if [ "$1" == "no" ]; then
  go env -w GOPROXY="https://proxy.golang.org,direct"
  go env -w GOSUMDB="sum.golang.org"
elif [ "$1" == "yes" ]; then
  go env -w GOPROXY="https://goproxy.cn,https://goproxy.io,direct"
  go env -w GOSUMDB="sum.golang.google.cn"
else
  echo "goproxy.sh yes|no"
fi
