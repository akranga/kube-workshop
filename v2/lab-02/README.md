# Lab 02 Cuztomized Appplication Deployment

## Introduction

In the second lab we are going to slightly modify our application. In order to do that we need to 
* do few modifications in the source code of the applications 
* build new docker images, that contain these changes
* push these images to a Docker registry
* deploy applications to Kubernetes

We are going to push images to a private docker registry (Harbor) and authorize Kubernetes cluster to pull images from this registry.

## Private Docker registry

Each workshop participant (ideally) have his own Harbor Docker registry running in his Kubernetes cluster (backed by AWS S3 storage). It must be available at ```https://harbor.svc.<your-cluster-name>.workshop.base.stacks.delivery```. Let's try to log into the registry and configure our Kubernetes to pull images from the registry.

1. Run ```docker login harbor.svc.<your-cluster-name>.workshop.base.stObjects of type secret are intended to hold sensitive information, such as passwords, OAuth tokens, and ssh keys. Putting this information in a secret is safer and more flexible than putting it verbatim in a pod definition or in a docker image.acks.delivery```. The output should be:
2. Create a secret that contains credentials of your docker registry:
```kubectl create secret docker-registry harbor-<cluster-name> --docker-server=harbor.svc.<cluster-name>.workshop.base.stacks.delivery --docker-username=admin --docker-password=<your-password> --docker-email=<your-email>```

> Objects of type [secret](https://kubernetes.io/docs/concepts/configuration/secret/) are intended to hold sensitive information, such as passwords, OAuth tokens, and ssh keys. Putting this information in a secret is safer and more flexible than putting it verbatim in a pod definition or in a docker image.

## Modify the DB application

Let's make our application to build sentences from Latvian words instead of English words!
In order to do so we need to modify a SQL script that inserts data (words) to application's database.

1. cd to k8s-wordsmith-demo directory. It contains sources of 3 Docker images (2 application sources and the database) we deployed in the first lab. 
2. cd to k8s-wordsmith-demo/db
3. The directory contains [words.sql](k8s-wordsmith-demo/db/words.sql) that is executed when the database container gets bootstrapped:
```
CREATE TABLE nouns (word TEXT NOT NULL);
CREATE TABLE verbs (word TEXT NOT NULL);
CREATE TABLE adjectives (word TEXT NOT NULL);

INSERT INTO nouns(word) VALUES
  ('dators'),
  ('koks'),
  ('zīmulis'),
  ('ūdens'),
  ('cilvēks'),
  ('pele');

INSERT INTO verbs(word) VALUES
  ('lieto'),
  ('skaitļo'),
  ('aug'),
  ('raksta'),
  ('ir'),
  ('ēd');

INSERT INTO adjectives(word) VALUES
  ('akls'),
  ('dzidrs'),
  ('centīgs'),
  ('ciets'),
  ('vecs');
```

