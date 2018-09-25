# Lab 01 Introduction to Kubernetes

## Prerequisites

We have demo application called Wordsmith, that produces sentences from random words. The application consists of 3 microservices:

* db - a Postgres database which stores words
* words - a Java REST API which serves words read from the databases
* web - a Go web application which calls the API and builds words into sentences

[Kubernetes deployment manifest of the application](kube-deployment.yaml)

## Simple application deployment

1. Create a copy of [manifest](kube-deployment.yml) file in your Terminal. (Use VIM, or download the file from Github using Curl [link](https://raw.githubusercontent.com/akranga/kube-workshop/master/v2/lab-01/kube-deployment.yaml))
2. Run
```
kubectl apply -f kube-deployment.yaml
```
3. Run ```kubectl get pods``` and observe the result
```
╰─ kubectl get pods -o wide
NAME                     READY     STATUS    RESTARTS   AGE       IP          NODE
db-79b64dd4bb-fv4j4      1/1       Running   0          39m       10.2.1.31   ip-10-0-36-25.eu-west-1.compute.internal
web-58d8d84784-6kl4b     1/1       Running   0          39m       10.2.2.22   ip-10-0-34-172.eu-west-1.compute.internal
words-6f8c8d68b9-2xmdq   1/1       Running   0          39m       10.2.2.21   ip-10-0-34-172.eu-west-1.compute.internal
words-6f8c8d68b9-d5tpj   1/1       Running   0          39m       10.2.0.20   ip-10-0-44-3.eu-west-1.compute.internal
words-6f8c8d68b9-j2k6q   1/1       Running   0          39m       10.2.1.33   ip-10-0-36-25.eu-west-1.compute.internal
words-6f8c8d68b9-mhrr9   1/1       Running   0          39m       10.2.1.32   ip-10-0-36-25.eu-west-1.compute.internal
words-6f8c8d68b9-n6lk8   1/1       Running   0          39m       10.2.0.21   ip-10-0-44-3.eu-west-1.compute.internal
```
5 replicas of words microservice, 1 replica of web microservice and 1 replica of db service should be running.
All pods are exposed on an internal IP in the cluster. This type makes the pods only reachable from within the cluster.

> A [Pod](https://kubernetes.io/docs/concepts/workloads/pods/pod) is a group of one or more containers (such as Docker containers), with shared storage/network, and a specification for how to run the containers.

4. Run ```kubectl get services``` and observe the result
```
╰─ kubectl get services
NAME         TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
db           ClusterIP   10.3.206.118   <none>        5432/TCP   56m
web          ClusterIP   10.3.96.162    <none>        80/TCP     56m
words        ClusterIP   10.3.19.162    <none>        8080/TCP   56m
```
> A [Service](https://kubernetes.io/docs/concepts/services-networking/service) is an abstraction which defines a logical set of Pods and a policy by which to access them - sometimes called a micro-service. A service proxies and load balances requests across all replicas of a pod. Similar to pods, all services are exposed on an internal Cluster IP, unless it's headless service that does not need to be accessed.

5. Run ```kubectl get deployments``` and observe the result
```
╰─ kubectl get deployments
NAME      DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
db        1         1         1            1           1h
web       1         1         1            1           1h
words     5         5         5            5           1h
```
> A [Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment) describes desired state of a Service (how many pod replicas to spin up, etc.)

## Exposing the service
The application we deployed in the previous step has been available exclusively for cluster itself (and all pods deployed). We need to expose some of the services to the users.

There are multiple ways how to make applications available publicly:
* External load balancer, from Cloud provider (AWS, Microsoft Azure, etc.) or custom made
* Ingress via user facing reverse proxy server such as nginx or Traefik.
* NodePort - Exposes the Service on the same port of each selected node in the cluster using NAT. Makes a Service accessible from outside the cluster using <NodeIP>:<NodePort>.
  
Let's try to expose our application through Ingress via Traefik.

1. Create a copy of [manifest](kube-ingress.yml) file in your Terminal. (Use VIM, or download the file from Github using Curl [link](https://raw.githubusercontent.com/akranga/kube-workshop/master/v2/lab-01/kube-ingress.yml).
2. Update ```spec.rules.-host``` field in kube-ingress.yml file with fqdn of your cluster (example: wordsmith.app.devopsdays.kubernetes.delivery)
3. Run
```
kubectl apply -f kube-ingress.yml
```
4. Verify that your ingress has been successfully created:
```
╰─ kubectl get ingresses
NAME          HOSTS                                          ADDRESS   PORTS     AGE
web-ingress   wordsmith.app.<fqdn-of-your-cluster>                     80        20m
```
4. Open wordsmith.app.<fqdn-of-your-cluster> in a browser.
5. Observe home page of the application:
[Application](app.png)


