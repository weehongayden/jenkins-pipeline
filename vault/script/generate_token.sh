#!/bin/sh
set -euxo pipefail

# Read environment variables from .env file
while IFS= read -r line; do
  # Check if the line is not a comment (does not start with #)
  if [ "${line#"#"}" != "$line" ]; then
    continue
  fi
  
  # Export the environment variable
  export "$line"
done < .env

# Redirect all output (stdout and stderr) to a log file
exec > >(tee -a log.txt) 2>&1

# Check the Vault status
export VAULT_STATUS=$(vault status -format "json" | jq -r '.sealed')

if [[ $VAULT_STATUS == 'false' ]]; then
  echo "Vault is already unsealed."
else
  echo "Vault is sealed. Unsealing..."

  # Run unseal operation and iterate through the key values until the seal status changes to "false"
  i=1
  while [[ $VAULT_STATUS == 'true' ]]; do
    eval "UNSEAL_KEY=\$VAULT_UNSEAL_KEY_$i"
    vault operator unseal "$UNSEAL_KEY" &>/dev/null
    export VAULT_STATUS=$(vault status -format "json" | jq --raw-output '.sealed')
    i=$((i+1))
  done

  echo "Vault is now unsealed."
fi

# Fetch and parse the role ID from Vault
export VAULT_ROLE_ID="$(vault read -format=json auth/approle/role/$VAULT_ROLE/role-id | jq -r '.data.role_id')"

# Fetch and parse the secret ID from Vault
export VAULT_SECRET_ID="$(vault write -format=json -f auth/approle/role/$VAULT_ROLE/secret-id | jq -r '.data.secret_id')"

# Generate and parse the app token
export VAULT_APP_TOKEN="$(vault write auth/approle/login -format=json role_id=$VAULT_ROLE_ID secret_id=$VAULT_SECRET_ID | jq -r '.auth.client_token')"

# Send the credential to Jenkins using the Jenkins API endpoint
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
-X POST "https://$JENKINS_USERNAME:$JENKINS_TOKEN@$JENKINS_URL/manage/credentials/store/system/domain/_/credential/$JENKINS_CREDENTIAL_ID/updateSubmit" \
--data-urlencode "json={
    \"stapler-class\": \"com.datapipe.jenkins.vault.credentials.VaultTokenCredential\",
    \"scope\": \"GLOBAL\",
    \"token\": \"$VAULT_APP_TOKEN\",
    \"\$redact\": \"token\",
    \"namespace\": \"\",
    \"id\": \"$JENKINS_CREDENTIAL_ID\",
    \"description\": \"Vault+AppRole+Token\",
    \"Submit\": \"\"
  }"
)

# Output the Jenkins API response
if [ "$RESPONSE" -eq 302 ]; then
  echo "Update app role token successfully."
else
  echo "Failed to update the app role token."
fi
