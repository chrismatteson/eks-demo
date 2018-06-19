provider "kubernetes" {
  config_context_auth_info = "default-system"
  config_context_cluster   = "terraform-eks-demo"
}

resource "kubernetes_namespace" "example" {
  metadata {
    name = "my-first-namespace"
  }
}

resource "kubernetes_pod" "nginx" {
  metadata {
    name = "nginx"
  }

  spec {
    container {
      image = "nginx:1.7.9"
      name  = "nginx"

      port {
        container_port = 80
      }
    }
  }
}

