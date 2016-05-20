# Lab 01 Proxy Containers


We have one micro-service based on Spring Boot and gradle
```
$ cd chucknorris
$ pwd

/home/core/kube-workshop/lab-01/chucknorris
```

## Activity 1: Compiling with Docker

ChuckNorris is a very simple Spring boot micro service with one controller. As the first step we will need to compile it.

But...
```
$ java -version
-bash: java: command not found
```

This is okay. There is no Java in the VM. We don't need Java to compile and build Java application :). We will use Java docker container to compile our app and produce distribution JAR file

For the first time we will do it manually:

Simply run command:
```
$ docker run --rm -i -t --volume=$(pwd):/app -w /app java:jdk bash
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

Let's do the same compilation as oneliner
```
$ docker run --rm -i -t --volume=$(pwd):/app -w /app java:jdk ./gradlew clean assemble

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

Total time: 17.534 secs
```

# Proxying groovy

Let's create a startup file that will be executable and will behave like a gradle however it will run a docker container inside.

Let's create a file. To do this we will need a "vi" editor. Don't get trapped, remember `:wq` or `:q!` to exit.

Enter following command:
```
$ vi ./gradle.sh
```
Then press `i` to insert symbols
```
#!/bin/bash -xe
docker run --rm -i -t --volume=$(pwd):/app -w /app java:jdk ./gradlew "$@"
```

Press `ESC` and `wq` to save and quit the vi. Let's validate that the file is actually with command `ls`. If you can see it then you can run `cat ./gradle.sh` to validate it's content

Now let's add some execution rights and run it 
```
chmod +x gradle.sh

./gralde.sh clean assemble 
```


# Building a Docker image

How about to compile and run it? This directory has a Dockerfile. Which where we will put our compiled JAR file and create a container image our of it. Once we have an image then we can run it

Run following command:
```
$ docker build -t akranga/chucknorris .

Sending build context to Docker daemon 37.28 MB
Step 0 : FROM java:jdk
 ---> 7547e52aac4b
Step 1 : ENV APP_VERSION 0.1.0
 ---> Running in ac77614ee44a
...
Step 4 : ENTRYPOINT java -jar /app.jar
 ---> Running in 0991ddf114cf
 ---> c5c729af0559
Removing intermediate container 0991ddf114cf
Successfully built c5c729af0559

$ docker run -d -p 8000:8080 --name=chuck akranga/chucknorris
$ curl localhost:8000

Chuck Norris can read all encrypted data, because nothing can hide from Chuck Norris.
```

Now let's tear down our application
```
$ docker ps

CONTAINER ID        IMAGE                                       COMMAND             
865a6151d7ed        akranga/chucknorris                         "java -jar /app.jar"

$ docker stop 865a6151d7ed
$ docker rm 865a6151d7ed
```

# Removing Build Tools

We just built image `akranga/chucknorris` which is little bit bulky. We do not need JDK to run Spring boot. Instead JRE will be just enough.

Now let's update Docker file with `vi` editor.

Open file with 

```
$ vi Dockerfile
```

Now press `i` to enter interactive mode. and replace `FROM java:jdk` with `FROM java:jre`

press 
```
:wq
# to safe and exit file. To validate succressful change 

$ cat Dockerfile
FROM java:jre

ENV APP_VERSION 0.1.0

COPY build/libs/chnorr-$APP_VERSION.jar /app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "/app.jar"]
```

Let's build image again. Feel the diference
```
$ docker build -t akranga/chucknorris .
$ docker images

```

Our image is now almos 300MB slimmer. Let's schedule it with Kubernetes. Go to `lab-02`