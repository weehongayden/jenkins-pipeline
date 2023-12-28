#!/bin/bash
set -euxo pipefail

export CREDENTIAL_PATH="/home/vault/credentials"
export VAULT_ADDR="https://0.0.0.0:8200"

export JENKINS_USERNAME="weehong"
export JENKINS_TOKEN="11e29411fa9ee268c2431f537dd4ac6744"
export JENKINS_URL="jenkins.weehong.dev"

exec > >(tee -a log.txt) 2>&1

# fetch and parse the role ID from Vault
export VAULT_ROLE_ID="$(vault write -format=json -f auth/approle/role/developer/role-id | jq -r '.data.role_id')"

# fetch and parse the secret ID from Vault
export VAULT_SECRET_ID="$(vault write -format=json -f auth/approle/role/developer/secret-id | jq -r '.data.secret_id')"

# generate and parse the app token
export VAULT_APP_TOKEN="$(vault write auth/approle/login -format=json role_id=$VAULT_ROLE_ID secret_id=$VAULT_SECRET_ID | jq -r '.auth.client_token')"

# write the credential XML to a file, which we will upload to Jenkins later 
cat > $CREDENTIAL_PATH/credential.xml <<EOF
<org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl>
  <scope>GLOBAL</scope>
  <id>vault-approle-token</id>
  <secret>$VAULT_APP_TOKEN</secret>
</org.jenkinsci.plugins.plaincredentials.impl.StringCredentialsImpl>
EOF

# send the credential to Jenkins using the Jenkins API endpoint
echo "Setting $JENKINS_URL vault-secret-id"
curl -X POST -H content-type:application/xml -d @$CREDENTIAL_PATH/credential.xml "https://$JENKINS_USERNAME:$JENKINS_TOKEN@$JENKINS_URL/credentials/store/system/domain/_/credential/vault-secret-id/config.xml"