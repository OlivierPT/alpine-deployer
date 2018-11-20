#!/bin/bash

# Configure aws credentials from CodeBuild environment and provided role to assume as argument of the script
# References :
# https://aws.amazon.com/fr/blogs/security/a-new-and-standardized-way-to-manage-credentials-in-the-aws-sdks/
# http://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_temp_use-resources.html#using-temp-creds-sdk-cli

if [ $# != 2 ]
then
  echo "Error : this script requires 2 arguments."
  echo "Usage: "$(basename $0)" <profile name> <role arn>"
  echo ""
  exit 1
fi

# then add the role to assume
# first arg is the name of the profile
# second arg is the role arn to be used for the profile
echo "[$1]" >> ~/.aws/credentials
echo "role_arn = $2" >> ~/.aws/credentials
echo 'source_profile = default' >> ~/.aws/credentials
echo "region = $AWS_REGION" >> ~/.aws/credentials
echo '' >> ~/.aws/credentials
