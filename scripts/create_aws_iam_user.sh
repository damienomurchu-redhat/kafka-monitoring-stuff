#!/bin/bash

# USAGE: ./create_aws_iam_user.sh $USERNAME $PASSWORD $EMAIL $TEAM

if [ "$#" -ne 4 ]; then
    echo "Please supply the required number of arguments"
    exit 2
fi

# Prevent Pagination: https://docs.aws.amazon.com/cli/latest/userguide/cliv2-migration.html#cliv2-migration-output-pager
export AWS_PAGER=""

# Account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Group and Policy name
GROUP_NAME="MKLogsReadOnlyUsers"
POLICY_NAME="MKManageOwnUserAccount"

# Arguments
USERNAME="mk_$1_evals"
PASSWORD="$2"
EMAIL="$3"
TEAM="$4"

# Check if the group already exists. If it doesn't, create it and attach the CloudWatchLogsReadOnlyAccess policy
if [ "$(aws iam get-group --group-name "$GROUP_NAME")" ]; then
echo "Group $GROUP_NAME already exists"
else
aws iam create-group --group-name "$GROUP_NAME"
aws iam attach-group-policy --group-name "$GROUP_NAME" --policy-arn 'arn:aws:iam::aws:policy/CloudWatchLogsReadOnlyAccess'
fi

# Check if the policy already exists. If it doesn't, create it and attach it to the MKLogsReadOnlyUsers group
if [ "$(aws iam get-policy --policy-arn 'arn:aws:iam::'"$ACCOUNT_ID"':policy/'"$POLICY_NAME"'')" ]; then
echo "Policy $POLICY_NAME already exists"
else
aws iam create-policy --policy-name $POLICY_NAME --policy-document file://scripts/mk_evals_cloudwatch_iam_policy.json
aws iam wait policy-exists --policy-arn 'arn:aws:iam::'"$ACCOUNT_ID"':policy/'"$POLICY_NAME"''
aws iam attach-group-policy --group-name "$GROUP_NAME" --policy-arn 'arn:aws:iam::'"$ACCOUNT_ID"':policy/'"$POLICY_NAME"''
fi

# Check if the user already exists. If it doesn't, create the user and attach it to the MKLogsReadOnlyUsers group
if [ "$(aws iam get-user --user-name "$USERNAME")" ]; then
echo "User $USERNAME already exists"
exit 1
else
# Create user and assign tags
aws iam create-user --user-name "$USERNAME" --tags Key=email,Value="$EMAIL" Key=team,Value="$TEAM"
aws iam create-login-profile --password-reset-required --user-name "$USERNAME" --password "$PASSWORD"
aws iam add-user-to-group --group-name "$GROUP_NAME" --user-name "$USERNAME"
fi

# Print out log in details
echo
echo Sign in URL: "https://$ACCOUNT_ID.signin.aws.amazon.com/console"
echo Username: "$USERNAME"
echo -e Password: "https://vault.devshift.net/ui/vault/secrets/managed-services/show/rts/aws_iam_cloudwatch_readonly_user\n"
echo "User $USERNAME successfully created"