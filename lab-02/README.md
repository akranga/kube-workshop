# Lab 2: Schedulling container execution

### Run microservice with Kubernetes

Now let's run our Chuck Norris app as part of kubernetes

Before we start, let's do sanity check
```
$ kubectl get nodes
NAME        LABELS                             STATUS
127.0.0.1   kubernetes.io/hostname=127.0.0.1   Ready
```

Now we are ready to start our Chuck:
```
$ kubectl run chuck --image=akranga/chucknorris --port=8080

CONTROLLER   CONTAINER(S)   IMAGE(S)              SELECTOR    REPLICAS
chuck        chuck          akranga/chucknorris   run=chuck   1

$ kubectl get pods
NAME                   READY     STATUS    RESTARTS   AGE
chuck-bbbj5            1/1       Running   0          3m
```

Next step is to expose our Chuck norris to the world
```
$ kubectl expose rc chuck --container-port=8080 --port=8000

NAME      LABELS      SELECTOR    IP(S)     PORT(S)
chuck     run=chuck   run=chuck             8000/TCP

$ kubectl describe service chuck

Name:			chuck
Labels:			run=chuck
Selector:		run=chuck
...
IP:			    10.0.0.93
Port:			<unnamed>	8080/TCP
Endpoints:		172.17.0.14:8080

$ curl 172.17.0.14:8080

Chuck Norris can solve the Towers of Hanoi in one move.
```

Next step is to scale our application to 5 replicas
```
$ kubectl scale --current-replicas=1 --replicas=3 rc chuck

scaled

$ kubectl get pods

NAME                   READY     STATUS    RESTARTS   AGE
chuck-2z97v            1/1       Running   0          30s
chuck-bbbj5            1/1       Running   0          16m
chuck-ow5s0            1/1       Running   0          30s

$ kubectl describe service chuck

Name:			chuck
...
Port:			<unnamed>	8080/TCP
Endpoints:		172.17.0.14:8080,172.17.0.15:8080,172.17.0.16:8080

$ kubectl delete rc chuck

replicationcontrollers/chuck

$ kubectl delete service chuck

services/chuck

### Write a pod file

Commands are good, however we can operate with kubernetes via files. This will give us possiblity to store our configuration in the SCM and make it part of our applicaiton. So it could evolve together.

Take a look in the file stores ```src/main/infra/*```. You will see RC and SCV yaml manifests. One goes to replicaiton controller declaration and another goes to Service.

To start you can run following command:
```
$ kubectl create -f src/main/infra/chucknorris-rc.yml

replicationcontrollers/chuck

$ kubectl create -f src/main/infra/chucknorris-svc.yml

services/chuck

$ kubectl describe service chuck
Name:			chuck
Namespace:		default
Labels:			name=chuck
Selector:		app=chuck,version=0.1.0
Type:			ClusterIP
IP:			10.0.0.97
Port:			<unnamed>	80/TCP
Endpoints:		172.17.0.2:8080

$ curl 172.17.0.2
"It works on my machine" always holds true for Chuck Norris.
```
### Externalize the Service 

Thgere is a number of ways how to chuck norris extgernally

You can call  ```http://localhost:8080/api/v1/proxy/namespaces/default/services/chuck/```

Then you should get something like the following: 
![alt text](https://raw.githubusercontent.com/akranga/kube-workshop/master/docs/chuck-browser.png "Chuck in your browser")
