### Pre-configure k8s for CockroachDB

### Expose kube-dns service externally for cross cluster DNS resolution

resource "kubernetes_service_v1" "kube-dns-lb-region_1" {
    provider = kubernetes.region_1
    metadata {
      name      = "kube-dns-lb"
      namespace = "kube-system"
      annotations = {
        "service.beta.kubernetes.io/azure-load-balancer-internal" = "true"
      }
  }
  spec {
    selector = {
      k8s-app = "kube-dns"
    }
    port {
      name        = "dns"
      port        = 53
      protocol    = "UDP"
      target_port = 53
    }

    type = "LoadBalancer"
  }
}

resource "kubernetes_service_v1" "kube-dns-lb-region_2" {
    provider = kubernetes.region_2
    metadata {
      name      = "kube-dns-lb"
      namespace = "kube-system"
      annotations = {
        "service.beta.kubernetes.io/azure-load-balancer-internal" = "true"
      }
  }
  spec {
    selector = {
      k8s-app = "kube-dns"
    }
    port {
      name        = "dns"
      port        = 53
      protocol    = "UDP"
      target_port = 53
    }

    type = "LoadBalancer"
  }
}

resource "kubernetes_service_v1" "kube-dns-lb-region_3" {
    provider = kubernetes.region_3
    metadata {
      name      = "kube-dns-lb"
      namespace = "kube-system"
      annotations = {
        "service.beta.kubernetes.io/azure-load-balancer-internal" = "true"
      }
  }
  spec {
    selector = {
      k8s-app = "kube-dns"
    }
    port {
      name        = "dns"
      port        = 53
      protocol    = "UDP"
      target_port = 53
    }

    type = "LoadBalancer"
  }
}

### Create the namespaces based on the region names

resource "kubernetes_namespace_v1" "ns_region_1" {
  provider = kubernetes.region_1
  metadata {
    name = var.location_1

    annotations = {
      name = "CockroachDB Namespace"
    }

    labels = {
      app = "cockroachdb"
    }
  }
}

resource "kubernetes_namespace_v1" "ns_region_2" {
  provider = kubernetes.region_2
  metadata {
    name = var.location_2

    annotations = {
      name = "CockroachDB Namespace"
    }

    labels = {
      app = "cockroachdb"
    }
  }
}

resource "kubernetes_namespace_v1" "ns_region_3" {
  provider = kubernetes.region_3
  metadata {
    name = var.location_3

    annotations = {
      name = "CockroachDB Namespace"
    }

    labels = {
      app = "cockroachdb"
    }
  }
}

### Update the CoreDNS configuration to forward DNS request to the correct cluster.

resource "kubernetes_config_map_v1_data" "coredns-custom_region_1" {
  provider = kubernetes.region_1
  data = {
    "cockroach.server" = <<EOT
    ${var.location_2}.svc.cluster.local:53 {
        errors
        cache 30
        forward . ${kubernetes_service_v1.kube-dns-lb-region_2.status.0.load_balancer.0.ingress.0.ip} {
        }
    }
    ${var.location_3}.svc.cluster.local:53 {
        errors
        cache 30
        forward . ${kubernetes_service_v1.kube-dns-lb-region_3.status.0.load_balancer.0.ingress.0.ip}
    }
EOT
  }

  metadata {
    name      = "coredns-custom"
    namespace = "kube-system"
  }
}

resource "kubernetes_config_map_v1_data" "coredns-custom_region_2" {
  provider = kubernetes.region_2
  data = {
    "cockroach.server" = <<EOT
    ${var.location_1}.svc.cluster.local:53 {
        errors
        cache 30
        forward . ${kubernetes_service_v1.kube-dns-lb-region_1.status.0.load_balancer.0.ingress.0.ip} {
        }
    }
    ${var.location_3}.svc.cluster.local:53 {
        errors
        cache 30
        forward . ${kubernetes_service_v1.kube-dns-lb-region_3.status.0.load_balancer.0.ingress.0.ip}
    }
EOT
  }

  metadata {
    name      = "coredns-custom"
    namespace = "kube-system"
  }
}

resource "kubernetes_config_map_v1_data" "coredns-custom_region_3" {
  provider = kubernetes.region_3
  data = {
    "cockroach.server" = <<EOT
    ${var.location_2}.svc.cluster.local:53 {
        errors
        cache 30
        forward . ${kubernetes_service_v1.kube-dns-lb-region_2.status.0.load_balancer.0.ingress.0.ip} {
        }
    }
    ${var.location_1}.svc.cluster.local:53 {
        errors
        cache 30
        forward . ${kubernetes_service_v1.kube-dns-lb-region_1.status.0.load_balancer.0.ingress.0.ip}
    }
EOT
  }

  metadata {
    name      = "coredns-custom"
    namespace = "kube-system"
  }
}

### Create Certificates and upload these as secrets to each cluster

### Apply the StatefulSet manifests updated with the required regions.

### Initialize the cluster

### Expose the Admin UI externally.