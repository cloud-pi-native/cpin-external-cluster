resource "helm_release" "nginx-controller" {
  name = var.ingress_name
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart = "ingress-nginx"
  namespace = var.ingress_namespace
  create_namespace = true
  description  = var.description
  #wait_for_jobs = true
  values = [
    "${file(var.values_file)}"
  ]
  timeout = 300
}