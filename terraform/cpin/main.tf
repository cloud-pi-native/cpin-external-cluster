module "sops" {
  source      = "../modules/sops"
  sops_namespace = "sops-cpin"
  secret_sops_base64 = var.secret_sops_base64
}
