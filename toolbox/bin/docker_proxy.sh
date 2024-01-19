if [ '$1' == 'yes' ]; then
 export  HTTP_PROXY=http://127.0.0.1:10080/
 export  HTTPS_PROXY=https://127.0.0.1:10080/
else if [ '$1' == 'no']; then
 export HTTP_PROXY=
 export HTTPS_PROXY=
else 
    echo "docker_proxy.sh yes|no"
fi

