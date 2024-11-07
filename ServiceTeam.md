# Documentation pour la ServiceTeam

Les exemples se font depuis la plateforme OVH sur la console hp, à adapter selon le contexte.

Pré-requis:

- Avoir l'url du futur ArgoCD déployé (exemple: https://argocd.demo-cpin.numerique-interieur.com/): *possible de fournir cette valeur plus tard*

Etapes pour la création d'une zone et d'un cluster pour le BYOC:

- Créer une zone (**SuccessTeam Bring Your Own Cluster**)
- Créer un cluster dans la zone associée (**st-byoc**): rentrer un kubeconfig vide pour la configuration
- Récupérer le clientID et clientSecret dans keycloak
- Récupérer l'url dans gitlab qui sera scrutée par le ArgoCD déployé (**attention, l'url doit finir par .git)

## Créer une zone

Voir la zone d'exemple: **SuccessTeam Bring Your Own Cluster**

## Créer un cluster

Voir l'exemple **st-byoc**.

Dans la création d'un cluster, il est demandé de fournir un kubeconfig valide, utiliser le kubeconfig vide suivant:

```yaml
apiVersion: v1
clusters:
- cluster:
    insecure-skip-tls-verify: true
    server: https://nohost
  name: empty
contexts:
- context:
    cluster: empty
    user: empty
  name: empty
current-context: empty
kind: Config
preferences: {}
users:
- name: empty
  user: {}
```

Cela permettra à la console de savoir qu'il s'agit d'un ArgoCD déporté.

## Keycloak

Chaque zone se voit créer un client sur Keycloak. Se connecter au Keycloak (https://keycloak.apps.dso.hp.numerique-interieur.com/), choisir le royaume **DSO**, puis Client.

Clique sur le client **argocd-<nom court de la zone>-zone** (argocd-stbyoc-zone pour l'exemple). Le clientID se trouve dans l'onglet Settings et le clientSecret dans l'onglet Credentials.

## Gitlab

La communication entre la console et ArgoCD se fait via un repo git qu'il faut fournir à l'installation de l'argoCD.

Ce repo se trouve dans **forge-mi/projects/infra/mi/<nom court de la zone>.git** (dans l'exemple https://gitlab.apps.dso.hp.numerique-interieur.com/forge-mi/projects/infra/mi/stbyoc.git)

### Authentification (point à améliorer)

ArgoCD doit pouvoir s'authentifier auprès de GitLab, les informations de connexion sont récupérables sur le cluster dso:

```shell
kubectl -n dso-argocd get secret gitlab -o yaml
```

Ce secret sera à créer dans le cluster cible.