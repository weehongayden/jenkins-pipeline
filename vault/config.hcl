disable_sealwrap = true
ui = true
api_addr = "0.0.0.0:8200"
cluster_addr = "0.0.0.0:8201"
default_lease_ttl = "168h"
max_lease_ttl = "0h"

listener "tcp"{
  address = "0.0.0.0:8200"
  tls_disable = false
  tls_cert_file = "/vault/config/ssl/vault.crt"
  tls_key_file = "/vault/config/ssl/vault_private_key.pem"
}

storage "file"{
  path = "/vault/data"
}

backend "file"{
  path = "/vault/file"
}