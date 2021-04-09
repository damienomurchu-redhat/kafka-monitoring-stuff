#!/bin/bash

# USAGE: ./create_aws_iam_user.sh $USERNAME $PASSWORD $EMAIL $TEAM

if [ "$#" -ne 4 ]; then
    echo "Please supply the required number of arguments"
    exit 2
fi

# Prevent Pagination: https://docs.aws.amazon.com/cli/latest/userguide/cliv2-migration.html#cliv2-migration-output-pager
export AWS_PAGER=""

# Account ID
ID=$(aws sts get-caller-identity --query Account --output text)

# Group and Policy name
GROUP_NAME="MKLogsReadOnlyUsers"
POLICY_NAME="MKManageOwnUserAccount"

# Arguments
USERNAME="mk_$1_evals"
PASSWORD="$2"
EMAIL="$3"
TEAM="$4"

# Create MKLogsReadOnlyUsers group and attach the CloudWatchLogsReadOnlyAccess policy
aws iam create-group --group-name "$GROUP_NAME"
aws iam attach-group-policy --group-name "$GROUP_NAME" --policy-arn 'arn:aws:iam::aws:policy/CloudWatchLogsReadOnlyAccess'

# Create MKManageOwnUserAccount policy and attach it to the MKLogsReadOnlyUsers group
aws iam create-policy --policy-name $POLICY_NAME --policy-document file://scripts/mk_evals_cloudwatch_iam_policy.json
aws iam wait policy-exists --policy-arn 'arn:aws:iam::'"$ID"':policy/'"$POLICY_NAME"''
aws iam attach-group-policy --group-name "$GROUP_NAME" --policy-arn 'arn:aws:iam::'"$ID"':policy/'"$POLICY_NAME"''

# Create user and assign tags
aws iam create-user --user-name "$USERNAME" --tags Key=email,Value="$EMAIL" Key=team,Value="$TEAM"
aws iam create-login-profile --password-reset-required --user-name "$USERNAME" --password "$PASSWORD"
aws iam add-user-to-group --group-name "$GROUP_NAME" --user-name "$USERNAME"

echo
echo Sign in URL: "https://$ID.signin.aws.amazon.com/console"
echo Username: "$USERNAME"
echo "Successful Execution!"