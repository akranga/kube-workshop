# Activiy 4: Operations with Persistent volumes

Here is the contract. Persistent volumes have been configured by Operator, while POD and RC are typically responsibility of the DEV. We need to put between persistent volume (PV) and POD an abstraction layer called in Kubernetes as Persistent Volume Claim. It will give possiblity to the PODs claim storage without knowing specifics storage provisioning details

Persistent volumes has been configuration can be executed by running command:
```
$ kubectl create -f jenkins-pv.yml
persistentvolumes/jenkins-data-vol1
persistentvolumes/jenkins-data-vol2
ubuntu@ip-172-31-8-2:~/kube-workshop$ kubectl get pv
NAME                LABELS                   CAPACITY      ACCESSMODES   STATUS      CLAIM     REASON
jenkins-data-vol1   name=jenkins-workspace   21474836480   RWO           Available
jenkins-data-vol2   name=jenkins-jobs        10737418240   RWO           Available
```

It marks local directories `/data/vol-01` and `/data/vol-02` as persistent volumes for Kubernetes pods. You can map it directly to pod, however it is more nice to map it via so called `Persistent Volume Claims (pvc)` that abstracts pods from concrete persistent volume implementations (hostDir, AWS EBS volume, nfs etc). Pod can request Persistent Volume from kubernetes by claiming it by capacity, read-write strategy etc.

Persistent volumes claims can be created by running following command:
```
$ kubectl create -f jenkins-pvc.yml

persistentvolumeclaims/jenkins-workspace
persistentvolumeclaims/jenkins-jobs

$ kubectl get pvc
NAME                LABELS    STATUS    VOLUME
jenkins-jobs        map[]     Bound     jenkins-data-vol2
jenkins-workspace   map[]     Bound     jenkins-data-vol1
```

You can see Claims has been bound to the Persistent Volumes

### Back to Jenkins

Now our goal is to run Jenkins POD with respect to storage. You need to stop RC and POD of "stateless" Jenkins and run with volumes.

```
$ kubectl stop -f jenkins-master-rc.yml
replicationcontrollers/jenkins

$ kubectl create -f jenkins-master-rc-with-volumes.yml
replicationcontrollers/jenkins

$ kubectl get pods
NAME                   READY     STATUS    RESTARTS   AGE
jenkins-mlmtm          1/1       Running   0          40s
```

Second POD file has one difference: it uses PVC
```yaml
spec:
    ...
    volumeMounts:
    - name: jenkins-workspace
      mountPath: /var/jenkins_home/workspace
      readOnly: false
    - name: jenkins-jobs
      mountPath: /var/jenkins_home/jobs
      readOnly: false
  volumes:
  - name: jenkins-jobs
    persistentVolumeClaim:
      claimName: jenkins-jobs
  - name: jenkins-workspace
    persistentVolumeClaim:
      claimName: jenkins-workspace
```

We have two volumes one to store Jenkins jobs and another to store workspaces. This is what we don't want to loose. Other Jenkins configuration (plugins, tools etc) needs to be baked inside of container.

### Add a simple Jenkins Workflow

Now let's create a simple job! Click to create Jobs link (as follows on the screenshot).
![alt text](https://raw.githubusercontent.com/akranga/kube-workshop/master/docs/jenkins-2.png "Jenkins CI")

Give a name to the new job: let's say: ```hello-chuck```. And select a type ```Workflow```
![alt text](https://raw.githubusercontent.com/akranga/kube-workshop/master/docs/jenkins-3.png "Jenkins CI")

Add following script:
```groovy

node("master") {
  git 'https://github.com/akranga/chucknorris'
  echo 'Done!!!'
}

```

now let's extend workflow with somtheing better
```
// bootstrap.groovy
def flow
node{
  flow = load "main-workflow.groovy"
  echo "bootstrap function end"
}
flow.build()
```

And... run the build!

# Activity 5: Operations with Jenkins

We setup our Jenkins Master and configured persistent volumes, As you noticed we are able to do git pull but we do not able to  compile it. This is because Jenkins Master doesn't have JDK tool installed. We can install it (that's an option); however this will make our Jenkins Master more majical that violates microservice nature of Docker.

Instead of running compilation on Jenkins Master we will prepare set of Dockerized Slaves. 

* Java Builder: has tool JDK. Can run, compile and do test-suits.
* Docker Builder: will create build docker container
* Kubernetes Builder: will manipulate with kubernetes API. Schedule PODs and Services

Let's run it:


### Now let's compile 

We have a challenge