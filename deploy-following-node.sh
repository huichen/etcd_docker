#!/usr/bin/env bash

clients=$1
[[ -z  $clients  ]] && echo "missing first parameter: first node's client ip:port" && exit

host=$2
[[ -z  $host  ]] && echo "missing second parameter: host" && exit

nodename="node$RANDOM"

container=`docker run -dt -P -p ${host}::4000 -p ${host}::4001 --name etcd_${nodename} unmerged/etcd`
[[ -z  $container  ]] && echo "can't run container" && exit

portpeer=`docker port $container 4000 | cut -d':' -f2`
[[ -z  $portpeer  ]] && echo "can't get peer port" && exit

portclient=`docker port $container 4001 | cut -d':' -f2`
[[ -z  $portclient  ]] && echo "can't get client port" && exit

containerip=`docker exec $container /bin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
[[ -z  $containerip  ]] && echo "can't get container ip" && exit

cluster=`docker exec $container /etcdctl --endpoint=$clients member add $nodename "http://$host:$portpeer" | grep ETCD_INITIAL_CLUSTER= | cut -d'"' -f2`
[[ -z  $cluster  ]] && echo "can't add to cluster" && exit

docker exec -d $container /etcd --listen-peer-urls "http://$containerip:4000" --listen-client-urls "http://$containerip:4001" --initial-advertise-peer-urls "http://$host:$portpeer" --initial-cluster $cluster --advertise-client-urls "http://$host:$portclient" --initial-cluster-state=existing  --name=$nodename

echo "deployment is successful. your client endpoint is "
echo "$host:$portclient"
