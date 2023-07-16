#!/bin/bash

# Function to configure an AWS SSO profile
configure_aws_sso_profile() {
    local profile_name=$1

    echo "Configuring AWS SSO profile: $profile_name"

    # Configure AWS SSO profile
    aws configure sso --profile "$profile_name"

    # Validate the connection
    echo "Validating connection to $profile_name..."
    if aws sso login --profile "$profile_name" >/dev/null 2>&1; then
        echo "Connection to '$profile_name' established."
    else
        echo "Failed to establish connection to '$profile_name'. Please check your credentials and try again."
        exit 1
    fi
}

# Main script
echo "AWS SSO Profile Configuration Script"

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "AWS CLI is not installed. Please install it before running this script."
    exit 1
fi

# Array of AWS SSO profiles
aws_sso_profiles=("Enterprise-Infrastructure" "NonProd-DataLake" "NonProd-Devops" "NonProd-EntInfrastructure" "NonProd-ITApp" "Prod-DevOps" "Prod-EntInfrastructure" "Prod-ITBusiness" "Sandbox-DevOps")

# Prompt for selecting an AWS SSO profile
PS3="Select an AWS SSO profile to configure (enter the corresponding number): "
select profile_name in "${aws_sso_profiles[@]}"; do
    break
done

# Configure the selected AWS SSO profile
configure_aws_sso_profile "$profile_name"

echo "AWS SSO profile '$profile_name' is successfully configured."
