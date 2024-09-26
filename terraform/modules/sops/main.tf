resource "kubernetes_namespace" "sops-system" {
  metadata {
    name = var.sops_namespace
  }
}

# Créer un secret Kubernetes
resource "kubernetes_secret" "sops-key-secret" {
  metadata {
    name      = "sops-age-key-file"
    namespace = var.sops_namespace
  }
  data = {
    key-sops-pic = base64decode(var.secret_sops_base64) 
  }

  type = "Opaque"  # Type du secret Kubernetes
}

resource "helm_release" "sops-secret-operator" {
  name             = "sops-secrets-operator"
  namespace        = var.sops_namespace
  version          = var.sops_version
  create_namespace = true
  repository       = "https://isindir.github.io/sops-secrets-operator/"
  chart            = "sops-secrets-operator"

  set {
      name  = "secretsAsFiles[0].mountPath"
      value = "/etc/sops-age-key-file"
    }

  set {
    name  = "secretsAsFiles[0].name"
    value = "sops-age-key-file"
  }

  set {
    name  = "secretsAsFiles[0].secretName"
    value = "sops-age-key-file"
  }

  set {
    name  = "extraEnv[0].name"
    value = "SOPS_AGE_KEY_FILE"
  }

  set {
    name  = "extraEnv[0].value"
    value = "/etc/sops-age-key-file/key-sops-pic"
  }
  depends_on = [kubernetes_secret.sops-key-secret]
}