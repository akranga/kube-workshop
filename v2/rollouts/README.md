```kubectl apply -f rbac.yml```
Modify ingress.spec.rules.host...
```
kubectl apply --record -f observer.yml
kubectl apply --record -f pet.yml
kubectl set image --record -f pet.yml application=gcr.io/google_containers/update-demo:nautilus
kubectl rollout status -w deployment/update-demo
```
