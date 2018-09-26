```kubectl apply -f rbac.yml```
Modify ingress.spec.rules.host...
```kubectl apply -f --record observer.yml```
```kubectl apply -f --record pet.yml```
```kubectl set image --record -f pet.yml application=gcr.io/google_containers/update-demo:nautilus
```kubectl -n update-demo rollout status -w 'deployment/update-demo```
