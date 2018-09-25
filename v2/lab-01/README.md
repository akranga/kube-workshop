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


