resource "kubernetes_deployment" "sock_shop_carts" {
  metadata {
    name      = "carts"
    namespace = kubernetes_namespace.sock_shop.metadata.0.name

    labels = {
      name = "carts"
    }
  }

  spec {
    selector {
      match_labels = {
        name = "carts"
      }
    }

    replicas = 1

    template {
      metadata {
        labels = {
          name = "carts"
        }
      }

      spec {
        container {
          name  = "carts"
          image = "weaveworksdemos/carts:0.4.8"

          resources {
            limits = {
              cpu    = "300m"
              memory = "500Mi"
            }

            requests = {
              cpu    = "100m"
              memory = "200Mi"
            }
          }

          env {
            name  = "JAVA_OPTS"
            value = "-Xms64m -Xmx128m -XX:+UseG1GC -Djava.security.egd=file:/dev/urandom -Dspring.zipkin.enabled=false"
          }

          security_context {
            capabilities {
              add = ["NET_BIND_SERVICE"]
            }

            run_as_non_root      = true
            run_as_user          = 10001
            read_only_root_filesystem = true
          }

          port {
            container_port = 80
          }

          volume_mount {
            name       = "tmp-volume"
            mount_path = "/tmp"
          }
        }

        node_selector = {
          "beta.kubernetes.io/os" = "linux"
        }

        volume {
          name = "tmp-volume"

          empty_dir {
            medium = "Memory"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "sock_shop_carts" {
  metadata {
    name      = "carts"
    namespace = kubernetes_namespace.sock_shop.metadata.0.name

    labels = {
      name = "carts"
    }

    annotations = {
      "prometheus.io/scrape" = "true"
    }
  }

  spec {
    selector = {
      name = "carts"
    }

    port {
      port        = 80
      target_port = 80
    }
  }
}

resource "kubernetes_deployment" "carts-db" {
  metadata {
    name = "carts-db"
    namespace = "sock-shop"
    labels = {
      name = "carts-db"
    }
  }
  
  spec {
    replicas = 1

    selector {
      match_labels = {
        name = "carts-db"
      }
    }

    template {
      metadata {
        labels = {
          name = "carts-db"
        }
      }

      spec {
        container {
          name  = "carts-db"
          image = "mongo"
          
          port {
            name          = "mongo"
            container_port = 27017
          }

          security_context {
            capabilities {
              drop = ["all"]
              add  = ["CHOWN", "SETGID", "SETUID"]
            }
            read_only_root_filesystem = false
          }

          volume_mount {
            mount_path = "/tmp"
            name       = "tmp-volume"
          }
        }
        
        volume {
          name = "tmp-volume"
          empty_dir {
            medium = "Memory"
          }
        }

        node_selector = {
          "beta.kubernetes.io/os" = "linux"
        }
      }
    }
  }
}

resource "kubernetes_service" "carts-db" {
  metadata {
    name      = "carts-db"
    namespace = "sock-shop"
    labels = {
      name = "carts-db"
    }
  }
  
  spec {
    selector = {
      name = "carts-db"
    }
    
    port {
      port        = 27017
      target_port = 27017
    }
  }
}

resource "kubernetes_deployment" "catalogue" {
  metadata {
    name = "catalogue"
    labels = {
      name = "catalogue"
    }
    namespace = "sock-shop"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        name = "catalogue"
      }
    }

    template {
      metadata {
        labels = {
          name = "catalogue"
        }
      }

      spec {
        container {
          name  = "catalogue"
          image = "weaveworksdemos/catalogue:0.3.5"

          command = ["/app"]

          args = [
            "-port=80"
          ]

          resources {
            limits = {
              cpu    = "200m"
              memory = "200Mi"
            }

            requests = {
              cpu    = "100m"
              memory = "100Mi"
            }
          }

          port {
            name          = "http"
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "catalogue" {
  metadata {
    name = "catalogue"
    labels = {
      name = "catalogue"
    }
    namespace = "sock-shop"
    annotations = {
      "prometheus.io/scrape" = "true"
    }
  }

  spec {
    selector = {
      name = "catalogue"
    }

    port {
      port        = 80
      target_port = 80
    }
  }
}

resource "kubernetes_deployment" "catalogue_db" {
  metadata {
    name = "catalogue-db"

    labels = {
      name = "catalogue-db"
    }

    namespace = "sock-shop"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        name = "catalogue-db"
      }
    }

    template {
      metadata {
        labels = {
          name = "catalogue-db"
        }
      }

      spec {
        container {
          name = "catalogue-db"
          image = "weaveworksdemos/catalogue-db:0.3.0"

          env {
            name  = "MYSQL_ROOT_PASSWORD"
            value = "fake_password"
          }

          env {
            name  = "MYSQL_DATABASE"
            value = "socksdb"
          }

          port {
            name          = "mysql"
            container_port = 3306
          }
        }

        node_selector = {
          "beta.kubernetes.io/os" = "linux"
        }
      }
    }
  }
}

resource "kubernetes_service" "catalogue_db" {
  metadata {
    name = "catalogue-db"

    labels = {
      name = "catalogue-db"
    }

    namespace = "sock-shop"
  }

  spec {
    port {
      port       = 3306
      target_port = 3306
    }

    selector = {
      name = "catalogue-db"
    }
  }
}

resource "kubernetes_deployment" "front_end" {
  metadata {
    name = "front-end"
    namespace = "sock-shop"

    labels = {
      name = "front-end"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        name = "front-end"
      }
    }

    template {
      metadata {
        labels = {
          name = "front-end"
        }
      }

      spec {
        container {
          name  = "front-end"
          image = "weaveworksdemos/front-end:0.3.12"

          resources {
            limits = {
              cpu    = "300m"
              memory = "1000Mi"
            }

            requests = {
              cpu    = "100m"
              memory = "300Mi"
            }
          }

          port {
            container_port = 8079
          }

          env {
            name  = "SESSION_REDIS"
            value = "true"
          }

          security_context {
            run_as_non_root          = true
            run_as_user              = 10001
            capabilities {
              drop = ["all"]
            }
            read_only_root_filesystem = true
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 8079
            }

            initial_delay_seconds = 300
            period_seconds        = 3
          }

          readiness_probe {
            http_get {
              path = "/"
              port = 8079
            }

            initial_delay_seconds = 30
            period_seconds        = 3
          }
        }

        node_selector = {
          "beta.kubernetes.io/os" = "linux"
        }
      }
    }
  }
}

resource "kubernetes_service" "front_end" {
  metadata {
    name = "front-end"
    namespace = "sock-shop"

    labels = {
      name = "front-end"
    }

    annotations = {
      "prometheus.io/scrape" = "true"
    }
  }

  spec {
    type = "LoadBalancer"

    port {
      port        = 80
      target_port = 8079
      node_port   = 30001
    }

    selector = {
      name = "front-end"
    }
  }
}

resource "kubernetes_deployment" "orders" {
  metadata {
    name = "orders"
    labels = {
      name = "orders"
    }
    namespace = "sock-shop"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        name = "orders"
      }
    }

    template {
      metadata {
        labels = {
          name = "orders"
        }
      }

      spec {
        container {
          name = "orders"
          image = "weaveworksdemos/orders:0.4.7"

          env {
            name = "JAVA_OPTS"
            value = "-Xms64m -Xmx128m -XX:+UseG1GC -Djava.security.egd=file:/dev/urandom -Dspring.zipkin.enabled=false"
          }

          resources {
            limits = {
              cpu = "500m"
              memory = "500Mi"
            }

            requests = {
              cpu = "100m"
              memory = "300Mi"
            }
          }

          port {
            container_port = 80
          }

          security_context {
            run_as_non_root = true
            run_as_user = 10001

            capabilities {
              drop = ["all"]
              add = ["NET_BIND_SERVICE"]
            }

            read_only_root_filesystem = true
          }

          volume_mount {
            mount_path = "/tmp"
            name = "tmp-volume"
          }
        }

        volume {
          name = "tmp-volume"

          empty_dir {
            medium = "Memory"
          }
        }

        node_selector = {
          "beta.kubernetes.io/os" = "linux"
        }
      }
    }
  }
}

resource "kubernetes_service" "orders" {
  metadata {
    name = "orders"
    labels = {
      name = "orders"
    }
    namespace = "sock-shop"
    annotations = {
      "prometheus.io/scrape" = "true"
    }
  }

  spec {
    selector = {
      name = "orders"
    }

    port {
      port = 80
      target_port = 80
    }
  }
}

resource "kubernetes_deployment" "orders-db" {
  metadata {
    name      = "orders-db"
    namespace = "sock-shop"

    labels = {
      name = "orders-db"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        name = "orders-db"
      }
    }

    template {
      metadata {
        labels = {
          name = "orders-db"
        }
      }

      spec {
        container {
          name  = "orders-db"
          image = "mongo"

          port {
            name          = "mongo"
            container_port = 27017
          }

          security_context {
            capabilities {
              drop = ["all"]
              add  = ["CHOWN", "SETGID", "SETUID"]
            }

            read_only_root_filesystem = false
          }

          volume_mount {
            name      = "tmp-volume"
            mount_path = "/tmp"
          }
        }

        volume {
          name = "tmp-volume"

          empty_dir {
            medium = "Memory"
          }
        }

        node_selector = {
          "beta.kubernetes.io/os" = "linux"
        }
      }
    }
  }
}

resource "kubernetes_service" "orders-db" {
  metadata {
    name      = "orders-db"
    namespace = "sock-shop"

    labels = {
      name = "orders-db"
    }
  }

  spec {
    selector = {
      name = "orders-db"
    }

    port {
      name       = "mongo"
      port       = 27017
      target_port = 27017
    }
  }
}

resource "kubernetes_deployment" "payment" {
  metadata {
    name = "payment"
    labels = {
      name = "payment"
    }
    namespace = kubernetes_namespace.sock_shop.metadata[0].name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        name = "payment"
      }
    }

    template {
      metadata {
        labels = {
          name = "payment"
        }
      }

      spec {
        container {
          name  = "payment"
          image = "weaveworksdemos/payment:0.4.3"

          resources {
            limits = {
              cpu    = "200m"
              memory = "200Mi"
            }
            requests = {
              cpu    = "99m"
              memory = "100Mi"
            }
          }

          port {
            container_port = 80
          }

          security_context {
            run_as_non_root          = true
            run_as_user              = 10001
            capabilities {
              drop = ["all"]
              add  = ["NET_BIND_SERVICE"]
            }
            read_only_root_filesystem = true
          }

          liveness_probe {
            http_get {
              path   = "/health"
              port   = 80
            }
            initial_delay_seconds = 300
            period_seconds        = 3
          }

          readiness_probe {
            http_get {
              path   = "/health"
              port   = 80
            }
            initial_delay_seconds = 180
            period_seconds        = 3
          }
        }

        node_selector = {
          "beta.kubernetes.io/os" = "linux"
        }
      }
    }
  }
}

resource "kubernetes_service" "payment" {
  metadata {
    name = "payment"
    labels = {
      name = "payment"
    }
    namespace = kubernetes_namespace.sock_shop.metadata[0].name
    annotations = {
      "prometheus.io/scrape" = "true"
    }
  }

  spec {
    port {
      port        = 80
      target_port = 80
    }

    selector = {
      name = "payment"
    }
  }
}

resource "kubernetes_deployment" "rabbitmq" {
  metadata {
    name = "rabbitmq"
    labels = {
      name = "rabbitmq"
    }
    namespace = "sock-shop"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        name = "rabbitmq"
      }
    }

    template {
      metadata {
        labels = {
          name = "rabbitmq"
        }
        annotations = {
          "prometheus.io/scrape" = "false"
        }
      }

      spec {
        container {
          name = "rabbitmq"
          image = "rabbitmq:3.6.8-management"

          port {
            name = "management"
            container_port = 15672
          }

          port {
            name = "rabbitmq"
            container_port = 5672
          }

          security_context {
            capabilities {
              drop = [
                "all"
              ]
              add = [
                "CHOWN",
                "SETGID",
                "SETUID",
                "DAC_OVERRIDE"
              ]
            }
            read_only_root_filesystem = false
          }
        }

        container {
          name = "rabbitmq-exporter"
          image = "kbudde/rabbitmq-exporter"

          port {
            name = "exporter"
            container_port = 9090
          }
        }

        node_selector = {
          "beta.kubernetes.io/os" = "linux"
        }
      }
    }
  }
}

resource "kubernetes_service" "rabbitmq" {
  metadata {
    name = "rabbitmq"
    labels = {
      name = "rabbitmq"
    }
    namespace = "sock-shop"
    annotations = {
      "prometheus.io/scrape" = "true"
      "prometheus.io/port" = "9090"
    }
  }

  spec {
    port {
      name = "rabbitmq"
      port = 5672
      target_port = 5672
    }

    port {
      name = "exporter"
      port = 9090
      target_port = 9090
      protocol = "TCP"
    }

    selector = {
      name = "rabbitmq"
    }
  }
}

resource "kubernetes_deployment" "session_db" {
  metadata {
    name = "session-db"

    labels = {
      name = "session-db"
    }

    namespace = "sock-shop"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        name = "session-db"
      }
    }

    template {
      metadata {
        labels = {
          name = "session-db"
        }

        annotations = {
          "prometheus.io.scrape" = "false"
        }
      }

      spec {
        container {
          name  = "session-db"
          image = "redis:alpine"

          port {
            name          = "redis"
            container_port = 6379
          }

          security_context {
            capabilities {
              add = [
                "CHOWN",
                "SETGID",
                "SETUID"
              ]

              drop = [
                "all"
              ]
            }

            read_only_root_filesystem = false
          }
        }

        node_selector = {
          "beta.kubernetes.io/os" = "linux"
        }
      }
    }
  }
}

resource "kubernetes_service" "session_db" {
  metadata {
    name = "session-db"

    labels = {
      name = "session-db"
    }

    namespace = "sock-shop"
  }

  spec {
    port {
      port        = 6379
      target_port = 6379
    }

    selector = {
      name = "session-db"
    }
  }
}

resource "kubernetes_deployment" "shipping" {
  metadata {
    name = "shipping"
    labels = {
      name = "shipping"
    }
    namespace = kubernetes_namespace.sock_shop.metadata.0.name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        name = "shipping"
      }
    }

    template {
      metadata {
        labels = {
          name = "shipping"
        }
      }

      spec {
        container {
          name = "shipping"
          image = "weaveworksdemos/shipping:0.4.8"

          env {
            name  = "ZIPKIN"
            value = "zipkin.jaeger.svc.cluster.local"
          }

          env {
            name  = "JAVA_OPTS"
            value = "-Xms64m -Xmx128m -XX:+UseG1GC -Djava.security.egd=file:/dev/urandom -Dspring.zipkin.enabled=false"
          }

          resources {
            limits = {
              cpu    = "300m"
              memory = "500Mi"
            }

            requests = {
              cpu    = "100m"
              memory = "300Mi"
            }
          }

          port {
            container_port = 80
          }

          security_context {
            run_as_non_root        = true
            run_as_user            = 10001
            capabilities {
              drop = ["all"]
              add  = ["NET_BIND_SERVICE"]
            }
            read_only_root_filesystem = true
          }

          volume_mount {
            mount_path = "/tmp"
            name       = "tmp-volume"
          }
        }

        volume {
          name = "tmp-volume"
          empty_dir {
            medium = "Memory"
          }
        }

        node_selector = {
          "beta.kubernetes.io/os" = "linux"
        }
      }
    }
  }
}

resource "kubernetes_service" "shipping" {
  metadata {
    name = "shipping"
    labels = {
      name = "shipping"
    }
    annotations = {
      "prometheus.io/scrape" = "true"
    }
    namespace = kubernetes_namespace.sock_shop.metadata.0.name
  }

  spec {
    port {
      port        = 80
      target_port = 80
    }

    selector = {
      name = "shipping"
    }
  }
}

resource "kubernetes_deployment" "user" {
  metadata {
    name = "user"
    labels = {
      name = "user"
    }
    namespace = kubernetes_namespace.sock_shop.metadata.0.name
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        name = "user"
      }
    }

    template {
      metadata {
        labels = {
          name = "user"
        }
      }

      spec {
        node_selector = {
          "beta.kubernetes.io/os" = "linux"
        }

        container {
          name = "user"
          image = "weaveworksdemos/user:0.4.7"
          port {
            container_port = 80
          }
          env {
            name  = "mongo"
            value = "user-db:27017"
          }
          resources {
            limits = {
              cpu    = "300m"
              memory = "200Mi"
            }
            requests = {
              cpu    = "100m"
              memory = "100Mi"
            }
          }
          security_context {
            run_as_non_root          = true
            run_as_user              = 10001
            capabilities {
              drop = ["all"]
              add  = ["NET_BIND_SERVICE"]
            }
            read_only_root_filesystem = true
          }
          liveness_probe {
            http_get {
              path = "/health"
              port = 80
            }
            initial_delay_seconds = 300
            period_seconds        = 3
          }
          readiness_probe {
            http_get {
              path = "/health"
              port = 80
            }
            initial_delay_seconds = 180
            period_seconds        = 3
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "user" {
  metadata {
    name = "user"
    labels = {
      name = "user"
    }
    namespace = kubernetes_namespace.sock_shop.metadata.0.name

    annotations = {
      "prometheus.io/scrape" = "true"
    }
  }

  spec {
    selector = {
      name = "user"
    }

    port {
      port        = 80
      target_port = 80
    }
  }
}

resource "kubernetes_deployment" "user_db" {
  metadata {
    name      = "user-db"
    namespace = "sock-shop"

    labels = {
      name = "user-db"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        name = "user-db"
      }
    }

    template {
      metadata {
        labels = {
          name = "user-db"
        }
      }

      spec {
        container {
          name  = "user-db"
          image = "weaveworksdemos/user-db:0.3.0"

          port {
            name          = "mongo"
            container_port = 27017
          }

          security_context {
            capabilities {
              add = [
                "CHOWN",
                "SETGID",
                "SETUID",
              ]
              drop = [
                "all",
              ]
            }
            read_only_root_filesystem = false
          }

          volume_mount {
            mount_path = "/tmp"
            name       = "tmp-volume"
          }
        }

        volume {
          name = "tmp-volume"

          empty_dir {
            medium = "Memory"
          }
        }

        node_selector = {
          "beta.kubernetes.io/os" = "linux"
        }
      }
    }
  }
}

resource "kubernetes_service" "user_db" {
  metadata {
    name      = "user-db"
    namespace = "sock-shop"

    labels = {
      name = "user-db"
    }
  }

  spec {
    port {
      name        = "mongo"
      port        = 27017
      target_port = 27017
    }

    selector = {
      name = "user-db"
    }
  }
}
