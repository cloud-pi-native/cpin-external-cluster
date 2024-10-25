variable "secret_sops_base64" {
  description = "SOPS key, base64 encoded"
  type        = string
}

variable "kubeconfig" {
  description = "Path to kubeconfig file"
  type = string
}