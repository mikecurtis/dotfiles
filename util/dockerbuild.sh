#!/bin/bash

cd $(dirname $0)/..

if [ $# -eq 0 ]; then
  USERNAME=$(whoami)
else
  USERNAME=$1
fi

docker build util/
