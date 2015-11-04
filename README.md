## Build etcd docker image

    ./build.sh

or get the image with following command (don't run yet)

    docker pull unmerged/etcd

## Deploy an etcd cluster with the docker image

1. Deploy the first etcd peer

  ```
  ./deploy-first-node.sh <ip of the host>
  ```
  
  The host is the machine you want to deploy the first peer on. Notice the ip must be accessable by other peers.

  At the end of a successful running, the first peer's client url will be shown. Write it down since you will need it in the second step.

2. Deploy following peers with

  ```
  ./deploy-following-node.sh <ip:port as the first peer's CLIENT URL> <ip of this peer's host>
  ```
  
  Upon a successful running, this peer's client url will be shown at the end. You can repeat step 2 to deploy as many peers as possible in the cluster. BTW the first peer's client url in the command line above can be replaced by any peer's who's already in the cluster.

3. Test the cluster

  ```
  etcdctl --endpoint=<client urls> member list
  ```
