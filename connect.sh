#!/bin/bash
#  Usage: ssh to your new EC2 host using TagName
#         Use this script when you don't have DNS (name) setup.
#  The script gets the ip address of your EC2 instance based on the tag name

if [ $# -ne 3 ] ; then
   echo "$0 HN USERNAME PRIVATEKEY"
   exit 1
fi

EC2=/tmp/ec2.list
HN=$1
KP=$3
USERNAME=$2

if [ ! -f $KP ] ; then
   echo "Private Key $KP not found"
   exit 1
fi

echo "Looking for public IP with tag name $HN ..."

aws ec2 describe-instances  --query 'Reservations[].Instances[].[PrivateIpAddress,PublicIpAddress,VpcId,InstanceId,Tags[?Key==`Name`].Value[]]' --output text --filters "Name=instance-state-name,Values=running" | sed 's/None$/None\n/g' | sed '$!N;s/\n/ /g' | nl > $EC2

IP=`cat $EC2 | grep $HN | awk '{print $3}'`
echo "Found IP $IP of the hostname $HN "
# clean up temp file
rm $EC2

echo "Connecting to $HN with $IP as user $USERNAME ..."
ssh -i $KP $USERNAME\@$IP

echo "Done."
