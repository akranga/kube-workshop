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

