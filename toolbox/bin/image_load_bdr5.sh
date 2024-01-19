## bdr
k8s=$(kind get clusters | sort -r | head -n1)
declare -a imageArray
imageArray[0]="docker.enterprisedb.com/temporary-pgd-images/edb-pgd-proxy:0.0.1-59-3af8858-dev-8.6-5"
imageArray[1]="docker.enterprisedb.com/temporary-pgd-images/postgresql-bdr:14.5-5.0.0-1"
imageArray[2]="docker.enterprisedb.com/temporary-pgd-images/postgresql-advanced-bdr:14.5.0-5.0.0-1"
imageArray[3]="docker.enterprisedb.com/temporary-pgd-images/postgresql-extended-bdr:14.5.0-5.0.0-2"
imageArray[4]="ghcr.io/open-telemetry/opentelemetry-collector-releases/opentelemetry-collector-contrib:0.56.0"

for i in "${imageArray[@]}";
do
  image="$i"
  docker pull $image
done

for i in "${imageArray[@]}";
do 
  image="$i"
  kind load docker-image $image --name $k8s
done


