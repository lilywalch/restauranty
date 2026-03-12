#!/bin/bash
set -e

SUBSCRIPTION_ID="daf9c53c-7096-4293-9bb1-f7ad8263db1a"
STUDENT_NAME="lily"
SP_NAME="sp-${STUDENT_NAME}-terraform"

echo "Creating service principal '${SP_NAME}' with Owner role..."

SP_OUTPUT=$(az ad sp create-for-rbac \
  --name "$SP_NAME" \
  --role Owner \
  --scopes "/subscriptions/${SUBSCRIPTION_ID}" \
  --output json)

CLIENT_ID=$(echo "$SP_OUTPUT" | jq -r '.appId')
CLIENT_SECRET=$(echo "$SP_OUTPUT" | jq -r '.password')
TENANT_ID=$(echo "$SP_OUTPUT" | jq -r '.tenant')

# Save to .env (backup/reference)
cat > .env <<EOF
export ARM_CLIENT_ID=${CLIENT_ID}
export ARM_CLIENT_SECRET=${CLIENT_SECRET}
export ARM_SUBSCRIPTION_ID=${SUBSCRIPTION_ID}
export ARM_TENANT_ID=${TENANT_ID}
EOF

# Append to ~/.bashrc for persistence
cat >> ~/.bashrc <<EOF

# Azure SP credentials for Terraform (${SP_NAME})
export ARM_CLIENT_ID=${CLIENT_ID}
export ARM_CLIENT_SECRET=${CLIENT_SECRET}
export ARM_SUBSCRIPTION_ID=${SUBSCRIPTION_ID}
export ARM_TENANT_ID=${TENANT_ID}
EOF

# Load into current session
source ~/.bashrc

echo ""
echo "Service principal created successfully!"
echo "Credentials saved to .env and added to ~/.bashrc"
echo ""
echo "--- Credentials ---"
cat .env
echo "--------------------"
echo ""
echo "You can now run terraform directly:"
echo "  terraform init"
echo "  terraform apply"
