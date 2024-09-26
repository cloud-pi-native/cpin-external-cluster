variable "secret_sops_base64" {
  description = "SOPS key, base64 encoded"
  type        = string
}

variable "sops_namespace" {
  description = "namespace for sops"
  type        = string
  default     = "sops-system"
}

variable "sops_version" {
  description = "Version of sops"
  type        = string
  default     = "v0.19.4"
}
