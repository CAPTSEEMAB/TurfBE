#!/bin/bash

# ============================================
# AWS Elastic Beanstalk Setup Script
# Run this script ONCE to set up IAM roles
# ============================================

set -e

echo "🚀 Setting up AWS Elastic Beanstalk IAM Roles..."

# Variables
EC2_ROLE_NAME="aws-elasticbeanstalk-ec2-role"
INSTANCE_PROFILE_NAME="aws-elasticbeanstalk-ec2-role"

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if AWS CLI is configured
if ! aws sts get-caller-identity > /dev/null 2>&1; then
    echo "❌ AWS CLI is not configured. Please run 'aws configure' first."
    exit 1
fi

echo "✅ AWS CLI is configured"
echo "Account: $(aws sts get-caller-identity --query 'Account' --output text)"
echo "Region: $(aws configure get region)"

# Create EC2 Role for Elastic Beanstalk
echo ""
echo "📦 Creating EC2 Instance Role: $EC2_ROLE_NAME"

# Check if role exists
if aws iam get-role --role-name $EC2_ROLE_NAME > /dev/null 2>&1; then
    echo "   Role already exists, skipping creation..."
else
    aws iam create-role \
        --role-name $EC2_ROLE_NAME \
        --assume-role-policy-document file://$SCRIPT_DIR/ec2-trust-policy.json \
        --description "EC2 role for Elastic Beanstalk instances"
    echo "   ✅ Role created"
fi

# Attach AWS Managed Policies
echo ""
echo "📎 Attaching managed policies..."

POLICIES=(
    "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
    "arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker"
    "arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier"
    "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
)

for policy in "${POLICIES[@]}"; do
    echo "   Attaching: $policy"
    aws iam attach-role-policy \
        --role-name $EC2_ROLE_NAME \
        --policy-arn $policy 2>/dev/null || echo "   (already attached)"
done

# Create Instance Profile
echo ""
echo "📦 Creating Instance Profile: $INSTANCE_PROFILE_NAME"

if aws iam get-instance-profile --instance-profile-name $INSTANCE_PROFILE_NAME > /dev/null 2>&1; then
    echo "   Instance profile already exists, skipping..."
else
    aws iam create-instance-profile --instance-profile-name $INSTANCE_PROFILE_NAME
    aws iam add-role-to-instance-profile \
        --instance-profile-name $INSTANCE_PROFILE_NAME \
        --role-name $EC2_ROLE_NAME
    echo "   ✅ Instance profile created and role attached"
fi

echo ""
echo "============================================"
echo "✅ IAM Setup Complete!"
echo "============================================"
echo ""
echo "Next steps:"
echo "1. Add these secrets to your GitHub repository:"
echo "   - AWS_ACCESS_KEY_ID"
echo "   - AWS_SECRET_ACCESS_KEY"
echo ""
echo "2. Add your Supabase environment variables in AWS EB Console:"
echo "   - SUPABASE_URL"
echo "   - SUPABASE_SERVICE_ROLE_KEY"
echo "   - SUPABASE_KEY"
echo "   - JWT_SECRET"
echo ""
echo "3. Push your code to trigger deployment!"
