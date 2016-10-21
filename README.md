# Kubernetes

Список чтения
 * https://www.digitalocean.com/community/tutorials/an-introduction-to-kubernetes
 * http://kubernetes.io/docs/getting-started-guides/kubeadm/
 * https://github.com/kubernetes/kubernetes/issues/34101
 * http://www.devoperandi.com/load-balancing-in-kubernetes/

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

Если что-то пошло не так, выполнить на каждой ноде:
```
$ cd /vagrant
$ sudo ./vagrant-kubernetes-clean.sh
```
И после этого можно начинать сначала.


## Подключаем slave1 и slave2
В новом терминале (для машин slave1 и slave2),
вместо команды `kubeadm join --token 1e55bc.eb74aea68d5225d1 192.168.50.2`
подставить значение полученное на предыдущем шаге:
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

Подключаем Weave Net:

```
# kubectl apply -f https://git.io/weave-kube
```

Пример вызова команды:
```
root@master:~# kubectl apply -f https://git.io/weave-kube
daemonset "weave-net" created
```

В зависимости от производительности сети, загрузка образов занимает какое-то
время, поэтому необходимо подождать несколько минут прежде чем кластер 
соберется.

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

## Логи

WIP.

## Админка

```
$ vagrant ssh master
$ sudo su -
# kubectl create -f https://rawgit.com/kubernetes/dashboard/master/src/deploy/kubernetes-dashboard.yaml
```

Для доступа к админке
```
$ vagrant ssh master
$ sudo su -
# kubectl proxy --accept-hosts='.*' --address='192.168.50.2' --port=9090
```

И бразуером перейти на http://192.168.50.2:9090/ui/

## Registry

На мастер ноде запустить:
```
$ cd /vagrant
$ sudo ./vagrant-setup-registry.sh
```

## Можно тестировать
