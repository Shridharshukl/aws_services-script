#!/bin/bash

############################################################################################################
# Author: shridhar 
# Date: 20/03/25 
# Description: AWS CLI Helper Script
#
# This script provides a convenient interface to query common AWS services
# and display their resources in a readable format using jq.
# 
# Usage:
#   1. Run ./aws_help.sh 
#   2. Enter the region name and service name when prompted
#   3. View formatted service information
# 
# Example:
#   ./aws_help.sh 
#   > us-east-1 ec2
#
# Supported Services:
#   1. ec2        - List EC2 instances 
#   2. s3         - List S3 buckets
#   3. lambda     - List Lambda functions
#   4. iam        - List IAM users
#   5. vpc        - List VPCs
#   6. cloudwatch - List CloudWatch metrics
#   7. cloudfront - List CloudFront distributions
############################################################################################################

# Function to display service options and collect user input
function helper(){
    echo ""
    echo "===== AWS CLI HELPER ====="
    echo "Supported services:"
    echo "  1. ec2        - EC2 instances"
    echo "  2. s3         - S3 buckets"
    echo "  3. lambda     - Lambda functions"
    echo "  4. iam        - IAM users"
    echo "  5. vpc        - VPCs"
    echo "  6. cloudwatch - CloudWatch metrics"
    echo "  7. cloudfront - CloudFront distributions"
    echo ""
    echo "Enter the region name and service name:"
    echo "Format: <region_name> <service_name>"
    echo "Example: us-east-1 ec2"
    read val1 val2
}

# Prompt user for service and region
helper

# Verify AWS CLI installation
if [ -z "$(which aws)" ]; then
    echo "ERROR: AWS CLI is not installed. Please install AWS CLI and configure credentials."
    exit 1
fi

# Verify AWS credentials are configured
if [ -z "$(aws configure get aws_access_key_id)" ]; then
    echo "ERROR: AWS credentials not configured. Run 'aws configure' to set up your credentials."
    exit 1
fi

# Store input values as region and service names
region_name="$val1"
service_name="$val2"

# Validate that both region and service were provided
if [ -z "$region_name" ] || [ -z "$service_name" ]; then
    echo "ERROR: Missing required input. Please provide both region name and service name."
    exit 1
fi

# Validate the region exists in AWS
if [ -z "$(aws ec2 describe-regions --region $region_name)" ]; then
    echo "ERROR: Invalid region '$region_name'. Please provide a valid AWS region name."
    exit 1
fi

# Validate the requested service is supported
if [ $service_name != "ec2" ] && [ $service_name != "s3" ] && [ $service_name != "lambda" ] && [ $service_name != "iam" ] && [ $service_name != "vpc" ] && [ $service_name != "cloudwatch" ] && [ $service_name != "cloudfront" ]; then
    echo "ERROR: Invalid service '$service_name'. Please select from the supported services list."
    exit 1
fi

# Process service request and display results using jq for JSON formatting
echo "Fetching $service_name resources in region $region_name..."

case $service_name in
    "ec2")
        aws ec2 describe-instances --region $region_name | jq '.Reservations[].Instances[].Tags[].Value'
        exit 0
        ;;
    "s3")
        aws s3api list-buckets --region $region_name | jq '.Buckets[].Name'
        exit 0
        ;;
    "lambda")
        aws lambda list-functions --region $region_name | jq '.Functions[].FunctionName'
        exit 0
        ;;
    "iam")
        aws iam list-users --region $region_name | jq '.Users[].UserName'
        exit 0
        ;;
    "vpc")
        aws ec2 describe-vpcs --region $region_name | jq '.Vpcs[].VpcId'
        exit 0
        ;;
    "cloudwatch")
        aws cloudwatch list-metrics --region $region_name | jq '.Metrics[].MetricName'
        exit 0
        ;;
    "cloudfront")
        aws cloudfront list-distributions --region $region_name | jq '.DistributionList.Items[].Id'
        exit 0
        ;;
    *)
        echo "Invalid service name provided."
        exit 1
        ;;
esac

