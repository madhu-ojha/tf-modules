#!/bin/bash
# AWS IAM Role Setup for GitHub Actions
# This script helps set up the OIDC trust relationship for GitHub Actions

set -e

REPO_OWNER=${1:-"madhu-ojha"}
REPO_NAME=${2:-"tf-modules"}
GITHUB_ROLE_NAME="github-actions-terraform-role"

echo "GitHub Actions - AWS IAM Setup"
echo "=================================="
echo "Repository: ${REPO_OWNER}/${REPO_NAME}"
echo ""

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "AWS CLI is not installed. Please install it first."
    exit 1
fi

# Create trust policy JSON
cat > /tmp/trust-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::\${AWS_ACCOUNT_ID}:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:${REPO_OWNER}/${REPO_NAME}:*"
        }
      }
    }
  ]
}
EOF

# Create IAM policy JSON
cat > /tmp/terraform-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "TerraformActions",
      "Effect": "Allow",
      "Action": [
        "ec2:Describe*",
        "elasticloadbalancing:Describe*",
        "autoscaling:Describe*",
        "cloudwatch:*",
        "logs:*",
        "ecs:*",
        "rds:*",
        "s3:*",
        "opensearch:*",
        "iam:*",
        "sns:*",
        "secretsmanager:*"
      ],
      "Resource": "*"
    },
    {
      "Sid": "IAMPassRole",
      "Effect": "Allow",
      "Action": [
        "iam:PassRole"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "iam:PassedToService": [
            "ec2.amazonaws.com",
            "ecs-tasks.amazonaws.com"
          ]
        }
      }
    }
  ]
}
EOF

echo "Step 1: Create OIDC Provider (if not exists)"
echo "----------------------------------------------"
echo ""
echo "To set up OIDC, run these commands:"
echo ""
echo "AWS_ACCOUNT_ID=\$(aws sts get-caller-identity --query Account --output text)"
echo "echo \$AWS_ACCOUNT_ID"
echo ""
echo "aws iam create-open-id-connect-provider \\"
echo "  --url https://token.actions.githubusercontent.com \\"
echo "  --client-id-list sts.amazonaws.com \\"
echo "  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1"
echo ""
echo ""

echo "Step 2: Create IAM Role"
echo "---------------------"
echo ""
echo "Run this command with the trust policy:"
echo ""
echo "aws iam create-role \\"
echo "  --role-name ${GITHUB_ROLE_NAME} \\"
echo "  --assume-role-policy-document file:///tmp/trust-policy.json"
echo ""
echo ""

echo "Step 3: Attach Policy to Role"
echo "----------------------------"
echo ""
echo "aws iam put-role-policy \\"
echo "  --role-name ${GITHUB_ROLE_NAME} \\"
echo "  --policy-name terraform-policy \\"
echo "  --policy-document file:///tmp/terraform-policy.json"
echo ""
echo ""

echo "Step 4: Configure GitHub Secrets"
echo "--------------------------------"
echo ""
echo "In your GitHub repository settings, add this secret:"
echo ""
echo "Name: AWS_ROLE_TO_ASSUME"
echo "Value: arn:aws:iam::\${AWS_ACCOUNT_ID}:role/${GITHUB_ROLE_NAME}"
echo ""

echo "Trust policy and role policy JSON files have been created:"
echo "  - /tmp/trust-policy.json"
echo "  - /tmp/terraform-policy.json"
