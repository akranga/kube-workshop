# Lab 02 Cuztomized application deployment

## Introduction

In the second lab we are going to slightly modify our application. In order to do that we need to 
* do few modifications in the source code of the applications, 
* build new docker images, that contain these changes,
* push these images to a Docker registry
* deploy applications to Kubernetes

We are going to push images to a private docker registry (Harbor) and authorize Kubernetes cluster to pull images from this registry. 

## Modify the DB application


