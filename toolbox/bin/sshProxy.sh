port=4444
nohup ssh -i ~/.ssh/alissh.pem -CNnfD :$port root@47.88.33.240 > ./proxy.out 2>./proxy.err < /dev/null &
