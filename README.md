# AWS SSO Profile Configuration Utility
![Quality Assurance](http://ForTheBadge.com/images/badges/built-with-love.svg) ![Shell Script](https://img.shields.io/badge/Shell_Script-121011?style=for-the-badge&logo=gnu-bash&logoColor=white) ![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)

Simplify your AWS Single Sign-On (SSO) profile configuration process with this effective shell script. A perfect solution for individual developers and teams managing multiple AWS accounts and frequently alternating between various SSO profiles.

## Prerequisites

Before launching this script, please ensure to install the following dependencies:

- AWS CLI
- jq

Refer to their respective documentation for the installation process.

## Installation Steps

1. Clone the repository to your local system:

```bash
git clone https://github.com/YOUR_GITHUB_USERNAME/aws-sso-config.git
```

2. Navigate into the cloned repository:

```bash
cd aws-sso-config
```

3. Assign execution permission to the script:

```bash
chmod +x awsaccounts.sh
```

## Script Execution

For script execution, use bash or zsh:

- Bash users:

```bash
bash awsaccounts.sh
```

- Zsh users:

```bash
zsh awsaccounts.sh
```

## Functionality

Here's a rundown of how the script operates:

1. Verifies the installation of the required tools (`jq` and `aws`), providing installation instructions if any are missing.
2. Lists all available AWS SSO profiles and prompts you to select one.
3. Validates the AWS SSO session related to the chosen profile, establishing a new session if the existing one has expired.
4. Validates the connection to the selected AWS SSO profile and proceeds with its configuration.
5. Sets the chosen AWS SSO profile as the `AWS_PROFILE` environment variable in your shell profile.

The script auto-detects your shell (`bash` or `zsh`) and accordingly updates the `AWS_PROFILE` environment variable in the correct shell profile file.

## Applying Configuration Changes

Upon successful configuration of the AWS SSO profile and updating your shell profile, apply the changes to reflect them in your current shell session.

For bash users, run the following command:

```bash
source ~/.bashrc
```

For zsh users, run the following command:

```bash
source ~/.zshrc
```


## Licensing
This project operates under the Apache License 2.0. For more information, see the LICENSE.md file.

### Note: 
Please replace "YOUR_GITHUB_USERNAME" with your actual GitHub username in the repository cloning command.