provider "kubernetes" {
  config_path    = "C:/Users/PierreLECLAINCHE/.kube/kubeconfig-k8s-demo-public-cloud-cpin.yaml"
#  config_context = "admin@k8s-demo-public-cloud-cpin"
}

provider "helm" {
  kubernetes {
    config_path  = "C:/Users/PierreLECLAINCHE/.kube/kubeconfig-k8s-demo-public-cloud-cpin.yaml"
#  config_context = "admin@k8s-demo-public-cloud-cpin"
  }
}