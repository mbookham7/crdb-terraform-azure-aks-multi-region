### Apply the StatefulSet manifests updated with the required regions.

# Region 1

resource "kubernetes_service_account_v1" "serviceaccount_cockroachdb_region_1" {
  provider = kubernetes.region_1
  depends_on = [kubernetes_namespace_v1.ns_region_1]
  metadata {
    name = "cockroachdb"

    labels = {
      app = "cockroachdb"
    }
    namespace = var.location_1
  }
}

resource "kubernetes_role_v1" "role_cockroachdb_region_1" {
  provider = kubernetes.region_1
  depends_on = [kubernetes_namespace_v1.ns_region_1]
  metadata {
    name = "cockroachdb"

    labels = {
      app = "cockroachdb"
    }
  }

  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["get", "create"]
  }
}

resource "kubernetes_cluster_role_v1" "clusterrole_cockroachdb_region_1" {
  provider = kubernetes.region_1
  depends_on = [kubernetes_namespace_v1.ns_region_1] 
  metadata {
    name = "cockroachdb"
    labels = {
      app = "cockroachdb"
    }
  }

  rule {
    api_groups = ["certificates.k8s.io"]
    resources  = ["certificatesigningrequests"]
    verbs      = ["get", "create", "watch"]
  }
}

resource "kubernetes_role_binding_v1" "rolebinding_cockroachdb_region_1" {
  provider = kubernetes.region_1
  depends_on = [kubernetes_namespace_v1.ns_region_1]
  metadata {
    name      = "cockroachdb"
    namespace = var.location_1
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "cockroachdb"
  }
  subject {
    kind      = "User"
    name      = "admin"
    api_group = "rbac.authorization.k8s.io"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "cockroachdbdefault"
    namespace = var.location_1
  }
}

resource "kubernetes_cluster_role_binding_v1" "clusterrolebinding_cockroachdb_region_1" {
  provider = kubernetes.region_1
  depends_on = [kubernetes_namespace_v1.ns_region_1]
  metadata {
    name = "cockroachdb"
    labels = {
      app = "cockroachdb"
    }
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cockroachdb"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "cockroachdb"
    namespace = var.location_1
  }
  subject {
    kind      = "Group"
    name      = "system:masters"
    api_group = "rbac.authorization.k8s.io"
  }
}

resource "kubernetes_service" "service_cockroachdb_public_region_1" {
  provider = kubernetes.region_1
  depends_on = [kubernetes_namespace_v1.ns_region_1]
  metadata {
    name = "cockroachdb-public"
    labels = {
      app = "cockroachdb"
    }
    namespace = var.location_1
  }
  spec {
    selector = {
      app = "cockroachdb"
    }
    port {
      name        = "grpc"
      port        = 26257
      target_port = 26257
    }
    port {
      name        = "http"
      port        = 8080
      target_port = 8080
    }
  }
}

resource "kubernetes_service" "service_cockroachdb_region_1" {
  provider = kubernetes.region_1
  depends_on = [kubernetes_namespace_v1.ns_region_1]
  metadata {
    name = "cockroachdb"
    labels = {
      app = "cockroachdb"
    }
    annotations = {
        "prometheus.io/path" = "_status/vars"
        "prometheus.io/port" = "8080"
        "prometheus.io/scrape" = "true"
        "service.alpha.kubernetes.io/tolerate-unready-endpoints" = "true"
    }
    namespace = var.location_1
  }
  spec {
    selector = {
      app = "cockroachdb"
    }
    port {
      name        = "grpc"
      port        = 26257
      target_port = 26257
    }
    port {
      name        = "http"
      port        = 8080
      target_port = 8080
    }
    type = "ClusterIP"
    publish_not_ready_addresses = "true"
  }
}

resource "kubernetes_pod_disruption_budget_v1" "poddisruptionbudget_cockroachdb_budget_region_1" {
  provider = kubernetes.region_1
  depends_on = [kubernetes_namespace_v1.ns_region_1]
  metadata {
    name = "cockroachdb-budget"
    labels = {
      app = "cockroachdb"
    }
    namespace = var.location_1
  }
  spec {
    max_unavailable = 1
    selector {
      match_labels = {
        app = "cockroachdb"
      }
    }
  }
}

resource "kubernetes_stateful_set_v1" "statefulset_region_1_cockroachdb" {
  provider = kubernetes.region_1
  depends_on = [kubernetes_namespace_v1.ns_region_1]
  metadata {
    annotations = {
      SomeAnnotation = "foobar"
    }

    labels = {
    }

    name = "cockroachdb"
    namespace = var.location_1
  }

  spec {
    pod_management_policy  = "Parallel"
    replicas               = 3

    selector {
      match_labels = {
        app = "cockroachdb"
      }
    }

    service_name = "cockroachdb"

    template {
      metadata {
        labels = {
          app = "cockroachdb"
        }

        annotations = {}
      }

      spec {

        affinity {
          pod_anti_affinity {
              preferred_during_scheduling_ignored_during_execution {
                weight = 100 

                pod_affinity_term {
                  label_selector {
                    match_expressions {
                      key      = "app"
                      operator = "In"
                      values   = ["cockroachdb"]
                    }
                  }
                  topology_key = "kubernetes.io/hostname"
                }
              }
            }
        }

        container {
          command = [
            "/bin/bash",
            "-ecx",
            "exec /cockroach/cockroach start --logtostderr --certs-dir /cockroach/cockroach-certs --advertise-host $(hostname -f) --http-addr 0.0.0.0 --join cockroachdb-0.cockroachdb.${var.location_1},cockroachdb-1.cockroachdb.${var.location_1},cockroachdb-2.cockroachdb.${var.location_1},cockroachdb-0.cockroachdb.${var.location_2},cockroachdb-1.cockroachdb.${var.location_2},cockroachdb-2.cockroachdb.${var.location_2},cockroachdb-0.cockroachdb.${var.location_3},cockroachdb-1.cockroachdb.${var.location_3}e,cockroachdb-2.cockroachdb.${var.location_3} --locality=cloud=azure,region=azure-${var.location_1} --cache $(expr $MEMORY_LIMIT_MIB / 4)MiB --max-sql-memory $(expr $MEMORY_LIMIT_MIB / 4)MiB",
            ]

          env {
            name = "COCKROACH_CHANNEL"
            value = "kubernetes-multiregion"            
          }

          env {
            name = "GOMAXPROCS"


            value_from {
              resource_field_ref {
                divisor = 1
                resource = "limits.cpu"
              }
            }
          }

          env {
            name = "MEMORY_LIMIT_MIB"


            value_from {
              resource_field_ref {
                divisor = "1Mi"
                resource = "limits.memory"
              }
            }           
          }

          name              = "cockroachdb"
          image             = "cockroachdb/cockroach:v23.1.2"
          image_pull_policy = "IfNotPresent"

          port {
            name = "grcp"
            container_port = 26257
          }
          port {
            name = "http"
            container_port = 8080
          }

          readiness_probe {
            failure_threshold = 2
              http_get {
                path = "/health?ready=1"
                port = "http"
                scheme = "HTTPS"
              }

            initial_delay_seconds = 10
            period_seconds = 5
          }

          resources {
            limits = {
              cpu    = "4"
              memory = "8Gi"
            }

            requests = {
              cpu    = "4"
              memory = "8Gi"
            }
          }
        
          volume_mount {
            name       = "datadir"
            mount_path = "/cockroach/cockroach-data"
          }

          volume_mount {
            name       = "certs"
            mount_path = "/cockroach/cockroach-certs"
          }

          volume_mount {
            name       = "cockroach-env"
            mount_path = "/etc/cockroach-env"
          }
        }


        service_account_name = "cockroachdb"

        termination_grace_period_seconds = 60

        volume {
          name = "datadir"

          persistent_volume_claim {
            claim_name = "datadir"
          }
        }
        volume {
          name = "certs"

          secret {
            default_mode = "0400"
            secret_name = "cockroachdb.node"
          }
        }
        volume {
          name = "cockroach-env"
          empty_dir {}
        }
      }
    }

    update_strategy {
      type = "RollingUpdate"

      rolling_update {
        partition = 1
      }
    }

    volume_claim_template {
      metadata {
        name = "datadir"
      }

      spec {
        access_modes       = ["ReadWriteOnce"]

        resources {
          requests = {
            storage = "50Gi"
          }
        }
      }
    }
  }
}

# Region 2

resource "kubernetes_service_account_v1" "serviceaccount_cockroachdb_region_2" {
  provider = kubernetes.region_2
  depends_on = [kubernetes_namespace_v1.ns_region_2]
  metadata {
    name = "cockroachdb"

    labels = {
      app = "cockroachdb"
    }
    namespace = var.location_2
  }
}

resource "kubernetes_role_v1" "role_cockroachdb_region_2" {
  provider = kubernetes.region_2
  depends_on = [kubernetes_namespace_v1.ns_region_2]
  metadata {
    name = "cockroachdb"

    labels = {
      app = "cockroachdb"
    }
  }

  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["get", "create"]
  }
}

resource "kubernetes_cluster_role_v1" "clusterrole_cockroachdb_region_2" {
  provider = kubernetes.region_2
  depends_on = [kubernetes_namespace_v1.ns_region_2]
  metadata {
    name = "cockroachdb"
    labels = {
      app = "cockroachdb"
    }
  }

  rule {
    api_groups = ["certificates.k8s.io"]
    resources  = ["certificatesigningrequests"]
    verbs      = ["get", "create", "watch"]
  }
}

resource "kubernetes_role_binding_v1" "rolebinding_cockroachdb_region_2" {
  provider = kubernetes.region_2
  depends_on = [kubernetes_namespace_v1.ns_region_2]
  metadata {
    name      = "cockroachdb"
    namespace = var.location_2
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "cockroachdb"
  }
  subject {
    kind      = "User"
    name      = "admin"
    api_group = "rbac.authorization.k8s.io"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "cockroachdbdefault"
    namespace = var.location_2
  }
}

resource "kubernetes_cluster_role_binding_v1" "clusterrolebinding_cockroachdb_region_2" {
  provider = kubernetes.region_2
  depends_on = [kubernetes_namespace_v1.ns_region_2]
  metadata {
    name = "cockroachdb"
    labels = {
      app = "cockroachdb"
    }
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cockroachdb"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "cockroachdb"
    namespace = var.location_2
  }
  subject {
    kind      = "Group"
    name      = "system:masters"
    api_group = "rbac.authorization.k8s.io"
  }
}

resource "kubernetes_service" "service_cockroachdb_public_region_2" {
  provider = kubernetes.region_2
  depends_on = [kubernetes_namespace_v1.ns_region_2]
  metadata {
    name = "cockroachdb-public"
    labels = {
      app = "cockroachdb"
    }
    namespace = var.location_2
  }
  spec {
    selector = {
      app = "cockroachdb"
    }
    port {
      name        = "grpc"
      port        = 26257
      target_port = 26257
    }
    port {
      name        = "http"
      port        = 8080
      target_port = 8080
    }
  }
}

resource "kubernetes_service" "service_cockroachdb_region_2" {
  provider = kubernetes.region_2
  depends_on = [kubernetes_namespace_v1.ns_region_2]
  metadata {
    name = "cockroachdb"
    labels = {
      app = "cockroachdb"
    }
    annotations = {
        "prometheus.io/path" = "_status/vars"
        "prometheus.io/port" = "8080"
        "prometheus.io/scrape" = "true"
        "service.alpha.kubernetes.io/tolerate-unready-endpoints" = "true"
    }
    namespace = var.location_2
  }
  spec {
    selector = {
      app = "cockroachdb"
    }
    port {
      name        = "grpc"
      port        = 26257
      target_port = 26257
    }
    port {
      name        = "http"
      port        = 8080
      target_port = 8080
    }
    type = "ClusterIP"
    publish_not_ready_addresses = "true"
  }
}

resource "kubernetes_pod_disruption_budget_v1" "poddisruptionbudget_cockroachdb_budget_region_2" {
  provider = kubernetes.region_2
  depends_on = [kubernetes_namespace_v1.ns_region_2]
  metadata {
    name = "cockroachdb-budget"
    labels = {
      app = "cockroachdb"
    }
    namespace = var.location_2
  }
  spec {
    max_unavailable = 1
    selector {
      match_labels = {
        app = "cockroachdb"
      }
    }
  }
}

resource "kubernetes_stateful_set_v1" "statefulset_region_2_cockroachdb" {
  depends_on = [kubernetes_namespace_v1.ns_region_2]
  provider = kubernetes.region_2
  metadata {
    annotations = {
      SomeAnnotation = "foobar"
    }

    labels = {
    }

    name = "cockroachdb"
    namespace = var.location_2
  }

  spec {
    pod_management_policy  = "Parallel"
    replicas               = 3

    selector {
      match_labels = {
        app = "cockroachdb"
      }
    }

    service_name = "cockroachdb"

    template {
      metadata {
        labels = {
          app = "cockroachdb"
        }

        annotations = {}
      }

      spec {

        affinity {
          pod_anti_affinity {
              preferred_during_scheduling_ignored_during_execution {
                weight = 100 

                pod_affinity_term {
                  label_selector {
                    match_expressions {
                      key      = "app"
                      operator = "In"
                      values   = ["cockroachdb"]
                    }
                  }
                  topology_key = "kubernetes.io/hostname"
                }
              }
            }
        }

        container {
          command = [
            "/bin/bash",
            "-ecx",
            "exec /cockroach/cockroach start --logtostderr --certs-dir /cockroach/cockroach-certs --advertise-host $(hostname -f) --http-addr 0.0.0.0 --join cockroachdb-0.cockroachdb.${var.location_1},cockroachdb-1.cockroachdb.${var.location_1},cockroachdb-2.cockroachdb.${var.location_1},cockroachdb-0.cockroachdb.${var.location_2},cockroachdb-1.cockroachdb.${var.location_2},cockroachdb-2.cockroachdb.${var.location_2},cockroachdb-0.cockroachdb.${var.location_3},cockroachdb-1.cockroachdb.${var.location_3}e,cockroachdb-2.cockroachdb.${var.location_3} --locality=cloud=azure,region=azure-${var.location_2} --cache $(expr $MEMORY_LIMIT_MIB / 4)MiB --max-sql-memory $(expr $MEMORY_LIMIT_MIB / 4)MiB",
            ]

          env {
            name = "COCKROACH_CHANNEL"
            value = "kubernetes-multiregion"            
          }

          env {
            name = "GOMAXPROCS"


            value_from {
              resource_field_ref {
                divisor = 1
                resource = "limits.cpu"
              }
            }
          }

          env {
            name = "MEMORY_LIMIT_MIB"


            value_from {
              resource_field_ref {
                divisor = "1Mi"
                resource = "limits.memory"
              }
            }           
          }

          name              = "cockroachdb"
          image             = "cockroachdb/cockroach:v23.1.2"
          image_pull_policy = "IfNotPresent"

          port {
            name = "grcp"
            container_port = 26257
          }
          port {
            name = "http"
            container_port = 8080
          }

          readiness_probe {
            failure_threshold = 2
              http_get {
                path = "/health?ready=1"
                port = "http"
                scheme = "HTTPS"
              }

            initial_delay_seconds = 10
            period_seconds = 5
          }

          resources {
            limits = {
              cpu    = "4"
              memory = "8Gi"
            }

            requests = {
              cpu    = "4"
              memory = "8Gi"
            }
          }
        
          volume_mount {
            name       = "datadir"
            mount_path = "/cockroach/cockroach-data"
          }

          volume_mount {
            name       = "certs"
            mount_path = "/cockroach/cockroach-certs"
          }

          volume_mount {
            name       = "cockroach-env"
            mount_path = "/etc/cockroach-env"
          }
        }


        service_account_name = "cockroachdb"

        termination_grace_period_seconds = 60

        volume {
          name = "datadir"

          persistent_volume_claim {
            claim_name = "datadir"
          }
        }
        volume {
          name = "certs"

          secret {
            default_mode = "0400"
            secret_name = "cockroachdb.node"
          }
        }
        volume {
          name = "cockroach-env"
          empty_dir {}
        }
      }
    }

    update_strategy {
      type = "RollingUpdate"

      rolling_update {
        partition = 1
      }
    }

    volume_claim_template {
      metadata {
        name = "datadir"
      }

      spec {
        access_modes       = ["ReadWriteOnce"]

        resources {
          requests = {
            storage = "50Gi"
          }
        }
      }
    }
  }
}

# Region 3

resource "kubernetes_service_account_v1" "serviceaccount_cockroachdb_region_3" {
  provider = kubernetes.region_3
  depends_on = [kubernetes_namespace_v1.ns_region_3]
  metadata {
    name = "cockroachdb"

    labels = {
      app = "cockroachdb"
    }
    namespace = var.location_3
  }
}

resource "kubernetes_role_v1" "role_cockroachdb_region_3" {
  provider = kubernetes.region_3
  depends_on = [kubernetes_namespace_v1.ns_region_3]
  metadata {
    name = "cockroachdb"

    labels = {
      app = "cockroachdb"
    }
  }

  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["get", "create"]
  }
}

resource "kubernetes_cluster_role_v1" "clusterrole_cockroachdb_region_3" {
  provider = kubernetes.region_3
  depends_on = [kubernetes_namespace_v1.ns_region_3]
  metadata {
    name = "cockroachdb"
    labels = {
      app = "cockroachdb"
    }
  }

  rule {
    api_groups = ["certificates.k8s.io"]
    resources  = ["certificatesigningrequests"]
    verbs      = ["get", "create", "watch"]
  }
}

resource "kubernetes_role_binding_v1" "rolebinding_cockroachdb_region_3" {
  provider = kubernetes.region_3
  depends_on = [kubernetes_namespace_v1.ns_region_3]
  metadata {
    name      = "cockroachdb"
    namespace = var.location_3
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "cockroachdb"
  }
  subject {
    kind      = "User"
    name      = "admin"
    api_group = "rbac.authorization.k8s.io"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "cockroachdbdefault"
    namespace = var.location_3
  }
}

resource "kubernetes_cluster_role_binding_v1" "clusterrolebinding_cockroachdb_region_3" {
  provider = kubernetes.region_3
  depends_on = [kubernetes_namespace_v1.ns_region_3]
  metadata {
    name = "cockroachdb"
    labels = {
      app = "cockroachdb"
    }
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cockroachdb"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "cockroachdb"
    namespace = var.location_3
  }
  subject {
    kind      = "Group"
    name      = "system:masters"
    api_group = "rbac.authorization.k8s.io"
  }
}

resource "kubernetes_service" "service_cockroachdb_public_region_3" {
  provider = kubernetes.region_3
  depends_on = [kubernetes_namespace_v1.ns_region_3]
  metadata {
    name = "cockroachdb-public"
    labels = {
      app = "cockroachdb"
    }
    namespace = var.location_3
  }
  spec {
    selector = {
      app = "cockroachdb"
    }
    port {
      name        = "grpc"
      port        = 26257
      target_port = 26257
    }
    port {
      name        = "http"
      port        = 8080
      target_port = 8080
    }
  }
}

resource "kubernetes_service" "service_cockroachdb_region_3" {
  provider = kubernetes.region_3
  depends_on = [kubernetes_namespace_v1.ns_region_3]
  metadata {
    name = "cockroachdb"
    labels = {
      app = "cockroachdb"
    }
    annotations = {
        "prometheus.io/path" = "_status/vars"
        "prometheus.io/port" = "8080"
        "prometheus.io/scrape" = "true"
        "service.alpha.kubernetes.io/tolerate-unready-endpoints" = "true"
    }
    namespace = var.location_3
  }
  spec {
    selector = {
      app = "cockroachdb"
    }
    port {
      name        = "grpc"
      port        = 26257
      target_port = 26257
    }
    port {
      name        = "http"
      port        = 8080
      target_port = 8080
    }
    type = "ClusterIP"
    publish_not_ready_addresses = "true"
  }
}

resource "kubernetes_pod_disruption_budget_v1" "poddisruptionbudget_cockroachdb_budget_region_3" {
  provider = kubernetes.region_3
  depends_on = [kubernetes_namespace_v1.ns_region_3]
  metadata {
    name = "cockroachdb-budget"
    labels = {
      app = "cockroachdb"
    }
    namespace = var.location_3
  }
  spec {
    max_unavailable = 1
    selector {
      match_labels = {
        app = "cockroachdb"
      }
    }
  }
}

resource "kubernetes_stateful_set_v1" "statefulset_region_3_cockroachdb" {
  provider = kubernetes.region_3
  depends_on = [kubernetes_namespace_v1.ns_region_3]
  metadata {
    annotations = {
      SomeAnnotation = "foobar"
    }

    labels = {
    }

    name = "cockroachdb"
    namespace = var.location_3
  }

  spec {
    pod_management_policy  = "Parallel"
    replicas               = 3

    selector {
      match_labels = {
        app = "cockroachdb"
      }
    }

    service_name = "cockroachdb"

    template {
      metadata {
        labels = {
          app = "cockroachdb"
        }

        annotations = {}
      }

      spec {

        affinity {
          pod_anti_affinity {
              preferred_during_scheduling_ignored_during_execution {
                weight = 100 

                pod_affinity_term {
                  label_selector {
                    match_expressions {
                      key      = "app"
                      operator = "In"
                      values   = ["cockroachdb"]
                    }
                  }
                  topology_key = "kubernetes.io/hostname"
                }
              }
            }
        }

        container {
          command = [
            "/bin/bash",
            "-ecx",
            "exec /cockroach/cockroach start --logtostderr --certs-dir /cockroach/cockroach-certs --advertise-host $(hostname -f) --http-addr 0.0.0.0 --join cockroachdb-0.cockroachdb.${var.location_1},cockroachdb-1.cockroachdb.${var.location_1},cockroachdb-2.cockroachdb.${var.location_1},cockroachdb-0.cockroachdb.${var.location_2},cockroachdb-1.cockroachdb.${var.location_2},cockroachdb-2.cockroachdb.${var.location_2},cockroachdb-0.cockroachdb.${var.location_3},cockroachdb-1.cockroachdb.${var.location_3}e,cockroachdb-2.cockroachdb.${var.location_3} --locality=cloud=azure,region=azure-${var.location_3} --cache $(expr $MEMORY_LIMIT_MIB / 4)MiB --max-sql-memory $(expr $MEMORY_LIMIT_MIB / 4)MiB",
            ]

          env {
            name = "COCKROACH_CHANNEL"
            value = "kubernetes-multiregion"            
          }

          env {
            name = "GOMAXPROCS"


            value_from {
              resource_field_ref {
                divisor = 1
                resource = "limits.cpu"
              }
            }
          }

          env {
            name = "MEMORY_LIMIT_MIB"


            value_from {
              resource_field_ref {
                divisor = "1Mi"
                resource = "limits.memory"
              }
            }           
          }

          name              = "cockroachdb"
          image             = "cockroachdb/cockroach:v23.1.2"
          image_pull_policy = "IfNotPresent"

          port {
            name = "grcp"
            container_port = 26257
          }
          port {
            name = "http"
            container_port = 8080
          }

          readiness_probe {
            failure_threshold = 2
              http_get {
                path = "/health?ready=1"
                port = "http"
                scheme = "HTTPS"
              }

            initial_delay_seconds = 10
            period_seconds = 5
          }

          resources {
            limits = {
              cpu    = "4"
              memory = "8Gi"
            }

            requests = {
              cpu    = "4"
              memory = "8Gi"
            }
          }
        
          volume_mount {
            name       = "datadir"
            mount_path = "/cockroach/cockroach-data"
          }

          volume_mount {
            name       = "certs"
            mount_path = "/cockroach/cockroach-certs"
          }

          volume_mount {
            name       = "cockroach-env"
            mount_path = "/etc/cockroach-env"
          }
        }


        service_account_name = "cockroachdb"

        termination_grace_period_seconds = 60

        volume {
          name = "datadir"

          persistent_volume_claim {
            claim_name = "datadir"
          }
        }
        volume {
          name = "certs"

          secret {
            default_mode = "0400"
            secret_name = "cockroachdb.node"
          }
        }
        volume {
          name = "cockroach-env"
          empty_dir {}
        }
      }
    }

    update_strategy {
      type = "RollingUpdate"

      rolling_update {
        partition = 1
      }
    }

    volume_claim_template {
      metadata {
        name = "datadir"
      }

      spec {
        access_modes       = ["ReadWriteOnce"]

        resources {
          requests = {
            storage = "50Gi"
          }
        }
      }
    }
  }
}

### Expose the Admin UI externally.

resource "kubernetes_service" "service_cockroachdb_ui_region_1" {
  provider = kubernetes.region_1
  depends_on = [kubernetes_namespace_v1.ns_region_1]
  metadata {
    name = "cockroachdb-adminui"
    labels = {
      app = "cockroachdb"
    }
    namespace = var.location_1
  }
  spec {
    selector = {
      app = "cockroachdb"
    }
    port {
      name        = "http"
      port        = 8080
      target_port = 8080
    }
        type = "LoadBalancer"
  }
}

resource "kubernetes_service" "service_cockroachdb_ui_region_2" {
  provider = kubernetes.region_2
  depends_on = [kubernetes_namespace_v1.ns_region_2]
  metadata {
    name = "cockroachdb-adminui"
    labels = {
      app = "cockroachdb"
    }
    namespace = var.location_2
  }
  spec {
    selector = {
      app = "cockroachdb"
    }
    port {
      name        = "http"
      port        = 8080
      target_port = 8080
    }
        type = "LoadBalancer"
  }
}

resource "kubernetes_service" "service_cockroachdb_ui_region_3" {
  provider = kubernetes.region_3
  depends_on = [kubernetes_namespace_v1.ns_region_3]
  metadata {
    name = "cockroachdb-adminui"
    labels = {
      app = "cockroachdb"
    }
    namespace = var.location_3
  }
  spec {
    selector = {
      app = "cockroachdb"
    }
    port {
      name        = "http"
      port        = 8080
      target_port = 8080
    }
        type = "LoadBalancer"
  }
}
