# Activity 3: Starting Jenkins Master

Instead of building the applications we will build container with application inside and then schedule it for Kubernetes.

For nice CI/CD experience we will need. 

```
- Private Docker Registy: To store containers that we are building. Private registry should be in the same network. This will reduce network latency for transferring containers
- Jenkins Master: This container will have Jenkins CI master with some nice plugins, including 'workflow' that allows you to write jenkins CD/CD job in Groovy DSL
- Jenkins java slave: Docker container that connects via swarm plugin to Jenkins master. It has JDK and other Java build tools 
- Jenkins docker slave: Acts after java app has beeen built and unit tested. It is building Docker image out of it. WARNING: requires priviledged mode 
- Jenkins kubernetes slave: interacts with kuberneetes instance to run container as kubernetes service
```

## Creating Jenkins Master

Jenkins Master replication controller and service availale here:

```
$ kubectl create -f jenkins-master-rc.yml

replicationcontrollers/jenkins

$ kubectl create -f jenkins-master-svc.yml

services/jenkins
```

It will take few minutes for Jenkins to warm up... Be patient! You can check status by executing ```$ kubectl get pods```

Once it is running you should be able to connect by mapping ports from remote host to local via SSH (if you running remote host in the cloud)

To do so, you need to capture IP and ports by executing following command:

```
$ kubectl describe service jenkins

Name:			jenkins
...
Port:			web	80/TCP
Endpoints:		172.17.0.2:8080
Port:			web8080	8080/TCP
Endpoints:		172.17.0.2:8080
Port:			swarm	50000/TCP
Endpoints:		172.17.0.2:50000
```