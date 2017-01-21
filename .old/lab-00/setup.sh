#!/bin/bash
MYIP=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)
curl -O https://storage.googleapis.com/kubernetes-release/release/v1.2.3/bin/linux/amd64/kubectl
chmod +x kubectl
sudo mv kubectl /opt/bin/
kubectl config set-cluster default-cluster --server=https://$MYIP --certificate-authority=/etc/kubernetes/ssl/ca.pem

git clone https://github.com/akranga/kube-workshop.git