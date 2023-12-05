#######################################################################
# Create Certificates and upload these as secrets to each cluster     #
#######################################################################

# Create a CA Certificate and Key

# Key
resource "tls_private_key" "ca_private_key" {
  algorithm = "RSA"
}

resource "local_file" "ca_key" {
  content  = tls_private_key.ca_private_key.private_key_pem
  filename = "${path.module}/my-safe-directory/ca.key"
}

# Certificate

resource "tls_self_signed_cert" "ca_cert" {
  private_key_pem = tls_private_key.ca_private_key.private_key_pem

  is_ca_certificate = true

  subject {
    common_name         = "Cockroach CA"
    organization        = "Cockroach"
  }

  validity_period_hours = 8760 //  365 days or 1 years

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "client_auth",
    "server_auth",
    "cert_signing",
    "crl_signing",
  ]
}

# Output as a file for retention

resource "local_file" "ca_cert" {
  content  = tls_self_signed_cert.ca_cert.cert_pem
  filename = "${path.module}/certs/ca.crt"
}

resource "local_file" "ca_cert_region_1" {
  content  = tls_self_signed_cert.ca_cert.cert_pem
  filename = "${path.module}/${var.location_1}/certs/ca.crt"
}


resource "local_file" "ca_cert_region_2" {
  content  = tls_self_signed_cert.ca_cert.cert_pem
  filename = "${path.module}/${var.location_2}/certs/ca.crt"
}

resource "local_file" "ca_cert_region_3" {
  content  = tls_self_signed_cert.ca_cert.cert_pem
  filename = "${path.module}/${var.location_3}/certs/ca.crt"
}

# Create a Client certificate and ket for the first user

# Key
resource "tls_private_key" "client_private_key" {
  algorithm = "RSA"
}

# Output as a file for retention

resource "local_file" "client_key" {
  content  = tls_private_key.client_private_key.private_key_pem
  filename = "${path.module}/certs/client.root.key"
}

# Create CSR for for server certificate 
resource "tls_cert_request" "cert_client_csr" {

  private_key_pem = tls_private_key.client_private_key.private_key_pem

  dns_names = [
    "root",
    ]

  subject {
    common_name         = "root"

  }
}

# Sign Server Certificate by Private CA 
resource "tls_locally_signed_cert" "client_cert" {
  // CSR by the region_1 nodes
  cert_request_pem = tls_cert_request.cert_client_csr.cert_request_pem
  // CA Private key 
  ca_private_key_pem = tls_private_key.ca_private_key.private_key_pem
  // CA certificate
  ca_cert_pem = tls_self_signed_cert.ca_cert.cert_pem

  validity_period_hours = 8760

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "client_auth",
  ]
}

resource "local_file" "client_cert" {
  content  = tls_locally_signed_cert.client_cert.cert_pem
  filename = "${path.module}/certs/client.root.crt"
}

# Create Certificate and key for nodes in each region

# Region_1

# Create private key for server certificate 
resource "tls_private_key" "node_cert_region_1" {
  algorithm = "RSA"
}

# Output as a file for retention

resource "local_file" "node_cert_region_1_key" {
  content  = tls_private_key.node_cert_region_1.private_key_pem
  filename = "${path.module}/${var.location_1}/certs/node.key"
}


# Create CSR for for server certificate 
resource "tls_cert_request" "node_cert_region_1_csr" {

  private_key_pem = tls_private_key.node_cert_region_1.private_key_pem

  dns_names = [
    "localhost",
    "127.0.0.1",
    "cockroachdb-public",
    "cockroachdb-public.${var.location_1}",
    "cockroachdb-public.${var.location_1}.svc.cluster.local",
    "*.cockroachdb",
    "*.cockroachdb.${var.location_1}",
    "*.cockroachdb.${var.location_1}.svc.cluster.local"
    ]

  subject {
    common_name         = "node"
  }
}

# Sign Server Certificate by Private CA 
resource "tls_locally_signed_cert" "node_cert_region_1" {
  // CSR by the region_1 nodes
  cert_request_pem = tls_cert_request.node_cert_region_1_csr.cert_request_pem
  // CA Private key 
  ca_private_key_pem = tls_private_key.ca_private_key.private_key_pem
  // CA certificate
  ca_cert_pem = tls_self_signed_cert.ca_cert.cert_pem

  validity_period_hours = 8760

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "server_auth",
    "client_auth",
  ]
}

# Output as a file for retention

resource "local_file" "node_cert_region_1_cert" {
  content  = tls_locally_signed_cert.node_cert_region_1.cert_pem
  filename = "${path.module}/${var.location_1}/certs/node.crt"
}

# Region_2

# Create private key for server certificate 
resource "tls_private_key" "node_cert_region_2" {
  algorithm = "RSA"
}

# Output as a file for retention

resource "local_file" "node_cert_region_2_key" {
   content  = tls_private_key.node_cert_region_2.private_key_pem
  filename = "${path.module}/${var.location_2}/certs/node.key"
}

# Create CSR for for server certificate 
resource "tls_cert_request" "node_cert_region_2_csr" {

  private_key_pem = tls_private_key.node_cert_region_2.private_key_pem

  dns_names = [
    "localhost",
    "127.0.0.1",
    "cockroachdb-public",
    "cockroachdb-public.${var.location_2}",
    "cockroachdb-public.${var.location_2}.svc.cluster.local",
    "*.cockroachdb",
    "*.cockroachdb.${var.location_2}",
    "*.cockroachdb.${var.location_2}.svc.cluster.local",
    ]

  subject {
    common_name         = "node"
  }
}

# Sign Server Certificate by Private CA 
resource "tls_locally_signed_cert" "node_cert_region_2" {
  // CSR by the region_2 nodes
  cert_request_pem = tls_cert_request.node_cert_region_2_csr.cert_request_pem
  // CA Private key 
  ca_private_key_pem = tls_private_key.ca_private_key.private_key_pem
  // CA certificate
  ca_cert_pem = tls_self_signed_cert.ca_cert.cert_pem

  validity_period_hours = 8760

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "server_auth",
    "client_auth",
  ]
}

# Output as a file for retention

resource "local_file" "node_cert_region_2_cert" {
  content  = tls_locally_signed_cert.node_cert_region_2.cert_pem
  filename = "${path.module}/${var.location_2}/certs/node.crt"
}

# Region_3

# Create private key for server certificate 
resource "tls_private_key" "node_cert_region_3" {
  algorithm = "RSA"
}

# Output as a file for retention

resource "local_file" "node_cert_region_3_key" {
  content  = tls_private_key.node_cert_region_3.private_key_pem
  filename = "${path.module}/${var.location_3}/certs/node.key"
}

# Create CSR for for server certificate 
resource "tls_cert_request" "node_cert_region_3_csr" {

  private_key_pem = tls_private_key.node_cert_region_3.private_key_pem

  dns_names = [
    "localhost",
    "127.0.0.1",
    "cockroachdb-public",
    "cockroachdb-public.${var.location_3}",
    "cockroachdb-public.${var.location_3}.svc.cluster.local",
    "*.cockroachdb",
    "*.cockroachdb.${var.location_3}",
    "*.cockroachdb.${var.location_3}.svc.cluster.local",
    ]

  subject {
    common_name         = "node"
  }
}

# Sign Server Certificate by Private CA 
resource "tls_locally_signed_cert" "node_cert_region_3" {
  // CSR by the region_3 nodes
  cert_request_pem = tls_cert_request.node_cert_region_3_csr.cert_request_pem
  // CA Private key 
  ca_private_key_pem = tls_private_key.ca_private_key.private_key_pem
  // CA certificate
  ca_cert_pem = tls_self_signed_cert.ca_cert.cert_pem

  validity_period_hours = 8760

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "server_auth",
    "client_auth",
  ]
}

# Output as a file for retention

resource "local_file" "node_cert_region_3_cert" {
  content  = tls_locally_signed_cert.node_cert_region_3.cert_pem
  filename = "${path.module}/${var.location_3}/certs/node.crt"
}

# Upload Certificates as secrets to kubernetes

# Upload CA Cert and Key as a Secret to each cluster

# Region 1
resource "kubernetes_secret_v1" "cockroachdb_client_root_region_1" {
  provider = kubernetes.region_1
  metadata {
    name = "cockroachdb.client.root"
    namespace = var.location_1
  }

  data = {
    "ca.crt" = tls_self_signed_cert.ca_cert.cert_pem
    "client.root.crt" = tls_locally_signed_cert.client_cert.cert_pem
    "client.root.key" = tls_private_key.client_private_key.private_key_pem
  }
}

# Region 2
resource "kubernetes_secret_v1" "cockroachdb_client_root_region_2" {
  provider = kubernetes.region_2
  metadata {
    name = "cockroachdb.client.root"
    namespace = var.location_2
  }

  data = {
    "ca.crt" = tls_self_signed_cert.ca_cert.cert_pem
    "client.root.crt" = tls_locally_signed_cert.client_cert.cert_pem
    "client.root.key" = tls_private_key.client_private_key.private_key_pem
  }
}

# Region 3
resource "kubernetes_secret_v1" "cockroachdb_client_root_region_3" {
  provider = kubernetes.region_3
  metadata {
    name = "cockroachdb.client.root"
    namespace = var.location_3
  }

  data = {
    "ca.crt" = tls_self_signed_cert.ca_cert.cert_pem
    "client.root.crt" = tls_locally_signed_cert.client_cert.cert_pem
    "client.root.key" = tls_private_key.client_private_key.private_key_pem
  }
}

# Upload Node Cert and Key as a Secret to each cluster

# Region 1
resource "kubernetes_secret_v1" "cockroachdb_node_region_1" {
  provider = kubernetes.region_1
  metadata {
    name = "cockroachdb.node"
    namespace = var.location_1
  }

  data = {
    "ca.crt" = tls_self_signed_cert.ca_cert.cert_pem
    "node.crt" = tls_locally_signed_cert.node_cert_region_1.cert_pem
    "node.key" = tls_private_key.node_cert_region_1.private_key_pem
  }
}

# Region 2
resource "kubernetes_secret_v1" "cockroachdb_node_region_2" {
  provider = kubernetes.region_2
  metadata {
    name = "cockroachdb.node"
    namespace = var.location_2
  }

  data = {
    "ca.crt" = tls_self_signed_cert.ca_cert.cert_pem
    "node.crt" = tls_locally_signed_cert.node_cert_region_2.cert_pem
    "node.key" = tls_private_key.node_cert_region_2.private_key_pem

  }
}

# Region 3
resource "kubernetes_secret_v1" "cockroachdb_node_region_3" {
  provider = kubernetes.region_3
  metadata {
    name = "cockroachdb.node"
    namespace = var.location_3
  }

  data = {
    "ca.crt" = tls_self_signed_cert.ca_cert.cert_pem
    "node.crt" = tls_locally_signed_cert.node_cert_region_3.cert_pem
    "node.key" = tls_private_key.node_cert_region_3.private_key_pem

  }
}
