# Lab 01 Introduction to Kubernetes

## Prerequisites

We have demo application called Wordsmith, that produces sentences from from random words. The application consists of 3 microservices:

* db - a Postgres database which stores words
* words - a Java REST API which serves words read from the databases
* web - a Go web application which calls the API and builds words into sentences

[Kubernetes deployment manifest of the application](kube-deployment.yaml)
