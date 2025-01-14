# Bring Your Own Cluster

Ce projet a pour but de répliquer autant que possible le développement sur CPiN depuis un cluster personnel afin de faciliter la transition vers un cluster de production géré par CPiN.

## Architecture

Le projet va déployer un ArgoCD qui va piloter les déploiements de la zone associée au cluster.

Deux appset seront créés :

- cpin-appset : appset qui sera en charge d'installer les outils de sécurité pour mimer au mieux un cluster CPiN
- dso-appset : appset qui est chargé de déployer les applications créées dans la console hexaforge

Pour récupérer les sources, les secrets, l'authentification, un flux devra être ouvert vers le cluster DSO opéré par les équipes de Cloud Pi Native

![architecture](docs/img/architecture.png)


## Pré-requis

**Client:**

- les briques (gitlab, keycloak, vault) de la console DSO doivent être accessibles (ouverture de flux, etc.): sur OVH *.apps.dso.numerique-interieur.com
- créer un cluster kubernetes et avoir le kubeconfig (configuration pour ArgoCD)
- un IngressController sur le cluster (Openshift utilise un HAProxy repackagé).
- générer une configuration pour sops
- avoir l'url du futur ArgoCD

**Service Team:**

- déclarer une zone dédiée dans la console DSO (voir [ServiceTeam.md](ServiceTeam.md))
- fournir les informations de connexion pour Keycloak (clientID, clientSecret)
- fournir le secret pour l'authentification d'ArgoCD à GitLab

> Ce chart part du principe qu'un ingress controller est installé. Si ce n'est pas le cas, un exemple pour installer un nginx est disponible dans le dossier **terraform/init**

## Installation

L'installation se déroule en 3 étapes :

1. Préparation des variables
2. Installation ArgoCD + des applications sets
3. (Automatique) Installation des autres briques via ArgoCD

### Étape 1: Configuration

#### SOPS

Les clusters SOPS ont accès à l'[opérateur SOPS](https://github.com/isindir/sops-secrets-operator) qui permet de chiffrer un fichier de secret et pouvoir le commiter dans git.

SOPS accepte plusieurs méthodes de chiffrement, l'équipe CPiN a choisi l'algorithme [AGE](https://github.com/FiloSottile/age) pour ses clusters :

- Générer le fichier de configuration AGE :
```shell
age-keygen -o key.txt
```

- Encoder le contenu en base64 :
```shell
cat key.txt | base64 -w 0
```

### Configuration des briques CPiN du nouveau cluster

- Préparer en local le fichier `custom-values.yaml` à la racine du présent dépôt et remplacer les `# valeurs spécifiques` :
    - **dsoZoneRepo** : URL du dépôt GitLab pour la zone DSO avec un .git - fourni par la ServiceTeam
    - **appValues.sops.key.base64_content** : Base64 de votre fichier SOPS - voir étape précédente
    - **global.domain / etc** : Nom de domaine cible pour cet ArgoCD - votre choix
    - **argo-cd.configs.cm.oidc.config** : Configuration pour se connecter à ArgoCD via Keycloak - informations fournies par la ServiceTeam

  ```yaml
  dsoZoneRepo: # URL du dépôt GitLab pour la zone DSO avec un .git
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

ArgoCD a besoin de s'authentifier auprès du GitLab de DSO pour récupérer des informations, pour cela ArgoCD va scruter son namespace à la recherche de secrets avec le label `argocd.argoproj.io/secret-type: repo-creds`.

Créer le manifest suivant (nommé gitlab-secret.yaml dans la suite du README), la ServiceTeam fournira les informations de connexion nécessaires :

```yaml
apiVersion: v1
kind: Secret
metadata:
  labels:
    argocd.argoproj.io/secret-type: repo-creds
  name: gitlab
type: Opaque
data:
  url:
  username:
  password:
```

### Étape 2 : Installation

Assurez-vous d'avoir le bon contexte Kubernetes (fichier .kube/config ou variable d'environnement KUBECONFIG) et lancez les commandes suivantes depuis la racine du dossier :

```sh
kubectl apply -k https://github.com/argoproj/argo-cd/manifests/crds\?ref\=stable
helm repo add argo https://argoproj.github.io/argo-helm
helm dependency build argo-cd
helm upgrade --install --create-namespace -n argo-cpin -f custom-values.yaml argocd argo-cd
kubectl -n argo-cpin apply -f gitlab-secret.yaml
```

### Étape 3 : Administration

Connectez-vous à votre instance ArgoCD avec le mot de passe admin pour refresh les applications et surveillez l'installation des différents outils.

Pour récupérer le mot de passe admin :

```shell
kubectl -n argo-cpin get secret argocd-initial-admin-secret --template="{{ .data.password | base64decode}}"; echo ""
```

## Post-Config

### Création du secret de connexion au cluster

ArgoCD a besoin d'un secret pour se connecter au cluster afin de déployer les applications clientes.

**Ce secret doit spécifier le même nom de cluster que celui déclaré dans la console**

Le script `kubeconfig-to-cluster-secret.sh` permet de générer le yaml du secret à partir d'un kubeconfig :

```sh
./kubeconfig-to-cluster-secret.sh -k <kubeconfig path> -n <cluster name> [-c <context_name>] [-i <https://cluster_api_ip:443>]
kubectl -n argo-cpin apply -f <cluster-name>-cluster-secret.yaml
```

*Si vous modifiez le secret pour avoir comme URL `https://kubernetes.default.svc`, cela va supprimer le secret **in-cluster**. Attention aux applications qui utilisent ce nom de destination au lieu de l'URL de destination.*

## Différence avec l'offre Cloud Pi Native au MI

### CDS

#### Certificat

Les certificats sont portés par la CDS, pas besoin de générer des ingress TLS

### Openshift

#### Réseaux

L'IngressController d'Openshift est basé sur HAProxy, repackagé par RedHat. Il ne répond donc pas aux mêmes annotations que l'opérateur officiel.

Voir la documentation [ici](https://docs.openshift.com/container-platform/4.15/networking/routes/route-configuration.html#nw-route-specific-annotations_route-configuration)

Openshift a une notion de route en plus des ingress, pas besoin de s'en préoccuper : une route sera automatiquement créée pour chaque ingress créé.

#### Sécurité

Openshift est une distribution sécurisée de Kubernetes qui génère automatiquement un [security context](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/) pour les pods conforme au [PSS](https://kubernetes.io/docs/concepts/security/pod-security-standards/) en mode **restricted** et avec pour la propriété **runAsUser** un nombre aléatoire.

Afin de mimer au mieux les contraintes d'Openshift, ce repo active (pour les namespaces liés à un projet dans la console DSO) les [PSS](https://kubernetes.io/docs/concepts/security/pod-security-standards/) en mode **restricted**. Il faudra définir soi-même le security context pour les pods, en pensant à mettre une valeur aléatoire pour la propriété **runAsUser**.
