#!/bin/bash

set -ex

cd $(dirname $0)/..

USERNAME=${1:-$(whoami)}

docker build -f util/Dockerfile --build-arg USERNAME=${USERNAME} -t dotfiles:latest
