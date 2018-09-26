# Helm Charts

Kubernetes is awesome, however we can get mad among all these pods, configmaps, persistent volumes etc. What kubernetes really needs is a package manager. Kind of `yum` or `apt` or (`nuget` for Windows lovers :)

Helm is solving exactly this problem. It delivers package manager.

Helm has been composed of few compoonents
* **Tiller** an API service deployed as kubernetes pod. This service provides necessary routines to control lifecycle of the deployments
* `helm` is a CLI client for Tiller
* **Charts** are actual deployment unites of Helm
* **Repositories** of helm charts

In this lab we will create a Chart for our Word Smith application

## Getting started with 

Your cluster already have got a Tiller up and running (In fact, we silently deployed an ingress controller, Traefik as a helm chart).

We do not need to install a Tiller. Just to initialize a client.

With your toolbox, run following command:
```
helm init --client-only --upgrade

Adding stable repo with URL: https://kubernetes-charts.storage.googleapis.com
Adding local repo with URL: http://127.0.0.1:8879/charts
Not installing Tiller due to 'client-only' flag having been set
Happy Helming!
```

After your `helm` cli have got connectivity with Tiller (backend API) you should be able to run few commands
```
helm list

NAME    REVISION  UPDATED                   STATUS    CHART           NAMESPACE
traefik 1         Wed Sep 26 00:42:34 2018  DEPLOYED  traefik-1.38.0  ingress
```

Told you, we have got taefik server installed as helm chart.

### Create your own Helm chart

Run following command:
```
helm create wordsmith

Creating wordsmith
```

Let's see what has been generated
```
  wordsmith/
    |- .helmignore   # Contains patterns to ignore when packaging Helm charts.
    |- Chart.yaml    # Information about your chart
    |- values.yaml   # The default values for your templates
    |- charts/       # Charts that this chart depends on
    |- templates/    # The template files
    |- templates/deployment.yaml
    |- templates/ingress.yaml
    |- templates/service.yaml
    |- templates/NOTES.txt # help notes for the user
    |- templates/_helpers.tpl # templating routines (gotemplates)
```

### Configuration management

Now our helm chart skeleton has bene creaetd. Let's go inside the directory
```
cd worksmith/

cat Chart.yaml

apiVersion: v1
appVersion: "1.0"
description: Our awesome Wordsmith application
name: wordsmith
version: 0.1.0
```
This is a Chart manifest. It contains version number, chart dependencies (from other charts) etc. We leave it as is. `values.yaml` is more interseing for us

This file contains a configruation management data for our deployment. It has been written in free format. 
```yaml
api:
  image: dockersamples/k8s-wordsmith-api
  replicas: 5

db:
  image: dockersamples/k8s-wordsmith-db

web:
  image: dockersamples/k8s-wordsmith-web
  servicePort: 80

ingress:
  enabled: true
  domain: app.<YOUR-CLUSTER>.superhub.io


# from origitnal helm chart. Not used here
resources: {}
  # We usually recommend not to specify default resources and to leave this as a conscious
  # choice for the user. This also increases chances charts run on environments with little
  # resources, such as Minikube. If you do want to specify resources, uncomment the following
  # lines, adjust them as necessary, and remove the curly braces after 'resources:'.
  # limits:
  #  cpu: 100m
  #  memory: 128Mi
  # requests:
  #  cpu: 100m
  #  memory: 128Mi

nodeSelector: {}

tolerations: []

affinity: {}
```
Actual format has been directeed by templates (see below)

### Customize Templates 
We write following content

Customize: `templates/deployment.yaml`

```yaml
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: {{ template "fullname" . }}-db
  labels:
    app: {{ template "fullname" . }}-db
    chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
    release: "{{ .Release.Name }}"
    heritage: "{{ .Release.Service }}"
spec:
  template:
    metadata:
      labels:
        app: {{ template "fullname" . }}-db
        chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
        release: "{{ .Release.Name }}"
        heritage: "{{ .Release.Service }}"
    spec:
      containers:
      - name: db
        image: {{ .Values.db.image }}
        ports:
        - containerPort: 5432
          name: db
---
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: {{ template "fullname" . }}-api
  labels:
    app: {{ template "fullname" . }}-api
    chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
    release: "{{ .Release.Name }}"
    heritage: "{{ .Release.Service }}"
spec:
  replicas: {{ .Values.api.replicas }}
  template:
    metadata:
      labels:
        app: {{ template "fullname" . }}-api
        chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
        release: "{{ .Release.Name }}"
        heritage: "{{ .Release.Service }}"
    spec:
      containers:
      - name: {{ template "fullname" . }}-api
        image: {{ .Values.api.image }}
        ports:
        - containerPort: 8080
          name: api
---
apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: {{ template "fullname" . }}-web
  labels:
    app: {{ template "fullname" . }}-web
    chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
    release: "{{ .Release.Name }}"
    heritage: "{{ .Release.Service }}"
spec:
  template:
    metadata:
      labels:
        app: {{ template "fullname" . }}-web
        chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
        release: "{{ .Release.Name }}"
        heritage: "{{ .Release.Service }}"
    spec:
      containers:
      - name: {{ template "fullname" . }}-web
        image: {{ .Values.web.image }}
        ports:
        - containerPort: 80
          name: words-web
```

Then `template/service.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: db
  labels:
    app: {{ template "fullname" . }}-db
    chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
    release: "{{ .Release.Name }}"
    heritage: "{{ .Release.Service }}"
spec:
  ports:
    - port: 5432
      targetPort: 5432
      name: db
  selector:
    app: {{ template "fullname" . }}-db
    chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
    release: "{{ .Release.Name }}"
    heritage: "{{ .Release.Service }}"
---
apiVersion: v1
kind: Service
metadata:
  name: words
  labels:
    app: {{ template "fullname" . }}-api
    chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
    release: "{{ .Release.Name }}"
    heritage: "{{ .Release.Service }}"
spec:
  ports:
    - port: 8080
      targetPort: 8080
      name: api
  selector:
    app: {{ template "fullname" . }}-api
    chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
    release: "{{ .Release.Name }}"
    heritage: "{{ .Release.Service }}"
---
apiVersion: v1
kind: Service
metadata:
  name: {{ template "fullname" . }}-web
  labels:
    app: {{ template "fullname" . }}-web
    chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
    release: "{{ .Release.Name }}"
    heritage: "{{ .Release.Service }}"
spec:
  ports:
    - port: {{default "80" .Values.web.servicePort }}
      targetPort: 80
      name: web
  selector:
    app: {{ template "fullname" . }}-web
    chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
    release: "{{ .Release.Name }}"
    heritage: "{{ .Release.Service }}"
```

Last but not least: `template/ingress.yaml`
```yaml
{{- if .Values.ingress.enabled -}}
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: {{ template "fullname" . }}-ingress
spec:
  rules:
  - host: {{ .Release.Name }}.{{ .Values.ingress.domain }}
    http:
      paths:
      - path: /
        backend:
          serviceName: {{ template "fullname" . }}-web
          servicePort: {{default "80" .Values.web.servicePort }}
{{- end }}
```

### Deployment

Now we are ready to deploy the application. This can be asily done with one single dcommand:
```
helm install --name smith --replace --values values.yaml .
```

### Troubleshooting

If you get something like the below, then it means our template helper does not have necessary definitons
**ERROR:**
``` 
Error: render error in "wordsmith/templates/service.yaml": template: wordsmith/templates/service.yaml:6:21: executing "wordsmith/templates/service.yaml" at <{{template "fullname...>: template "fullname" not defined
```




Let's update it with: `templates/_helpers.tpl`
```
{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
```

Now we are ready
```bash
helm install --name smith --replace --values values.yaml .
NAME:   smith
LAST DEPLOYED: Wed Sep 26 04:10:25 2018
NAMESPACE: default
STATUS: DEPLOYED

RESOURCES:
==> v1/Service
NAME                 TYPE       CLUSTER-IP    EXTERNAL-IP  PORT(S)   AGE
smith-wordsmith-web  ClusterIP  10.3.127.102  <none>       80/TCP    0s
db                   ClusterIP  10.3.51.233   <none>       5432/TCP  0s
words                ClusterIP  10.3.56.201   <none>       8080/TCP  0s

==> v1beta1/Deployment
NAME                 DESIRED  CURRENT  UP-TO-DATE  AVAILABLE  AGE
smith-wordsmith-db   1        1        1           0          0s
smith-wordsmith-api  5        5        5           0          0s
smith-wordsmith-web  1        1        1           0          0s

==> v1beta1/Ingress
NAME                     HOSTS                                 ADDRESS  PORTS  AGE
smith-wordsmith-ingress  smith.app.YOUR-CLUSTER.superhub.io  80       0s

==> v1/Pod(related)
NAME                                  READY  STATUS             RESTARTS  AGE
smith-wordsmith-db-8499767b9b-gb8cp   0/1    ContainerCreating  0         0s
smith-wordsmith-api-d4589656b-2l8dz   0/1    ContainerCreating  0         0s
smith-wordsmith-api-d4589656b-85cmq   0/1    ContainerCreating  0         0s
smith-wordsmith-api-d4589656b-bkvb4   0/1    Pending            0         0s
smith-wordsmith-api-d4589656b-jmht5   0/1    Pending            0         0s
smith-wordsmith-api-d4589656b-pb64v   0/1    Pending            0         0s
smith-wordsmith-web-76485bc68b-qmq6c  0/1    ContainerCreating  0         0s

```

### Validate:
Now let's hit [http://smith.app.YOUR-CLUSTER.superhub.io] with your browser. 

### Charts distribution
You can distribute a your helm chart via Chart repository. Your stack have got a Chart museum deployed as part of Harbor registry. To upload your helm chart you need to do following actions:

**1. Package helm chart**
Run following command:
```bash
helm package .
ls *.tgz
# wordsmith-0.1.0.tgz
```

**2. Add helm chart registry**
Run following command (Harbor password required)
```bash
helm repo add my-charts --username=admin --password=**hidden** https://harbor.svc.YOURSTACK.kubernetes.delivery/chartrepo/workshop
```

**3. Upload chart***
Again, use `helm` (Harbor password required):
```bash
helm plugin install https://github.com/chartmuseum/helm-push
helm push --username=admin --password=***hidden*** wordsmith-0.1.0.tgz harbor
```

**4. Validate**

1. With your browser open: https://harbor.svc.YOURSTACK.kubernetes.delivery/chartrepo/workshop
2. Go to the: projects -> workshop -> helm charts
3. See you chart

### Tear down:

```
helm delete --purge smith
```
