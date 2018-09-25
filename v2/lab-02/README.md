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

1. Run ```docker login harbor.svc.<your-cluster-name>.workshop.base.image.acks.delivery``` The output should be:
2. Create a secret that contains credentials of your docker registry:
```kubectl create secret docker-registry harbor-<cluster-name> --docker-server=harbor.svc.<cluster-name>.workshop.base.stacks.delivery --docker-username=admin --docker-password=<your-password> --docker-email=<your-email>```

> Objects of type [secret](https://kubernetes.io/docs/concepts/configuration/secret/) are intended to hold sensitive information, such as passwords, OAuth tokens, and ssh keys. Putting this information in a secret is safer and more flexible than putting it verbatim in a pod definition or in a docker image.

3. Check that secret has been created using ```kubectl get secret harbor-<cluster-name> --output=json```. The output should be:
4. cd to k8s-wordsmith-demo directory and modify ```kube-deployment.yml``` file. Add ```imagePullSecrets``` to the ```specs``` section of each ```Deployment``` in order to use the secret we created in Step 2. Example:
```
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: db
  labels:
    app: words-db
spec:
  template:
    metadata:
      labels:
        app: words-db
    spec:
      containers:
      - name: db
        image: harbor.svc.viktor.workshop.base.stacks.delivery/workshop/db
        ports:
        - containerPort: 5432
          name: db
      imagePullSecrets:
      - name: harbor-viktor
```

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

