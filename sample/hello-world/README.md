# Тестовое приложение

Node.JS echo-сервер.

## Собираем приложение
```
# ./build.sh [build-number]
```

где, build-number - любое число. Если не указано, используется значение 1.

Результатом сборки будет Docker image со следующими тэгами

 * hello-world:<build-number> 
 * 192.168.50.2:5000/sample/hello-world:<build-number>

Тэг `192.168.50.2:5000/sample/hello-world:<build-number>` будет отправлен в Registry.

## Первоначальная публикация приложения

`kubectl create -f ./app.manifest.yml`

## Доступ к приложению

http://192.168.50.2:3000/

## Подключение к pod приложения

```
# kubectl get pods
NAME                                     READY     STATUS    RESTARTS   AGE
hello-world-deployment-700434906-5kfkm   1/1       Running   0          7m
hello-world-deployment-700434906-ocxim   1/1       Running   0          8m

# kubectl exec -ti hello-world-deployment-700434906-5kfkm /bin/sh
# uname -a
Linux hello-world-deployment-700434906-5kfkm 4.4.0-45-generic #66-Ubuntu SMP Wed Oct 19 14:12:37 UTC 2016 x86_64 GNU/Linux
# ps uax
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  2.7 907548 27736 ?        Ssl  05:08   0:08 node /app/index.js
root        12  0.0  0.0   4336   712 ?        Ss   08:32   0:00 /bin/sh
root        22  0.0  0.1  17500  1996 ?        R+   08:33   0:00 ps uax
#
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

## Удаление приложения

`kubectl delete pod,service,deployment -l app=hello-world`
