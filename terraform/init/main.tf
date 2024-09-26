module "ingress" {
  source      = "../modules/ingress"
  ingress_name = "nginx"
  ingress_namespace = "nginx-cpin"
    values_file = "values-default.yaml"
}

