# Prepare the environment

First of all... please run setup.sh script 

```
./setup.sh
```

It should bootstrap credentials for your local copy of kubernetes

to test that everything fine, you should be able to run command:

```
$ kubectl get nodes

NAME                                          STATUS    AGE
ip-10-0-0-204.eu-central-1.compute.internal   Ready     1m
```

Which means that Single node Kubernetes instance has been initialized successfully

It is time to proceed with `lab01`. Follow the instructions in `README.md` file. 