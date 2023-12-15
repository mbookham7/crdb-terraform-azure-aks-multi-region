resource "time_sleep" "wait_120_seconds" {
  depends_on = [kubernetes_service.service_cockroachdb_public_region_1, kubernetes_namespace_v1.ns_region_1 ]
  create_duration = "120s"
}

resource "kubernetes_job_v1" "cockroachdb_init_job" {
  depends_on = [time_sleep.wait_120_seconds]
  provider = kubernetes.region_1
    metadata {
      name = "cockroachdb-client-secure"

      labels = {
        app = "cockroachdb-client"
      }
      
      namespace = var.location_1
    }
    spec {
      template {
      metadata {}
        spec {
          container {
            command = ["/cockroach/cockroach", "init", "--certs-dir=/cockroach-certs", "--host=cockroachdb-0.cockroachdb.${var.location_1}"]
            image = "cockroachdb/cockroach:${var.cockroachdb_version}"
            image_pull_policy  = "IfNotPresent"
            name = "cockroachdb-client"
            volume_mount {
                mount_path = "/cockroach-certs"
                name = "client-certs"
            }
        }
          service_account_name = "cockroachdb"
          termination_grace_period_seconds = 0
          volume {
            name = "client-certs"
            secret {
              default_mode = "0400"
              secret_name = "cockroachdb.client.root"
            }
          }
        }
      }
    }
}