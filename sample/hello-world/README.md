# 

## Собираем приложение
```
# ./build.sh <build-number>
```

Скрипт сборки:
```
#!/usr/bin/env bash

VERSION=$1
if [ -z "${VERSION}" ]; then
    VERSION=1
fi

docker build -t hello-world:${VERSION} .
docker tag hello-world:${VERSION} 192.168.50.2:5000/sample/hello-world:${VERSION}
docker push 192.168.50.2:5000/sample/hello-world:${VERSION}
```

## Публикуем приложение
`kubectl create -f ./app.manifest.yml`

## Посмотреть на приложение

http://192.168.50.2:3000/

## Удаляем приложение
`kubectl delete pod,service,deployment -l app=hello-world`

## Подключение к pod-у (без ssh)
```
# kubectl get pods
NAME                                     READY     STATUS    RESTARTS   AGE
hello-world-deployment-700434906-5kfkm   1/1       Running   0          7m
hello-world-deployment-700434906-ocxim   1/1       Running   0          8m

# kubectl exec -ti hello-world-deployment-700434906-5kfkm /bin/sh
/ # cat /app/index.js
'use strict';

const http = require('http');

// Configure our HTTP server to respond with Hello World to all requests.
var server = http.createServer((request, response) => {
    response.writeHead(200, {"Content-Type": "text/plain"});
    response.end("Hello World\n");
});

server.listen(8000);
console.log("Server running at http://127.0.0.1:8000/");
/ #

```

## Выкатываем новую версию
```
# ./build.sh 2
# kubectl set image deployment/hello-world-deployment hello-world=192.168.50.2:5000/sample/hello-world:2
```

## Откатываем релиз

```
# kubectl rollout undo deployment/hello-world-deployment
```
