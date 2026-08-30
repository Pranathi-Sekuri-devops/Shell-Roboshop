#!/bin/bash

# # version-1
# # ==========
# AMI_ID="ami-0220d79f3f480ecf5" 
# SG_ID="sg-0c13f122aeebc9259"

# for instance in $@
# do
#    INSTANCE_ID=$(aws ec2 run-instances --image-id $AMI_ID --instance-type t3.micro --security-group-ids $SG_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --output text --query 'Instances[0].InstanceId')
# done

# echo "$instance : $INSTANCE_ID"

# version-1
# ==========
AMI_ID="ami-0220d79f3f480ecf5" 
SG_ID="sg-0c13f122aeebc9259"

for instance in $@
do
   INSTANCE_ID=$(aws ec2 run-instances --image-id $AMI_ID --instance-type t3.micro --security-group-ids $SG_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --output text --query 'Instances[0].InstanceId')

if [ INSTANCE_ID -ne "frontend" ]; then
    IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --output text --query 'Reservations[0].Instances[0].PrivateIpAddress')
else
    IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --output text --query 'Reservations[0].Instances[0].PublicIpAddress')
fi

echo "$instance : $INSTANCE_ID"

done

