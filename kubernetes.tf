####################################
# Kubernetes Pre-configuration     #
####################################

### Expose kube-dns service externally for cross cluster DNS resolution

# DNS Exposed via LoadBalancer in first region

resource "kubernetes_service_v1" "kube-dns-lb-region_1" {
    provider = kubernetes.region_1
    depends_on = [azurerm_virtual_network_peering.peer1to2, azurerm_virtual_network_peering.peer2to1]
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

# DNS Exposed via LoadBalancer in second region

resource "kubernetes_service_v1" "kube-dns-lb-region_2" {
    provider = kubernetes.region_2
    depends_on = [azurerm_virtual_network_peering.peer2to3, azurerm_virtual_network_peering.peer3to2]
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

# DNS Exposed via LoadBalancer in third region

resource "kubernetes_service_v1" "kube-dns-lb-region_3" {
    provider = kubernetes.region_3
    depends_on = [azurerm_virtual_network_peering.peer1to3, azurerm_virtual_network_peering.peer3to1]
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

### Update the CoreDNS configuration to forward DNS request to the correct cluster.

# Replace the coredns-custom config map updated configuration to first region

resource "kubernetes_config_map_v1_data" "coredns-custom_region_1" {
  provider = kubernetes.region_1
  depends_on = [kubernetes_service_v1.kube-dns-lb-region_1]
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

# Replace the coredns-custom config map updated configuration to second region

resource "kubernetes_config_map_v1_data" "coredns-custom_region_2" {
  provider = kubernetes.region_2
  depends_on = [kubernetes_service_v1.kube-dns-lb-region_2]
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

# Replace the coredns-custom config map updated configuration to third region

resource "kubernetes_config_map_v1_data" "coredns-custom_region_3" {
  provider = kubernetes.region_3
  depends_on = [kubernetes_service_v1.kube-dns-lb-region_3]
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

