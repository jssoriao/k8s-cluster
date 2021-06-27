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

### Ingress Controller

Install the [ingress-nginx controller](https://kubernetes.github.io/ingress-nginx/). We will use helm to do this.

```bash
helm repo add <name> https://kubernetes.github.io/ingress-nginx
helm repo update

helm install <name> ingress-nginx/ingress-nginx
```

## Create TLS Secret and Ingress

## Issues Encountered

- GoDaddy provides csr and private key initially for the SSL. The csr is not the certificate you will use in the TLS secret. You can download the actual certificate file from GoDaddy and use it.
- The private key could be in utf8bom format. Change it to utf8 to be able to create the tls secret successfully.
