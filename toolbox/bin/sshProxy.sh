#!/bin/bash

## This tools is used to open a private reversed proxy from remote machine to local machine
## then local machine can use 4444 as port to jump through remote machine

port=4444
remote_ip=xxxx
private_key=~/.ssh/alissh.pem
nohup ssh -i $private_key -CNnfD :$port root@$remote_ip > ./proxy.out 2>./proxy.err < /dev/null &
