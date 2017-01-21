# Lab 2: Schedulling container execution

## Prerequisites

Go to the lab-02 directory.
```
$ cd ~/kube-workshop/lab-02/
~/kube-workshop/lab-02 $ pwd
/home/core/kube-workshop/lab-02
```

Now let's run our Chuck Norris app as part of kubernetes

Before we start, let's do sanity check
```
$ kubectl get nodes
NAME        LABELS                             STATUS
127.0.0.1   kubernetes.io/hostname=127.0.0.1   Ready
```

## It is time to open Kubernets Dashboard

Dashboard is the Kubernetes web console that helps you navigate through the different pods. Open your browser and go to the:
https://YOUR-IP-ADDRESS/api/v1/proxy/namespaces/kube-system/services/kubernetes-dashboard

Don't forget to put `https` in the URL because current VM is listenring port 443 (https) only and not 80 (http)

You will get a security warning. This is okay and you can ignore it. We are using self-signed certificates there (hi Let's encrypt project :) ). 

When you will be prompted for username and password please enter the following:
```
User:     gdg
Password: riga17
```

Now you should be able to enter the dashboard

1. We shall first start with the pod. Click "Pods" on the main menu left
2. Now select (+) symol on the top right (see screenshot)

![Dashboard](../docs/dashboard1.png)

3. Fill following params:
    - Specify app details below [`checked`]
    - App Name: `chuck-norris-pod`
    - Container image: `akranga/chucknorris`
    - Number of pods: `1`
    - Service: `None`

4. (Optional): you can inspect advanced options but we don't need them now
5. Click `DEPLOY` button

After a while you should be able to see somehting like on the screen below:

![Dashboard](../docs/dashboard2.png)

What just happened. Kubernetes deployed few things:
1. *POD* with our application container
2. *ReplicaSet* with 1 replica of the pod
3. And created a *Deployment*. 
 
Which is higher level ablstraction several kubernetes resources tightly related to each other (like above, POD is pretty much useless without ReplicaSet). Deployment is handy when you will want to roll back all resources in a single shot

![Dashboard](../docs/dashboard3.png)

You can also check the logs for the container. 

![Dashboard](../docs/dashboard4.png)

Kubernetes collects all logs from the pods and metrics.

You can also export POD definition as YAML file:

![Dashboard](../docs/dashboard5.png)


You will also notice that Kubernetes tagged your pod with some labels. Labels are important, it allow different kubernetes resources to lookup each other. For example POD and ReplicaSet has been linked by labels. You can have multiple PODs of the same container. They needs to differently labeled to allow ReplicaSets to work with them correspondingly

## ReplicaSet 

This is an evolution of *Replication Controller*. It behaves more or less like an autoscaling group that you can find in public cloud provider.

Now let's check how does it works.

Return to the Terminal console (CLI) and run command:
```
$ docker ps | grep akranga/chucknorris

b56f8dd98ec7        akranga/chucknorris                                          "java -jar /app.jar"     19 minutes ago      Up 19 minutes                           k8s_chuck-norris.bfdf57f0_chuck-norris-4098746947-qx8xx_default_4d761032-df88-11e6-87de-12810cc5ac56_858a9cb3

```

Let's kill this container
```
$ docker kill b56f8dd98ec7
b56f8dd98ec7
```

If we will come back to the Kubernetes UI we will see that Kubernetes detected a container failure and restarted it. 

![Dashboard](../docs/dashboard6.png)

Now let's do something similar to from the CLI

## Getting things dirty

Open the CLI. Kubernetes can be operated by `kubectl` tool. Let's check what we have got here:
```
$ kubectl get nodes

NAME                        STATUS    AGE
ip-10-0-0-56.ec2.internal   Ready     1h
```

It shows that we have 1 VM in our cluster. This command is handy to check if cluster is up and running.

Now let's check for the pods.
```
$ kubectl get pods
NAME                            READY     STATUS    RESTARTS   AGE
chuck-norris-4098746947-qx8xx   1/1       Running   1          35m
```

We see our pod is running. Tocheck it's logs we can do:
```
$ kubectl logs chuck-norris-4098746947-qx8xx

  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/
 :: Spring Boot ::        (v1.2.6.RELEASE)
....
```

If you want to connect to the pod. You can run following command:

```
$ kubectl exec -i -t chuck-norris-4098746947-qx8xx bash
root@chuck-norris-4098746947-qx8xx:/# ls -al
total 12628
drwxr-xr-x.   1 root root     4096 Jan 21 03:41 .
drwxr-xr-x.   1 root root     4096 Jan 21 03:41 ..
-rwxr-xr-x.   1 root root        0 Jan 21 03:41 .dockerenv
-rw-r--r--.   3 root root 12771390 Oct  9  2015 app.jar
...
```

Yes you are inside of the container. You can run command `env` to check the variables.
```
root@chuck-norris-4098746947-qx8xx:/# env
HOSTNAME=chuck-norris-4098746947-qx8xx
KUBERNETES_PORT=tcp://10.3.0.1:443
KUBERNETES_PORT_443_TCP_PORT=443
KUBERNETES_SERVICE_PORT=443
KUBERNETES_SERVICE_HOST=10.3.0.1
...
```

Containers can discover other pods by Environment Variables. This is not the only option, however simplies one. You see that can discover Kubernetes itself. Check out this funny command from INSIDE of the container:
```
root@chuck-norris-4098746947-qx8xx:/curl -k https://admin:secret@10.3.0.1:443/version

{
  "major": "1",
  "minor": "5",
  "gitVersion": "v1.5.2+coreos.1",
  "gitCommit": "3ed7d0f453a5517245d32a9c57c39b946e578821",
  "gitTreeState": "clean",
  "buildDate": "2017-01-18T01:43:45Z",
  "goVersion": "go1.7.4",
  "compiler": "gc",
  "platform": "linux/amd64"
}
```

Now let's exit this container
```
root@chuck-norris-4098746947-qx8xx:/# exit
```

## Schedulling a container wiht CLI

Now we are ready to start our Chuck:
```
$ kubectl run chuck2 --image=akranga/chucknorris --port=8080
deployment "chuck2" created

$ kubectl get pods
NAME                            READY     STATUS    RESTARTS   AGE
chuck-norris-4098746947-qx8xx   1/1       Running   1          55m
chuck2-1791737841-lf1gw         1/1       Running   0          8s
```

Let's probe the container
```
$ kubectl describe pod chuck2-1791737841-lf1gw
OR
$ kubectl describe pod $(kubectl get pods | awk '/^chuck/ { print $1; }')
Name:       chuck2-1791737841-lf1gw
Namespace:  default
Node:       ip-10-0-0-56.ec2.internal/10.0.0.56
Start Time: Sat, 21 Jan 2017 04:13:52 +0000
Labels:     pod-template-hash=1791737841
        run=chuck2
Status:     Running
IP:     172.17.0.6
...
```

Now we see the IP address and we also hit the port 8080.
```
$ curl 172.17.0.6:8080
Chuck Norris's first program was kill -9.
$ curl 172.17.0.6:8080
Chuck Norris can't test for equality because he has no equal.
```

It works!!! What else have we got there?

```
$ kubectl get replicaset
NAME                      DESIRED   CURRENT   READY     AGE
chuck-norris-4098746947   1         1         1         59m
chuck2-1791737841         1         1         1         4m
```

Let's scale it!

```
$ kubectl scale --current-replicas=1 --replicas=3 deployment/chuck2
deployment "chuck2" scaled

$ kubectl get pods
NAME                            READY     STATUS    RESTARTS   AGE
chuck-norris-4098746947-qx8xx   1/1       Running   1          1h
chuck2-1791737841-lf1gw         1/1       Running   0          6m
chuck2-1791737841-tpfwm         1/1       Running   0          32s
chuck2-1791737841-wdp9j         1/1       Running   0          32s
```


Next step is to expose our Chuck norris replicas as a single service
```
$ kubectl expose deployment chuck2 --port=80 --target-port=8080 --cluster-ip='10.3.0.128'
service "chuck2" exposed

$ kubectl describe service chuck2
Name:           chuck2
Namespace:      default
Labels:         run=chuck2
Selector:       run=chuck2
Type:           ClusterIP
IP:         10.3.0.128
Port:           <unset> 80/TCP
Endpoints:      172.17.0.6:8080,172.17.0.7:8080,172.17.0.8:8080
Session Affinity:   None
No events.

$ curl http://10.3.0.128

Chuck Norris can solve the Towers of Hanoi in one move.
```

## Cleaning up

```
$ kubectl delete service chuck2
service "chuck2" deleted

$ kubectl delete deployment chuck2
deployment "chuck2" deleted
services/chuck

$ kubectl delete deployment chuck-norris
deployment "chuck-norris" deleted

$ kubectl get pods
No resources found.
```

### Write a pod file

Commands are good, however we can operate with kubernetes via files. This will give us possiblity to store our configuration in the SCM and make it part of our applicaiton. So it could evolve together.

Create a service
```
$ vim chucknorris-svc.yml
```

put following content and save the file `:wq`
```yaml
apiVersion: v1
kind: Service
metadata:
  name: chuck
  labels:
    name: chuck
spec:
  clusterIP: 10.3.0.222
  ports:
  - port: 80
    protocol: "TCP"
    targetPort: 8080
  selector:
    app: chuck
    version: 0.1.0
```

Now run the command
```
kubectl create -f chucknorris-svc.yaml
$ kubectl describe service chuck
Name:           chuck
Namespace:      default
Labels:         name=chuck
Selector:       app=chuck,version=0.1.0
Type:           ClusterIP
IP:         10.3.0.222
Port:           <unset> 80/TCP
Endpoints:      
Session Affinity:   None
```

Let's create a pod
```
$ vim chucknorris-rc.yml
```

put following content and save the file `:wq`

```yaml
apiVersion: v1
kind: ReplicationController
metadata:
  name: chuck
  labels:
    name: chucknorris
spec:
  replicas: 1
  selector:
    app: chuck
    version: 0.1.0
  template:
    metadata:
      labels:
        app: chuck
        version: 0.1.0
    spec:
      containers:
      - name: chuck
        image: akranga/chucknorris
        imagePullPolicy: Never
        ports:
        - name: api
          containerPort: 8080
```

To start you can run following command:
```
$ kubectl create -f chucknorris-rc.yaml
replicationcontroller "chuck" created
```

### Externalize the Service 

Thgere is a number of ways how to chuck norris extgernally

You can call  `curl http://localhost:8080/api/v1/proxy/namespaces/default/services/chuck/`

Let's add a load balancer. Let's remove our chuck service for a while

```
$ kuberctl delete -f chucknorris-svc.yml

```

replace `clusterIP` line with `type: LoadBalancer` record to the file
```
vim chucknorris-svc.yml
# your serivce will look like this
```

```yaml
apiVersion: v1
kind: Service
metadata:
  name: chuck
  labels:
    name: chuck
spec:
  # clusterIP: 10.0.0.10
  type: LoadBalancer
  ports:
  - port: 80
    protocol: "TCP"
    targetPort: 8080
  selector:
    app: chuck
    version: 0.1.0

```

Then you should get something like the following: 
![alt text](https://raw.githubusercontent.com/akranga/kube-workshop/master/docs/chuck-browser.png "Chuck in your browser")

## cleaning up

```
$ kubectl delete -f chucknorris-svc.yml
$ kubectl delete -f chucknorris-rc.yml
```
