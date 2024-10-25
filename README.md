# Bring You Own Cluster

Ce projet a pour but de répliquer autant que possible le développement sur CPiN depuis un cluster personnel afin de faciliter la transition vers un cluster de production géré par CPiN.

## Pré-requis

- avoir un kubeconfig disponible
- générer une configuration pour sops
- déclarer une zone dédiée dans la console DSO

Ce chart part du principe qu'un ingress controller est installé. Si ce n'est pas le cas, un exemple pour installer un nginx est disponible dans le dossier **terraform/init**

## Installation

L'installation se déroule en 3 étapes:

1. Installation de sops via terraform
2. Installation ArgoCD + ses application sets
3. Installation des autres briques via argocd

### Étape 1

Se placer dans le dossier **terraform/cpin** et créer le fichier **main.auto.tfvars** contenant les champs suivants:

```txt
secret_sops_base64 = <clé sops en base64>
kubeconfig = "<chemin vers le kubeconfig>"
```

```shell
terraform init
terraform apply
```

### Étape 2

Récupérer dans Keycloak le client ID et le secret pour autoriser la connexion OIDC et préparer en local le fichier `custom-values.yaml` à la racine du présent dépôt :
```yaml
dsoZoneRepo: # Url du dépôt Gitlab pour la zone DSO
global:
  domain: # Nom de domaine cible pour cet ArgoCD
argo-cd:
  configs:
    cm:
      oidc.config: |
        name: Keycloak
        issuer: # Url du Keycloak DSO cible
        clientID: # Client ID à récupérer dans Keycloak (realm DSO)
        clientSecret: # Secret Keycloak correspondant (onglet Credentials)
        requestedScopes: ["openid", "groups"]
  server:
    ingress:
      hosts:
        - # Nom de domaine cible pour cet ArgoCD
      tls:
        - hosts:
            - # Nom de domaine cible pour cet ArgoCD
```

```sh
kubectl apply -k https://github.com/argoproj/argo-cd/manifests/crds\?ref\=stable
helm upgrade --install --create-namespace -n argo-cpin -f custom-values.yaml argocd argo-cd
```

Pour récupérer le mot de passe admin d'argocd infra:

```shell
kubectl -n argo-cpin get secret argocd-initial-admin-secret --template="{{ .data.password | base64decode}}"
```

### Étape 3


