#!/bin/bash

# # This script is used to create EC2 instances in AWS using the AWS CLI.
# # ----------------------------------------------------------------------

# # version-1 : Extracting only the instance Id from the JSON output of the AWS CLI command 
# # ----------------------------------------------------------------------------------------
# AMI_ID="ami-0220d79f3f480ecf5" 
# SG_ID="sg-0c13f122aeebc9259"

# for instance in $@
# do
#    INSTANCE_ID=$(aws ec2 run-instances --image-id $AMI_ID --instance-type t3.micro --security-group-ids $SG_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --output text --query 'Instances[0].InstanceId')
# done

# echo "$instance : $INSTANCE_ID"


# version-2 : Extracting instance Id, Private IP & Public IP from the JSON output of the AWS CLI 
# ------------------------------------------------------------------------------------------------
AMI_ID="ami-0220d79f3f480ecf5" 
SG_ID="sg-0c13f122aeebc9259"

for instance in $@
do
    INSTANCE_ID=$(aws ec2 run-instances --image-id $AMI_ID --instance-type t3.micro --security-group-ids $SG_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --output text --query 'Instances[0].InstanceId')

    sleep 5 # AWS needs a few seconds to boot the instance before an IP is assigned

    if [ $instance != "frontend" ]; then # != will be used for string comparison
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --output text --query 'Reservations[0].Instances[0].PrivateIpAddress')
    else
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --output text --query 'Reservations[0].Instances[0].PublicIpAddress')
    fi

    echo "$instance : $IP"

done


