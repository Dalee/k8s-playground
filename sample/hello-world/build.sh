#!/usr/bin/env bash

VERSION=$1
if [ -z "${VERSION}" ]; then
    VERSION=1
fi

docker build -t hello-world:${VERSION} .
docker tag hello-world:${VERSION} 192.168.50.2:5000/sample/hello-world:${VERSION}
docker push 192.168.50.2:5000/sample/hello-world:${VERSION}
