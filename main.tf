
# Root private key
resource "tls_private_key" "root" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P521"
}

# Root certificate
resource "tls_self_signed_cert" "root" {
  private_key_pem = tls_private_key.root.private_key_pem

  subject {
    common_name  = "hashicorp"
    organization = "Hashicorp Demos"
  }

  validity_period_hours = 8760

  allowed_uses = [
    "cert_signing",
    "digital_signature",
    "crl_signing",
  ]

  is_ca_certificate = true
}


# Server private key
resource "tls_private_key" "server" {
  count       = 5
  algorithm   = "ECDSA"
  ecdsa_curve = "P521"
}

# Server signing request
resource "tls_cert_request" "server" {
  count           = 5
  #key_algorithm   = element(tls_private_key.server.*.algorithm, count.index)
  private_key_pem = element(tls_private_key.server.*.private_key_pem, count.index)

  subject {
    common_name  = "hashicorp-server-${count.index}.node.consul"
    organization = "HashiCorp Demostack"
  }

  dns_names = [
    "*.query.consul",
    "consul.service.consul",

    # Nomad
    "nomad.service.consul",

    "client.global.nomad",
    "server.global.nomad",

    # Vault
    "vault.service.consul",
    "vault.query.consul",
    "active.vault.service.consul",
    "standby.vault.service.consul",
    "performance-standby.vault.service.consul",
    
    # Common
    "localhost"
    
  ]

}

# Server certificate
resource "tls_locally_signed_cert" "server" {
  count              = 5
  cert_request_pem   = element(tls_cert_request.server.*.cert_request_pem, count.index)
  ca_private_key_pem = tls_self_signed_cert.root.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.root.cert_pem

  validity_period_hours = 720 # 30 days

  allowed_uses = [
    "client_auth",
    "digital_signature",
    "key_agreement",
    "key_encipherment",
    "server_auth",
  ]
}


# Client private key

resource "tls_private_key" "workers" {
  count       = 5
  algorithm   = "ECDSA"
  ecdsa_curve = "P521"
}

# Client signing request
resource "tls_cert_request" "workers" {
  count           = 5
  private_key_pem = element(tls_private_key.workers.*.private_key_pem, count.index)

  subject {
    common_name  = "hashicorp-worker-${count.index}.node.consul"
    organization = "HashiCorp Demostack"
  }

  dns_names = [
    
    "*.service.consul",
    "*.query.consul",
    "consul.service.consul",

    # Nomad
    "nomad.service.consul",
    
    "client.global.nomad",
    "server.global.nomad",

    # Vault
    "vault.service.consul",
    "vault.query.consul",
    "active.vault.service.consul",
    "standby.vault.service.consul",
    "performance-standby.vault.service.consul",
    
    # Common
    "localhost"
  ]

}

# Client certificate

resource "tls_locally_signed_cert" "workers" {
  count            = 5
  cert_request_pem = element(tls_cert_request.workers.*.cert_request_pem, count.index)
  ca_private_key_pem = tls_self_signed_cert.root.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.root.cert_pem

  validity_period_hours = 720 # 30 days

  allowed_uses = [
    "client_auth",
    "digital_signature",
    "key_agreement",
    "key_encipherment",
    "server_auth",
  ]
}
