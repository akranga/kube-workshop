# Lab 01 Introduction to Kubernetes

## Prerequisites

We have demo application called Wordsmith, that produces sentences from from random words. The application consists of 3 microservices:

* db - a Postgres database which stores words
* words - a Java REST API which serves words read from the databases
* web - a Go web application which calls the API and builds words into sentences

[Kubernetes deployment manifest of the application](kube-deployment.yaml)

## Activity 1: Simple application deployment

1. Create a copy of [manifest](kube-deployment.yaml) file in your Web Terminal. (Use VIM, or download the file from Github using Curl [link](https://raw.githubusercontent.com/akranga/kube-workshop/master/v2/lab-01/kube-deployment.yaml))
2. Run
```
kubectl apply -f kube-deployment.yaml
```
3. Run 
```
╰─ kubectl get pods
NAME                     READY     STATUS    RESTARTS   AGE
db-79b64dd4bb-g5wqd      1/1       Running   0          1m
web-58d8d84784-zdxkb     1/1       Running   0          1m
words-6f8c8d68b9-gckqk   1/1       Running   0          1m
words-6f8c8d68b9-kf2x7   1/1       Running   0          1m
words-6f8c8d68b9-l2l92   1/1       Running   0          1m
words-6f8c8d68b9-ns6xp   1/1       Running   0          1m
words-6f8c8d68b9-thpm5   1/1       Running   0          1m
```

