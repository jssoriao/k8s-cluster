# Kubernetes Infrastructure

## Create an LKE cluster

Authenticate with linode. If you don't have an existing token, go to [API Tokens](https://cloud.linode.com/profile/tokens) and create one.

```bash
export LINODE_TOKEN="<linode-personal-access-token>"
```

Create an access key and secret key in Linode Object Storage. We will use the storage as our terraform state backend.
This assumes that you have already created a storage bucket. Create a copy of `default.config.sample` and name that copy `default.config`.
Provide the actual inputs inside the `default.config` file.

```bash
terraform init --backend-config="./default.config"
```

Review and deploy.

```bash
terraform plan
terraform apply
```

## Prepare LKE cluster for deployment

Download the cluster's kubeconfig file either from the browser or by using the command below. Set its path for the `KUBECONFIG` environment variable.
This will make `kubectl` use the configuration inside that file.

```bash
terraform output --raw kubeconfig | base64 -d > /path/to/kubeconfig.yaml
export KUBECONFIG=/path/to/kubeconfig.yaml
```

Create a namespace for your deployments. The blog project which we will deploy later in this guide uses the namespace `blog`.

```bash
kubectl create namespace blog
```

Create a secret for private dockerhub credentials. See more options [here](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/)

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: <secret-name>
  namespace: <namespace>
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: <base64 encoded dockerconfigjson>
```

Another option is the following command.

```bash
kubectl create secret docker-registry dockerhub-key \
    --docker-server=<registry-server e.g. https://index.docker.io/v1/ for dockerhub> \
    --docker-username=<username> \
    --docker-password=<password> \
    --docker-email=<email> \
    --namespace blog
```

## Install Helm

[Link](https://helm.sh/docs/intro/install/)

## Ingress Controller

[Guide](https://www.linode.com/docs/guides/how-to-deploy-nginx-ingress-on-linode-kubernetes-engine/)

Install the [ingress-nginx controller](https://kubernetes.github.io/ingress-nginx/). We will use helm to do this.

```bash
helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace
```

> NOTE: This will create a Linode NodeBalancer that will also incur cost alongside the LKE.

## Create IngressClass and Ingress objects

[Securing NGINX-Ingress](https://cert-manager.io/docs/tutorials/acme/nginx-ingress/)

```bash
kubectl apply -f ingress-class.yaml
kubectl apply -f ingress.yaml
```

## Install and configure cert-manager and issuer

Install cert-manager

```bash
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.8.1 \
  --set installCRDs=true
```

Create staging and production issuers for Let's Encrypt. Edit the email field with your own email.

> Take care to ensure that your Issuers are created in the same namespace as the certificates you want to create

```bash
# Staging Issuer
kubectl create --edit -f https://raw.githubusercontent.com/cert-manager/website/master/content/docs/tutorials/acme/example/staging-issuer.yaml -n blog
# Production Issuer
kubectl create --edit -f https://raw.githubusercontent.com/cert-manager/website/master/content/docs/tutorials/acme/example/production-issuer.yaml -n blog
```

Modify the ingress manifest to use an annotation which will make the cert-manager automatically request for a certificate and create a tls secret.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
---
metadata:
  annotations:
    cert-manager.io/issuer: letsencrypt-prod
spec:
  ingressClassName: nginx
  tls:
    - hosts:
        - subdomain.example.com
      secretName: tls-secret
  ...
```

Verify that the certificate is properly created.

```bash
kubectl get certificate -n blog
```
