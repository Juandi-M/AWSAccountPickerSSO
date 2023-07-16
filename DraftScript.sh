#!/bin/bash

check_and_install() {
  local tool=$1
  local brew_package=$2

  if ! command -v "$tool" &> /dev/null; then
    echo "$tool is not installed."

    if [[ $(uname -s) == "Darwin" ]]; then
      read -rp "Do you want to install $tool? (y/n): " answer
      if [[ $answer =~ [Yy] ]]; then
        if ! command -v brew &> /dev/null; then
          echo "Homebrew is not installed. Please install Homebrew and try again."
          exit 1
        fi
        echo "Installing $tool..."
        brew install "$brew_package"
      else
        echo "Please install $tool before running this script."
        exit 1
      fi
    else
      echo "Please install $tool before running this script."
      exit 1
    fi
  fi
}

configure_aws_sso_profile() {
  local profile_name=$1

  echo "Configuring AWS SSO profile: $profile_name"

  session_files=$(find ~/.aws/sso/cache/ -name "*.json")
  for session_file in $session_files; do
    expiry_time=$(jq -r '.expiresAt' "$session_file")
    current_time=$(date -u +"%Y-%m-%dT%H:%M:%S")
    if [[ "$expiry_time" > "$current_time" ]]; then
      echo "SSO session is valid. No need to login again."
      return
    fi
  done

  aws configure sso --profile "$profile_name"

  echo "Validating connection to $profile_name..."
  if aws sso login --profile "$profile_name" >/dev/null 2>&1; then
    echo "Connection to '$profile_name' established."
  else
    echo "Failed to establish connection to '$profile_name'. Please check your credentials and try again."
    exit 1
  fi
}

echo "AWS SSO Profile Configuration Script"

check_and_install "jq" "jq"
check_and_install "aws" "awscli"

aws_sso_profiles=("Enterprise-Infrastructure" "NonProd-DataLake" "NonProd-Devops" "NonProd-EntInfrastructure" "NonProd-ITApp" "Prod-DevOps" "Prod-EntInfrastructure" "Prod-ITBusiness" "Sandbox-DevOps")

PS3="Select an AWS SSO profile to configure (enter the corresponding number): "
select profile_name in "${aws_sso_profiles[@]}"; do
  if [[ $REPLY =~ ^[0-9]+$ ]] && [[ $REPLY -gt 0 && $REPLY -le ${#aws_sso_profiles[@]} ]]; then
    break
  fi
  echo "Invalid selection. Please enter a number corresponding to the profile."
done

configure_aws_sso_profile "$profile_name"

# Define the shell profile file based on the current shell
if [[ $SHELL == *"zsh"* ]]; then
  profile_file=~/.zshrc
elif [[ $SHELL == *"bash"* ]]; then
  profile_file=~/.bashrc
else
  echo "Unsupported shell. Exiting."
  exit 1
fi

echo "export AWS_PROFILE=$profile_name" >> "$profile_file"
echo "AWS SSO profile '$profile_name' is successfully configured and exported to the AWS_PROFILE environment variable."
echo "This change will be permanent in new shell sessions. For the current shell session, please source the profile file: 'source $profile_file' or open a new terminal window."