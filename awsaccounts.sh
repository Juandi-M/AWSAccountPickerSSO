#!/bin/zsh

# Function to connect to AWS accounts using AWS SSO
connect_to_aws() {
    aws_account_names=("Enterprise-Infrastructure" "NonProd-DataLake" "NonProd-Devops" "NonProd-EntInfrastructure" "NonProd-ITApp" "Prod-DevOps" "Prod-EntInfrastructure" "Prod-ITBusiness" "Sandbox-DevOps")

    # Prompt for selecting the AWS account
    echo "Select an AWS account to connect:"
    select account_name in "${aws_account_names[@]}"; do
        break
    done

    # Retrieve AWS SSO credentials for the selected account
    aws sso login --profile "$account_name"

    # Export the AWS configuration to environment variables
    export AWS_PROFILE="$account_name"
    export AWS_DEFAULT_REGION="us-west-2"  # Replace with your preferred default region
}

# Main script
echo "AWS Account Connector Script"

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "AWS CLI is not installed. Please install it before running this script."
    exit 1
fi

# Check if AWS SSO is configured
if ! aws configure get sso_start_url >/dev/null 2>&1; then
    echo "AWS SSO is not configured. Please run 'aws configure sso' to set up AWS SSO before using this script."
    exit 1
fi

# Connect to AWS accounts
connect_to_aws
