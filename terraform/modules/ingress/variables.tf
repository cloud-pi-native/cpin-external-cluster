variable "ingress_name" {
  description = "Ingress name"
  type = string
  default = "nginx"
}

variable "ingress_namespace" {
  description = "Ingress namespace"
  type = string
  default = "nginx-cpin"
}

variable "description" {
  description = "Description"
  type = string
  default = "Ingress controller"
}

variable "values_file" {
  description = "Values file"
  type = string
}

