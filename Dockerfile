FROM busybox
EXPOSE 4000 4001
ADD etcd etcd
ADD etcdctl etcdctl
CMD /bin/sh
