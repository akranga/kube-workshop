# Kubernetes workshop

This workshop guides through Google Kubernetes, Docker and Jenkins CI

## Activity 0: Setup Kubernetes

Setup and teardown scripts has been placed into ```cluster/kube-up.sh``` and ```cluster/kube-down.sh``` directories correspondingly

To start kubernetes just run following command:
```
$ bash cluster/kube-up.sh
$ kubectl config set-cluster http://localhost:8080
```

To check instalation run:
```
$ kubectl get nodes

NAME        LABELS                             STATUS
127.0.0.1   kubernetes.io/hostname=127.0.0.1   Ready
```

Next step is to clone our micro service
```
$ git clone https://github.com/akranga/chucknorris.git
cd chucknorris
```

## Activity 1: Compiling with Docker

ChuckNorris is a Spring boot micro service with one controller. As the first step we will need to compile it

However our environmetn is not ready. We simply (I don't) do not have Java Development Kit of right version. We will use Java docker container to compile our app and produce distribution JAR file

For the first time we will do it manually:

Simply run command:
```
$ docker run --rm -i -t --volume=$(pwd):/app -w /app java:jdk bas
```

This will download Docker container with latest Open JDK (8); mount current directory and let you inside

Now we can run compilation with gradle
```
root@477c94708216:/app$ ./gradlew assemble

:processResources
:classes
:jar
:findMainClass
:startScripts
:distTar
:distZip
:bootRepackage
:assemble

BUILD SUCCESSFUL

Total time: 19.007 secs
```

Now you can exit container and take a look at the compilation result

```
root@477c94708216:/app# exit
$ ls build/libs/
chnorr-0.1.0.jar
```
