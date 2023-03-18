resource "kubernetes_deployment" "deployment_azure_vote_back" {
  metadata {
    name = "azure-vote-back"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "azure-vote-back"
      }
    }

    template {
      metadata {
        labels = {
          app = "azure-vote-back"
        }
      }

      spec {
        node_selector = {
          "beta.kubernetes.io/os" = "linux"
        }

        container {
          name = "azure-vote-back"
          image = "mcr.microsoft.com/oss/bitnami/redis:6.0.8"

          env {
            name = "ALLOW_EMPTY_PASSWORD"
            value = "yes"
          }

          port {
            name = "redis"
            container_port = 6379
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "service_azure_vote_back" {
  metadata {
    name = "azure-vote-back"
  }

  spec {
    selector = {
      app = "azure-vote-back"
    }

    port {
      port = 6379
    }
  }
}

resource "kubernetes_deployment" "deployment_azure_vote_front" {
  metadata {
    name = "azure-vote-front"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
      app = "azure-vote-front"
      }
    }

    strategy {
      rolling_update {
        max_surge = 1
        max_unavailable = 1
      }
    }

    template {
      metadata {
        labels = {
          app = "azure-vote-front"
        }
      }

      spec {
        node_selector = {
          "beta.kubernetes.io/os" = "linux"
        }

        container {
          name = "azure-vote-front"
          image = "mcr.microsoft.com/azuredocs/azure-vote-front:v1"

          env {
            name = "REDIS"
            value = "azure-vote-back"
          }

          port {
            container_port = 80
          }

          resources {
            limits = {
              cpu = "500m"
            }
            requests = {
              cpu = "250m"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "service_azure_vote_front" {
  metadata {
    name = "azure-vote-front"
  }

  spec {
    selector = {
      app = "azure-vote-front"
    }

    port {
      port = 80
    }

    type = "LoadBalancer"
  }
}
