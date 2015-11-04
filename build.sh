#!/usr/bin/env bash

set -x

docker build -t unmerged/etcd -f Dockerfile .
