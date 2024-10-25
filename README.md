# Bring You Own Cluster

Ce projet a pour but de répliquer autant que possible le développement sur CPiN depuis un cluster personnel afin de faciliter la transition vers un cluster de production géré par CPiN.

## Pré-requis

- avoir un kubeconfig disponible
- générer une configuration pour sops

Ce chart part du principe qu'un ingress controller est installé. Si ce n'est pas le cas, un exemple pour installer un nginx est disponible dans le dossier **terraform/init**

## Installation

L'installation se déroule en 2 étapes:

- Installation de sops et argocd via terraform
- Installation des autres briques via argocd
 
Ou bien uniquement via Kubectl + Helm avec :
```sh
kubectl apply -k https://github.com/argoproj/argo-cd/manifests/crds\?ref\=stable
helm upgrade --install --create-namespace -n argo-cpin -f custom-values.yaml argocd charts-socle/argo-cd
```

### Etape 1

Se placer dans le dossier **terraform/cpin** et créer le fichier **main.auto.tfvars** contenant les champs suivants:

```txt
secret_sops_base64 = <clé sops en base64>
kubeconfig = "<chemin vers le kubeconfig>"
```

```shell
terraform init
terraform apply
```

Pour récupérer le mot de passe admin d'argocd infra:

```shell
kubectl -n argo-cpin get secret argocd-initial-admin-secret --template="{{ .data.password | base64decode}}"
```

