# Kubernetes

Список чтения
 * https://www.digitalocean.com/community/tutorials/an-introduction-to-kubernetes
 * http://kubernetes.io/docs/getting-started-guides/kubeadm/
 * https://github.com/kubernetes/kubernetes/issues/34101
 * https://blog.openshift.com/building-kubernetes-bringing-google-scale-container-orchestration-to-the-enterprise/
 * https://research.google.com/pubs/pub43438.html
 

Поднимаем наш кластер:
```
$ vagrant up
```

Появление в логе ошибки вида:
```
==> master: mesg:
==> master: ttyname failed
==> master: :
==> master: Inappropriate ioctl for device
==> master: OK
```
Это нормально, так и должно быть.


## Инициализация кластера

1) Основная инициализация
```
$ vagrant ssh master
$ sudo su -
# kubeadm init --api-advertise-addresses=192.168.50.2
```

Инициализация - долгая процедура, качает кучу докер образов
но в итоге выдает токен и ip адрес для подключения для 
slave нод:

Пример запуска команды:
```
root@master:~# kubeadm init --api-advertise-addresses=192.168.50.2
<master/tokens> generated token: "60998a.9d910d1359285a3f"
<master/pki> created keys and certificates in "/etc/kubernetes/pki"
<util/kubeconfig> created "/etc/kubernetes/admin.conf"
<util/kubeconfig> created "/etc/kubernetes/kubelet.conf"
<master/apiclient> created API client configuration
<master/apiclient> created API client, waiting for the control plane to become ready
<master/apiclient> all control plane components are healthy after 42.879415 seconds
<master/apiclient> waiting for at least one node to register and become ready
<master/apiclient> first node is ready after 6.007718 seconds
<master/discovery> created essential addon: kube-discovery, waiting for it to become ready
<master/discovery> kube-discovery is ready after 27.506506 seconds
<master/addons> created essential addon: kube-proxy
<master/addons> created essential addon: kube-dns

Kubernetes master initialised successfully!

You can now join any number of machines by running the following on each node:

kubeadm join --token 60998a.9d910d1359285a3f 192.168.50.2
```

2) Vagrant tune - запустить `vagrant-kubernetes-tune.sh`
```
# cd /vagrant
# ./vagrant-kubernetes-tune.sh
```

Если что-то пошло не так, чтобы начать все с начала, необходимо 
выполнить на каждой ноде:
```
$ cd /vagrant
$ sudo ./vagrant-kubernetes-clean.sh
```


## Подключаем slave1 и slave2
В новом терминале (для машин slave1 и slave2),
вместо команды `kubeadm join --token 1e55bc.eb74aea68d5225d1 192.168.50.2`
подставить значение полученное на шаге `kubeadm init`:
```
$ vagrant ssh slaveX
$ sudo su -
# kubeadm join --token ed9add.0e789e91c18e731c 192.168.50.2
...
```

Пример запуска команды:
```
root@slave1:~# kubeadm join --token 60998a.9d910d1359285a3f 192.168.50.2
<util/tokens> validating provided token
<node/discovery> created cluster info discovery client, requesting info from "http://192.168.50.2:9898/cluster-info/v1/?token-id=60998a"
<node/discovery> cluster info object received, verifying signature using given token
<node/discovery> cluster info signature and contents are valid, will use API endpoints [https://192.168.50.2:443]
<node/csr> created API client to obtain unique certificate for this node, generating keys and certificate signing request
<node/csr> received signed certificate from the API server, generating kubelet configuration
<util/kubeconfig> created "/etc/kubernetes/kubelet.conf"

Node join complete:
* Certificate signing request sent to master and response
  received.
* Kubelet informed of new secure connection details.

Run 'kubectl get nodes' on the master to see this machine join.
```

## Завершение инициализации кластера

Убеждаемся что slave подключены к master
```
# kubectl get nodes
```

Пример запуска команды:
```
root@master:~# kubectl get nodes
NAME      STATUS    AGE
master    Ready     2m
slave1    Ready     56s
slave2    Ready     32s
```

Подключаем Weave Net (сетевой стек для контейнеров):
```
# kubectl apply -f https://git.io/weave-kube
```

Пример вызова команды:
```
root@master:~# kubectl apply -f https://git.io/weave-kube
daemonset "weave-net" created
```

Загрузка и запуск образов занимает какое-то время, поэтому 
необходимо подождать несколько минут.


Убеждаемся что кластер функционирует:
```
# kubectl get pods --all-namespaces
```

```
root@master:~# kubectl get pods --all-namespaces
NAMESPACE     NAME                             READY     STATUS    RESTARTS   AGE
kube-system   etcd-master                      1/1       Running   0          7m
kube-system   kube-apiserver-master            1/1       Running   1          4m
kube-system   kube-controller-manager-master   1/1       Running   0          7m
kube-system   kube-discovery-982812725-ukbaj   1/1       Running   0          7m
kube-system   kube-dns-2247936740-dehju        2/3       Running   0          7m
kube-system   kube-proxy-amd64-blwb7           1/1       Running   0          4m
kube-system   kube-proxy-amd64-n8hk9           1/1       Running   0          1m
kube-system   kube-proxy-amd64-yv2q7           1/1       Running   0          1m
kube-system   kube-scheduler-master            1/1       Running   0          7m
kube-system   weave-net-3h3r0                  2/2       Running   0          48s
kube-system   weave-net-3r7lq                  2/2       Running   0          48s
kube-system   weave-net-kgbb0                  2/2       Running   0          48s
```

## Административный интерфейс

```
$ vagrant ssh master
$ sudo su -
# kubectl create -f https://rawgit.com/kubernetes/dashboard/master/src/deploy/kubernetes-dashboard.yaml
```

Доступ
```
$ vagrant ssh master
$ sudo su -
# kubectl proxy --accept-hosts='.*' --address='192.168.50.2' --port=9090
```

И бразуером перейти на http://192.168.50.2:9090/ui/

## Docker Registry

Для тестирования приложения из `sample/hello-world`, необходимо установить локальный
Docker Registry. Описание приложения в `sample/hello-world/README.md`

Установка Registry:
```
$ vagrant ssh master
$ cd /vagrant
$ sudo ./vagrant-setup-registry.sh
```

## Логи

### Для пользовательского namespace

```
$ kubectl get pods
NAME                                     READY     STATUS    RESTARTS   AGE
hello-world-deployment-863226332-9si7n   1/1       Running   0          11h
hello-world-deployment-863226332-pgfbf   1/1       Running   1          11h
```

```
$ kubectl logs hello-world-deployment-863226332-9si7n
....
....
```

### Для системного namespace, 

Необходимо передать ключ `-n kube-system`. Посколку один pod может содержать 
более одного запущенного контейнера, в таких случаях необходимо передать 
ключ `-c <container_name>`.

Пример:
```
$ kubectl get pods -n kube-system
NAME                                    READY     STATUS    RESTARTS   AGE
etcd-master                             1/1       Running   0          17h
heapster-2193675300-ow8nf               1/1       Running   1          10h
kube-apiserver-master                   1/1       Running   1          17h
kube-controller-manager-master          1/1       Running   0          17h
kube-discovery-982812725-60eoz          1/1       Running   0          17h
kube-dns-2247936740-s3hrm               3/3       Running   0          17h
kube-proxy-amd64-jjat4                  1/1       Running   0          17h
kube-proxy-amd64-jur2c                  1/1       Running   0          17h
kube-proxy-amd64-oda80                  1/1       Running   1          17h
kube-scheduler-master                   1/1       Running   0          17h
kubernetes-dashboard-1655269645-338mr   1/1       Running   1          17h
monitoring-grafana-927606581-yg6of      1/1       Running   1          10h
monitoring-influxdb-3276295126-kl8h2    1/1       Running   1          10h
weave-net-9nyoz                         2/2       Running   0          17h
weave-net-adpds                         2/2       Running   0          17h
weave-net-q76fe                         2/2       Running   3          17h

$ kubectl logs kube-dns-2247936740-s3hrm -n kube-system
Error from server: a container name must be specified for pod kube-dns-2247936740-s3hrm, choose one of: [kube-dns dnsmasq healthz]

$ kubectl logs kube-dns-2247936740-s3hrm -n kube-system -c kube-dns
I1021 15:16:49.059599       1 server.go:94] Using https://100.64.0.1:443 for kubernetes master, kubernetes API: <nil>
....
....
```
