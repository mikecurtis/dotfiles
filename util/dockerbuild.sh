#!/bin/bash

set -ex

cd $(dirname $0)/..

USERNAME=${1:-$(whoami)}

docker build --build-arg USERNAME=${USERNAME} -t dotfiles:latest util/
