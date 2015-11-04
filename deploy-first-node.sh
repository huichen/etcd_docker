#!/usr/bin/env bash

host=$1
[[ -z  $host  ]] && echo "missing parameter: host" && exit

nodename="node$RANDOM"

container=`docker run -dt -P -p ${host}::4000 -p ${host}::4001 --name etcd_${nodename} unmerged/etcd`
[[ -z  $container  ]] && echo "can't start container" && exit

portpeer=`docker port $container 4000 | cut -d':' -f2`
[[ -z  $portpeer  ]] && echo "can't get peer port on host" && exit

portclient=`docker port $container 4001 | cut -d':' -f2`
[[ -z  $portclient  ]] && echo "can't get client port on host" && exit

containerip=`docker exec $container /bin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
[[ -z  $containerip  ]] && echo "can't get container ip" && exit

docker exec -d $container /etcd --listen-peer-urls "http://$containerip:4000" --listen-client-urls "http://$containerip:4001" --initial-advertise-peer-urls "http://$host:$portpeer" --initial-cluster "$nodename=http://$host:$portpeer" --advertise-client-urls "http://$host:$portclient" --initial-cluster-state=new  --name=$nodename

echo "Your etcd cluster's endpoint is"
echo "$host:$portclient"
