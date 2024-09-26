module "sops" {
  source      = "../modules/sops"
  sops_namespace = "sops-cpin"
  secret_sops_base64 = var.secret_sops_base64
}

module "argocd" {
  source      = "../modules/argocd"
  argocd_namespace = "argo-cpin"
}