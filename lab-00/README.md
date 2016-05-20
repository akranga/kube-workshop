# Prepare the environment

First of all... please run setup.sh script 

```
./setup.sh
```

It should bootstrap credentials for your local copy of kubernetes

to test that everything fine, you should be able to run command:

```
$ ls -l

drwxr-xr-x. 12 core core 4096 May 20 07:13 kube-workshop

$ kubectl get nodes

NAME                                          STATUS    AGE
ip-10-0-0-204.eu-central-1.compute.internal   Ready     1m
```

Which means that Single node Kubernetes instance has been initialized successfully

Now go to the kuber-workshop directory

```
cd ~/kube-workshop/lab-01
```

It is time to proceed with `lab01`. Follow the instructions in `README.md` file. 
