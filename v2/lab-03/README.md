
# Lab 03 Scale the Application && Rolling updates

## Introduction

Our application experiences a high load and we want to increase number of replicas for certain microservices.

1. In this Lab we will use the application created in the Lab 2. ```kubectl get pods ``` should give you similar output:
```
╰─ kubectl get pods -o wide
NAME                     READY     STATUS    RESTARTS   AGE       IP          NODE
db-f49555865-jpmkd       1/1       Running   0          1h        10.2.1.39   ip-10-0-36-25.eu-west-1.compute.internal
web-768bd556bc-8d5xf     1/1       Running   0          1h        10.2.1.41   ip-10-0-36-25.eu-west-1.compute.internal
words-7dbb6b4845-mmnh2   1/1       Running   0          1h        10.2.1.40   ip-10-0-36-25.eu-west-1.compute.internal
words-7dbb6b4845-t9qg7   1/1       Running   0          1h        10.2.0.24   ip-10-0-44-3.eu-west-1.compute.internal
words-7dbb6b4845-w8tgx   1/1       Running   0          1h        10.2.2.25   ip-10-0-34-172.eu-west-1.compute.internal
```

2. There are 3 replicas of ```words``` pod currently running in the cluster. Let's scale it up to 10 replicas:
```
kubectl scale deployment web --replicas=10
```
Run ```kubectl get pods``` and observe additional instances of ```words``` pod:
```
db-f49555865-jpmkd       1/1       Running             0          1h        10.2.1.39   ip-10-0-36-25.eu-west-1.compute.internal
web-768bd556bc-8d5xf     1/1       Running             0          1h        10.2.1.41   ip-10-0-36-25.eu-west-1.compute.internal
words-7dbb6b4845-dn25s   1/1       Running             0          1s        10.2.2.33   ip-10-0-34-172.eu-west-1.compute.internal
words-7dbb6b4845-hjt29   1/1       Running             0          1s        10.2.2.32   ip-10-0-34-172.eu-west-1.compute.internal
words-7dbb6b4845-l6w8r   0/1       ContainerCreating   0          1s        <none>      ip-10-0-44-3.eu-west-1.compute.internal
words-7dbb6b4845-mmnh2   1/1       Running             0          1h        10.2.1.40   ip-10-0-36-25.eu-west-1.compute.internal
words-7dbb6b4845-ntzxm   0/1       ContainerCreating   0          1s        <none>      ip-10-0-34-172.eu-west-1.compute.internal
words-7dbb6b4845-p789z   1/1       Running             0          1s        10.2.0.32   ip-10-0-44-3.eu-west-1.compute.internal
words-7dbb6b4845-rdf9h   1/1       Running             0          1s        10.2.1.49   ip-10-0-36-25.eu-west-1.compute.internal
words-7dbb6b4845-t9qg7   1/1       Running             0          1h        10.2.0.24   ip-10-0-44-3.eu-west-1.compute.internal
words-7dbb6b4845-w8tgx   1/1       Running             0          1h        10.2.2.25   ip-10-0-34-172.eu-west-1.compute.internal
words-7dbb6b4845-wvspz   1/1       Running             0          1s        10.2.1.48   ip-10-0-36-25.eu-west-1.compute.internal
```

3. Now let's tail the logs of few ```words``` pods and observe that requests reaches all of them
```
╰─ kubectl logs -f words-7dbb6b4845-dn25s
{"word":"ūdens"}
{"word":"koks"}
╰─ kubectl logs -f words-7dbb6b4845-hjt29
{"word":"centīgs"}
{"word":"cilvēks"}
{"word":"ciets"}
{"word":"ir"}
{"word":"ciets"}
...
```

> There is no native Kubernetes tool, that allows log aggregation from multiple pods, however there is a lightweight open-source tool written on Go called Stern that does log aggregation. Mac users can install it using Brew ```brew install stern```

