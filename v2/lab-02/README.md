# Lab 02 Cuztomized Appplication Deployment

## Introduction

In the second lab we are going to slightly modify our application. In order to do that we need to 
* do few modifications in the source code of the applications 
* build new docker images, that contain these changes
* push these images to a Docker registry
* deploy applications to Kubernetes

We are going to push images to a private docker registry (Harbor) and authorize Kubernetes cluster to pull images from this registry.

## Private Docker registry

Each workshop participant (ideally) have his own Harbor Docker registry running in his Kubernetes cluster. It must be available at ```https://harbor.svc.<your-cluster-name>.workshop.base.stacks.delivery```

## Modify the DB application

Let's make our application to build sentences from Latvian words instead of English words!
In order to do so we need to modify a SQL script that inserts data (words) to application's database.

1. cd to k8s-wordsmith-demo directory. It contains sources of 3 Docker images (2 application sources and the database) we deployed in the first lab. 
2. cd to k8s-wordsmith-demo/db
3. The directory contains [words.sql](k8s-wordsmith-demo/db/words.sql) that is executed when the database container gets bootstrapped
