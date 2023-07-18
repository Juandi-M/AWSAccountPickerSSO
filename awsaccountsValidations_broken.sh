#!/bin/bash

# Function to check if a tool is installed and install it if not
check_tool_installation() {
  local tool=$1
  local brew_package=$2

  # Check if the tool is installed
  if ! command -v "$tool" &> /dev/null; then
    echo "$tool is not installed."
    # Check if the system is macOS and offer to install the tool
    if [[ $(uname -s) == "Darwin" ]]; then
      read -rp "Do you want to install $tool? (y/n): " answer
      if [[ $answer =~ [Yy] ]]; then
        # Check if Homebrew is installed
        if ! command -v brew &> /dev/null; then
          handle_error "Homebrew is not installed. Please install Homebrew and try again."
        fi
        echo "Installing $tool..." 
        brew install "$brew_package"
      else
        handle_error "Please install $tool before running this script."
      fi
    else
      handle_error "Please install $tool before running this script."
    fi
  fi
}

# Function to check if the AWS SSO configuration for a profile is valid
is_aws_sso_config_valid() {
  local profile_name=$1
  local required_fields=("sso_start_url" "sso_region" "sso_account_id" "sso_role_name")
  local missing_fields=()

  # Check each required field
  for field in "${required_fields[@]}"; do
    local value=$(aws configure get "sso_$field" --profile "$profile_name")

    # If the value is empty, add the field to the missing_fields array
    if [[ -z $value ]]; then
      missing_fields+=("$field")
    fi
  done

  # If any required fields are missing, trigger the AWS configure sso or login process
  if [[ ${#missing_fields[@]} -gt 0 ]]; then
    echo "Incomplete AWS SSO configuration for '$profile_name'. Proceeding with SSO login process to complete configuration."
    aws configure sso --profile "$profile_name"

    echo "Validating connection to $profile_name..."
    if aws sso login --profile "$profile_name" >/dev/null 2>&1; then
      echo "Connection to '$profile_name' established."
    else
      handle_error "Failed to establish a connection to '$profile_name'. Please check your credentials and try again."
    fi
  fi
}

# Function to configure an AWS SSO profile
configure_aws_sso_profile() {
  local profile_name=$1
  echo "Configuring AWS SSO profile: $profile_name"

  # Check if SSO session is already valid
  if is_sso_session_valid "$profile_name"; then
    echo "SSO session for $profile_name is valid. No need to log in again."
    return
  fi

  # Check if the AWS SSO configuration for the profile is valid
  if ! is_aws_sso_config_valid "$profile_name"; then
    echo "Incomplete AWS SSO configuration for '$profile_name'. Proceeding with SSO login process to complete configuration."
  fi

  # Configure SSO profile and validate connection
  aws configure sso --profile "$profile_name"

  echo "Validating connection to $profile_name..."
  if aws sso login --profile "$profile_name" >/dev/null 2>&1; then
    echo "Connection to '$profile_name' established."
  else
    handle_error "Failed to establish a connection to '$profile_name'. Please check your credentials and try again."
  fi
}

# Function to check if the SSO session for a profile is valid
is_sso_session_valid() {
  local profile_name=$1

  # Get the SSO start URL from the profile config file
  local sso_start_url=$(aws configure get sso_start_url --profile "$profile_name")

  # Loop over session files in the AWS SSO cache directory
  for session_file in ~/.aws/sso/cache/*.json; do
    # Check if the SSO session is valid by comparing expiry time with current time
    local expiry_time=$(jq -r '.expiresAt' "$session_file" | sed 's/Z/+0000/') # Replace 'Z' with '+0000'
    local expiry_time_epoch=$(date -u -j -f "%Y-%m-%dT%H:%M:%S%z" "$expiry_time" "+%s")
    local current_time_epoch=$(date -u +"%s")

    # Get the start URL from the session file
    local session_start_url=$(jq -r '.startUrl' "$session_file")

    # If the session is valid and the start URLs match, return true
    if [[ $current_time_epoch -lt $expiry_time_epoch && $session_start_url == $sso_start_url ]]; then
      return 0
    fi
  done

  # If no valid session is found, return false
  return 1
}

# Function to handle errors gracefully by printing an error message and exiting the script
handle_error() {
  local msg="$1"
  echo "Error: $msg" >&2
  exit 1
}

# Function to validate user's input by checking if it is a valid integer within the correct range
validate_user_input() {
  local input=$1
  local max=$2

  # Check if the input is an integer
  if ! [[ $input =~ ^[0-9]+$ ]]; then
    handle_error "Invalid input. Please enter a number."
  fi

  # Check if the input is within the correct range
  if ((input < 1 || input > max)); then
    handle_error "Invalid number. Please choose a number between 1 and $max."
  fi
}

# Main script starts here
echo "AWS SSO Profile Configuration Script"

# Check and install required tools
check_tool_installation "jq" "jq" || handle_error "Failed to install or find 'jq'"
check_tool_installation "aws" "awscli" || handle_error "Failed to install or find 'aws'"

# Define AWS SSO profile names
aws_sso_profiles=("AWS account 1" "AWS account 2" "AWS account 3" "AWS account 4" "AWS account 5" "AWS account 6" "AWS account 7" "AWS account 8")

# Loop through AWS SSO profiles and display them for the user to choose from
for index in "${!aws_sso_profiles[@]}"; do
  echo "$(($index+1))) ${aws_sso_profiles[$index]}"
done

# Ask the user to choose a profile
read -rp "Please choose an AWS SSO profile to configure: " profile_index

# Validate user's input
validate_user_input "$profile_index" "${#aws_sso_profiles[@]}"

# Get the profile name from the user's input
profile_name="${aws_sso_profiles[$((profile_index-1))]}"

# Configure the chosen profile
configure_aws_sso_profile "$profile_name"

# Determine the user's shell and choose the right shell profile file
if [[ $SHELL == "/bin/zsh" ]]; then
  profile_file=~/.zshrc
elif [[ $SHELL == "/bin/bash" ]]; then
  profile_file=~/.bashrc
else
  handle_error "Unsupported shell. Only bash and zsh are supported."
fi

# Add the chosen AWS SSO profile to the user's shell profile file
echo "export AWS_PROFILE=$profile_name" >> "$profile_file"
echo "AWS SSO profile '$profile_name' is successfully configured and exported to the AWS_PROFILE environment variable"

# Check if the script is being sourced or executed directly
if [[ "${BASH_SOURCE[0]}" = "${0}" ]]; then
  echo "To apply the changes, please execute the following command:"
  echo "source $profile_file"
else
  echo "Changes have been applied. AWS_PROFILE environment