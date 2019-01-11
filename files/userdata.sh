#!/usr/bin/env bash
#
# Get the value of a tag for a running EC2 instance.
# AWS instance must have a IAM role assigned to get tag data
#

#install dependencies

INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | awk -F\" '{print $4}')
EC2_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

# Grab tag value

TAG_PROJECT=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCE_ID" "Name=key,Values=project" --region=$REGION --output=text | cut -f5)
TAG_ENV=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCE_ID" "Name=key,Values=environment" --region=$REGION --output=text | cut -f5)
TAG_ROLE=$(aws ec2 describe-tags --filters "Name=resource-id,Values=$INSTANCE_ID" "Name=key,Values=role" --region=$REGION --output=text | cut -f5)

#OCT1=$(echo ${EC2_IP} | tr "." " " | awk '{ print $1 }')
#OCT2=$(echo ${EC2_IP} | tr "." " " | awk '{ print $2 }')
OCT3=$(echo ${EC2_IP} | tr "." " " | awk '{ print $3 }')
OCT4=$(echo ${EC2_IP} | tr "." " " | awk '{ print $4 }')

NEWHOSTNAME="$TAG_PROJECT-$TAG_ENV-$TAG_ROLE-$OCT3-$OCT4"

echo "update the /etc/sysconfig/network file with the new hostname/fqdn"
sed -i "/HOSTNAME/c\HOSTNAME=$NEWHOSTNAME" /etc/sysconfig/network

echo "update the running hostname"
hostname $NEWHOSTNAME

echo NEWHOSTNAME:$NEWHOSTNAME >> ~/userdata_output.txt
echo INSTANCE_ID:$INSTANCE_ID >> ~/userdata_output.txt
echo REGION:$REGION >> ~/userdata_output.txt
echo TAG_PROJECT:$TAG_PROJECT >> ~/userdata_output.txt
echo TAG_ENV:$TAG_ENV >> ~/userdata_output.txt
echo TAG_ROLE:$TAG_ROLE >> ~/userdata_output.txt
echo EC2_IP:$EC2_IP >> ~/userdata_output.txt
echo OCT3:$OCT3 >> ~/userdata_output.txt
echo OCT4:$OCT4 >> ~/userdata_output.txt

#TODO kickoff some external job maybe...

