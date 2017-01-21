# Getting started with Docker

Welcome! And let's start with docker.  Docker is the next level of virtualization. We say this is not VMs this is OS level virtualization. Beauty of docker is the ability to create a copy of container within seconds. 

You ar currenlty using Container native OS called CoreOS. It has docker daemon inside with few steroids that help docker with extra routines such as: networking, clustering etc.

CoreOS doesn't have a package  manager. So, you cannot install any software. You should use docker instead. With this activity we will try to use some basic dokcer routines such as: 
* Instantiate docker containers
* Build docker containers
* Use volumes with containers
* Link containers

## Hello world with Docker!

Let's start. Docker extremely friendly command line interface. However docker daemon can be optionally exposed as TCP socket to allow remote RESTful connections. We will not use remote connections today, but it is good to know about such possiblity.

Everything in docker is packaged as images. First action, you must downlaod docker image. You can do with the command: `docker pull hello-world`. Docker daemon will connect to the centralized docker repository and download image called hello-world.

You can run command: `docker images` to get list of available images. Naming convention for images is the following:
```
docker_registry/author/image_name:tag

* docker_registry: IP or hostname of registry where image can be donwloaded. If you skip this, then docker will use docker.io (centralized docker registry maintained by docker)
* author: or maintainer. This is typically authorized user in the registry who is owner of the image. If you skip it then docker will assume image author `library`. This is so called `trusted` images maintained by Docker it'self
* image_name: this is name of the image.
* tag: can be image version number, or anything else. If you skip. then docker will assume you use tag: latest
```

So, this is how 'docker pull hello-world' is equal to 'docker pull docker.io/library/hello-world:latest'

## Running an image

Before we start, let me show the command:

```
$ docker ps    # to see running containers
$ docker ps -a # to see all containers
```

Now let's run our docker image
```
$ docker run --rm hello-world
```

If you now run `docker ps` you will see nothing but if you run `docker ps -a` you will see an image that went to the state `Exited (0)`. Which means wihtout error

You can delete old container by capturing it's id (looks like hash). and putting as argument to command `docker rm ID or NAME` of the container.

When you run container you can give it a name: `docker run --name=hello hello-world`. Now you can refer container (even exite by name).

You can also run container in interactive mode. Let's do that.
```
docker pull ubuntu
docker run  --rm -i -t ubuntu
root@1871d8c98944:/$ apt-get update
root@1871d8c98944:/$ apt-get install apache2
root@1871d8c98944:/$ exit
```