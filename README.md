# Bring You Own Cluster

Ce projet a pour but de répliquer autant que possible le développement sur CPiN depuis un cluster personnel afin de faciliter la transition vers un cluster de production géré par CPiN.

## Pré-requis

- avoir un kubeconfig disponible
- générer une configuration pour sops
- déclarer une zone dédiée dans la console DSO

Ce chart part du principe qu'un ingress controller est installé. Si ce n'est pas le cas, un exemple pour installer un nginx est disponible dans le dossier **terraform/init**

## Installation

L'installation se déroule en 3 étapes:

1. Préparation des variables
2. Installation ArgoCD + des applications sets
3. (Automatique) Installation des autres briques via argocd

### Étape 1

- Récupérer dans Keycloak le client ID et le secret pour autoriser la connexion OIDC. Ceux-èci ont été automatiquement créés à la création de la zone dans la console DSO.
- Encoder en Base64 votre fichier SOPS. Par exemple le fichier de clé suivant :
  ```
  # created: 2024-09-26T09:58:11+02:00
  # public key: age13pzeffy3d4mrfzy3n6mc03v5secs57n0jju5vndhynmzasxx63lq33y3gm
  AGE-SECRET-KEY-1UTLA4FQQD3MJMUEGNEXF94K9MS4YFPF2MAHQR6YMDRCLE0PEK9XSQKQE4T
  ```
  devient en base 64 :
  ```
  IyBjcmVhdGVkOiAyMDI0LTA5LTI2VDA5OjU4OjExKzAyOjAwDQojIHB1YmxpYyBrZXk6IGFnZTEzcHplZmZ5M2Q0bXJmenkzbjZtYzAzdjVzZWNzNTduMGpqdTV2bmRoeW5temFzeHg2M2xxMzN5M2dtDQpBR0UtU0VDUkVULUtFWS0xVVRMQTRGUVFEM01KTVVFR05FWEY5NEs5TVM0WUZQRjJNQUhRUjZZTURSQ0xFMFBFSzlYU1FLUUU0VA==
  ```
- Préparer en local le fichier `custom-values.yaml` à la racine du présent dépôt et remplacer les `# valeurs spécifiques` :
  ```yaml
  dsoZoneRepo: # Url du dépôt Gitlab pour la zone DSO
  appValues:
    sops:
      key:
        base64_content: # Base64 de votre fichier SOPS
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

### Étape 2

Assurez-vous d'avoir le bon contexte Kubernetes (fichier .kube/config ou variable d'environnement KUBECONFIG) et lancez les commandes suivantes :
```sh
kubectl apply -k https://github.com/argoproj/argo-cd/manifests/crds\?ref\=stable
helm upgrade --install --create-namespace -n argo-cpin -f custom-values.yaml argocd argo-cd
```

### Étape 3

Connectez-vous à votre instance ArgoCD avec le mot de passe admin et surveillez l'installation des différents outils.

Pour récupérer le mot de passe admin :

```shell
kubectl -n argo-cpin get secret argocd-initial-admin-secret --template="{{ .data.password | base64decode}}"
```


