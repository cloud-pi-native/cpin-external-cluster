resource "helm_release" "argocd" {
  name      = "argocd"
  namespace = var.argocd_namespace
  chart = "../../charts-socle/argo-cd"
  create_namespace = true
  values = [
    file("../../charts-socle/argo-cd/values-cpin.yaml")
  ]
}