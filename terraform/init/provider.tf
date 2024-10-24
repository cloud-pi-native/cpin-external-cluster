provider "kubernetes" {
  config_path    = var.kubeconfig
#  config_context = "admin@k8s-demo-public-cloud-cpin"
}

provider "helm" {
  kubernetes {
    config_path  = var.kubeconfig
#  config_context = "admin@k8s-demo-public-cloud-cpin"
  }
}