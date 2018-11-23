#!/bin/sh

# build an .aws/credentials file
mkdir -p ~/.aws
echo "[default]" > ~/.aws/credentials
echo "aws_access_key_id = $AWS_DEFAULT_ACCESS_KEY_ID" >> ~/.aws/credentials
echo "aws_secret_access_key = $AWS_DEFAULT_SECRET_ACCESS_KEY" >> ~/.aws/credentials
echo "region = $AWS_DEFAULT_REGION" >> ~/.aws/credentials
echo '' >> ~/.aws/credentials
echo '' >> ~/.aws/credentials
