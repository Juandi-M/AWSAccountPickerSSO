
# AWS SSO Profile Configuration Script
![Effort](http://ForTheBadge.com/images/badges/built-with-love.svg) ![script](https://img.shields.io/badge/Shell_Script-121011?style=for-the-badge&logo=gnu-bash&logoColor=white) ![License](https://img.shields.io/badge/license-MIT-green.svg)


This is a shell script that helps in configuring AWS Single Sign-On (SSO) profiles. It first checks for the required tools: `aws` and `jq`, offers to install them if they are not present, and then helps you in selecting and setting up your AWS SSO profile.

## Dependencies

- [AWS CLI](https://aws.amazon.com/cli/)
- [jq](https://stedolan.github.io/jq/)

## How it works

The script works as follows:

1. It checks if the required tools (`jq` and `aws`) are installed.
2. If not installed, it attempts to install them via Homebrew (macOS only). For other operating systems, it provides a prompt for manual installation.
3. The script then allows you to select an AWS SSO profile.
4. The AWS SSO session validity is then checked. If the session is expired, it attempts to re-login.
5. It validates the connection to the AWS SSO profile, and if successful, sets it up.
6. It then sets the chosen AWS SSO profile as the `AWS_PROFILE` environment variable in your shell profile.

## Usage

To run the script, clone this repository and execute the script with bash.

```bash
git clone https://github.com/YOUR_GITHUB_USERNAME/aws-sso-config.git
cd aws-sso-config
bash aws_sso_config.sh
```

You'll then see a prompt to select an AWS SSO profile:

```bash
Select an AWS SSO profile to configure (enter the corresponding number): 
1) AWS account 1
2) AWS account 2
3) AWS account 3
4) WS account 4
5) AWS account 5
6) AWS account 6
7) AWS account 7
8) AWS account 8
9) AWS account 9
```

After selecting a profile, the script will attempt to validate and configure it. When it's done, it will update your shell profile with the `AWS_PROFILE` environment variable set to your chosen AWS SSO profile.

You'll then need to execute `source ~/.bashrc` or `source ~/.zshrc` depending on your shell for the changes to take effect.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.