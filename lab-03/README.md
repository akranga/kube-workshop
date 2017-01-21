# Activity 3: Working with Volumes

This time we will deploy a Wordpress app... I know it is a little bit boring, however every devops engineer must deploy at WordPress at least once. What is more important. WordPress have got few containers linked together (WordPress and MySQL database). To be able successfully deploy the app we should be able to address configuration management and persistent volumes

Before we will start the excersize, please go to the `lab-03` directory

### Deploying a database

First we need to create a deployment of MySQL. What is important, `myssql` container has an environment variable `MYSQL_ROOT_PASSWORD` that we must set with the desired password.

So, create a file following command

```
$ vim mysql-depl.yaml
```

And then press `i` to go to the insert mode and add following content. After you finish press `esc` and `:wq` to save and exit editor
``` yaml
apiVersion: v1
kind: Service
metadata:
  name: wordpress-mysql
  labels:
    app: wordpress
spec:
  ports:
    - port: 3306
  selector:
    app: wordpress
    tier: mysql
  clusterIP: None
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: wordpress-mysql
  labels:
    app: wordpress
spec:
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: wordpress
        tier: mysql
    spec:
      containers:
      - image: mysql:5.6
        name: mysql
        env:
        - name: MYSQL_ROOT_PASSWORD
          value: mysecretpass
        ports:
        - containerPort: 3306
          name: mysql
```

This time we will use Deployment. It is pretty stable, however it uses BETA api. 

```
$ kubectl create -f mysql-dpl.yaml
deployment "wordpress-mysql" created

$ kubectl get pods
NAME                               READY     STATUS    RESTARTS   AGE
wordpress-mysql-2586502893-qds92   1/1       Running   0          43s
```

Let's try the database
```
$ kubectl exec -i -t wordpress-mysql-2586502893-qds92 bash

root@wordpress-mysql-2586502893-qds92:/# mysql -u root
ERROR 1045 (28000): Access denied for user 'root'@'localhost' (using password: NO)
root@wordpress-mysql-2586502893-qds92:/# mysql -u root -p${MYSQL_ROOT_PASSWORD}

mysql> create database gdg;

mysql> show databases;

+--------------------+
| Database           |
+--------------------+
| ... |
| gdg                |
| ... |
+--------------------+
4 rows in set (0.00 sec)
mysql> exit
Bye
root@wordpress-mysql-2586502893-qds92:/# exit
$
```

Problem with this container, it has ephemeral storage that will not survive container crash.

```
$ docker ps | grep mysql
de0bac76808d        mysql:5.6 ...

$ docker kill de0bac76808d
de0bac76808d

$ kubectl get pods
NAME                               READY     STATUS    RESTARTS   AGE
wordpress-mysql-2586502893-qds92   1/1       Running   1          10m
```

Let's validate the database
```
$ kubectl exec -i -t wordpress-mysql-2586502893-qds92 bash
root@wordpress-mysql-2586502893-qds92:/# mysql -u root -p${MYSQL_ROOT_PASSWORD}
mysql> show databases;
mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
+--------------------+
3 rows in set (0.00 sec)

mysql> exit
Bye
root@wordpress-mysql-2586502893-qds92:/# exit
exit
$ 
```

To be able to surve this we need to add persistent volumes. Kubernetes supports over 18 different volume types. We will use most simplistic called `emptyDir`

Create a file:
```
$ vim wordpress-pv.yaml
```

And add following content
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: local-pv-1
  labels:
    type: local
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: /tmp/data/pv-1
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: local-pv-2
  labels:
    type: local
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: /tmp/data/pv-2
```

This will create two persistent volumes in `/temp/data` directory with size 10GB each. 

You can link persistent volumes directly to the container. However it is not a good practice. In fact container should just claim, that it wants certain persistencde and kubernetes shoudl be able to deliver desired storage.

So we create a persistence claim file
```
$ vim mysql-pvc.yaml
```

And add following code:
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-pv-claim
  labels:
    app: wordpress
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
```

and run the command
```
$ kubectl create -f mysql-pvc.yaml
```

Check what we have got here:
```
$ kubectl get pv
NAME         CAPACITY   ACCESSMODES   RECLAIMPOLICY   STATUS      CLAIM                    REASON    AGE
local-pv-1   10Gi       RWO           Retain          Available                                      4m
local-pv-2   10Gi       RWO           Retain          Bound       default/mysql-pv-claim             4m

$ kubectl get pvc
NAME             STATUS    VOLUME       CAPACITY   ACCESSMODES   AGE
mysql-pv-claim   Bound     local-pv-2   10Gi       RWO           26s
```

You see? Persistent volume remains operational generic, while persistence volume claim is now application specific.

Now we are ready to link volumes to the mysql deployment. Let's modify our deployment file
```
$ vim mysql-depl.yaml
```

Add followng code
```yaml
apiVersion: v1
kind: Service
metadata:
  name: wordpress-mysql
  labels:
    app: wordpress
spec:
  ports:
    - port: 3306
  selector:
    app: wordpress
    tier: mysql
  clusterIP: None
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: wordpress-mysql
  labels:
    app: wordpress
spec:
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: wordpress
        tier: mysql
    spec:
      containers:
      - image: mysql:5.6
        name: mysql
        env:
        - name: MYSQL_ROOT_PASSWORD
          value: mysecretpass
        ports:
        - containerPort: 3306
          name: mysql
        volumeMounts:
        - name: mysql-persistent-storage
          mountPath: /var/lib/mysql
      volumes:
      - name: mysql-persistent-storage
        persistentVolumeClaim:
          claimName: mysql-pv-claim
```

And run command to update the deployment
```
$ kubectl apply -f mysql-dpl.yaml
service "wordpress-mysql" configured
deployment "wordpress-mysql" configured
```

# Deploy Wordpress

Well this should be rather easy
```
$vim wordpress-dpl.yaml
```

apply following content
```yaml
apiVersion: v1
kind: Service
metadata:
  name: wordpress
  labels:
    app: wordpress
spec:
  ports:
    - port: 80
  selector:
    app: wordpress
    tier: frontend
  type: LoadBalancer
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: wp-pv-claim
  labels:
    app: wordpress
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: wordpress
  labels:
    app: wordpress
spec:
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: wordpress
        tier: frontend
    spec:
      containers:
      - image: wordpress:4.6.1-apache
        name: wordpress
        env:
        - name: WORDPRESS_DB_HOST
          value: wordpress-mysql
        - name: WORDPRESS_DB_PASSWORD
          value: mysecretpass
        ports:
        - containerPort: 80
          name: wordpress
        volumeMounts:
        - name: wordpress-persistent-storage
          mountPath: /var/www/html
      volumes:
      - name: wordpress-persistent-storage
        persistentVolumeClaim:
          claimName: wp-pv-claim
```

And let's create all these resources

```
$ kubectl create -f wordpress-dpl.yaml

service "wordpress" created
persistentvolumeclaim "wp-pv-claim" created
deployment "wordpress" created


```