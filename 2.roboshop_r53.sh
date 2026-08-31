#!/bin/bash
# version-1
# ==========
AMI_ID="ami-0220d79f3f480ecf5" 
SG_ID="sg-0c13f122aeebc9259"
HOSTED_ZONE_ID="Z0259262143THEDMPKZVP"
DOMAIN_NAME="prananya.in"

for INSTANCE in "$@"
do
   # 1. Launch Instance
   #--------------------
   INSTANCE_ID=$(aws ec2 run-instances --image-id $AMI_ID --instance-type t3.micro --security-group-ids $SG_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$INSTANCE}]" --output text --query 'Instances[0].InstanceId')

   # 2. Wait for instance to be running to ensure IP allocation
   #------------------------------------------------------------
   echo "Waiting for $INSTANCE to boot..."
   aws ec2 wait instance-running --instance-ids $INSTANCE_ID # official AWS waiter
    
   # 3. Fetch IP Address
   #---------------------
   if [ "$INSTANCE" != "frontend" ]; then 
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --output text --query 'Reservations[0].Instances[0].PrivateIpAddress')
        RECORD_NAME="$INSTANCE.$DOMAIN_NAME" # mongodb.prananya.in
  else
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --output text --query 'Reservations[0].Instances[0].PublicIpAddress')
        RECORD_NAME="$DOMAIN_NAME"  # prananya.in
   fi
    
   echo "Assigned IP for $INSTANCE : $IP"

   # 4. Update Route 53 DNS Record
   #-------------------------------
   echo "Updating Route 53 record for $RECORD_NAME..."
   aws route53 change-resource-record-sets \
   --hosted-zone-id $HOSTED_ZONE_ID \
   --change-batch '
   {
        "Comment": "Updating record set with new IP",
        "Changes": [{
            "Action"              : "UPSERT", 
            "ResourceRecordSet"   : {
              "Name"              : "'$RECORD_NAME'",
              "Type"              : "A",
              "TTL"               : 1,
              "ResourceRecords"   : [{
                  "Value"         : "'$IP'"
               }]
            }
       }]
    }
    '
done

# upsert : create record if not exist / update with new IP if exists