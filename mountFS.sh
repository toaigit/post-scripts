#!/bin/bash
#  Mount all file systems specified in a text file.
#  Each line of the file contains vol-id mountpoint owner

mountebs()
{
  echo "Info: Inside mountebs function ..."

  local VOLID=$1
  local fileowner=$2
  local mountpoint=$3
  local filecnt=$4

  devarray=(/dev/xvdh /dev/xvdi /dev/xvdj /dev/xvdk /dev/xvhl /dev/xvhm /dev/xvhn /dev/xvho /dev/xvhp /dev/xvhq)

  DEVINFO=${devarray[$filecnt]}
  echo "Info: aws ec2 attach-volume --device $DEVINFO --volume-id $VOLID --instance-id $INSTID --region=$REGION"
  aws ec2 attach-volume --device $DEVINFO --volume-id $VOLID --instance-id $INSTID --region=$REGION
  sleep 30
  state=$(aws ec2 describe-volumes --region $REGION --volume-ids $VOLID --query  "Volumes[].Attachments[].State" --output text)
  if [ "$state" == "attached" ] ; then
     echo "Info: $VOLID attached successfully."
  else
     echo "Info: $state ... It is taking a lot longer ... Waitting another 40s for $VOLID to attach."
     sleep 30
     aws ec2 describe-volumes --region $REGION --volume-ids $VOLID --query  "Volumes[].Attachments[].State" --output text
fi

echo "Info: Checking if the $DEVINFO has been initialized ..."
#  use readlink to handle Nitro Instance where the /dev/xvdAAA is a symbolic lik to nvmeXXX 
cnt=`file -s $(readlink -f $DEVINFO) | grep -c ': data'`
if [ $cnt -ne 1 ] ; then
   echo "Info: DEVICE $DEVINFO is already INITIALIZED."
else
   echo "Info: Initializing device $DEVINFO with mkfs ..."
   mkfs -t ext4 $(readlink -f $DEVINFO)
fi

BLKID=`blkid $(readlink -f $DEVINFO) | awk '{print $2}' | sed s/\"//g`
echo "Info:  Updating the /etc/fstab ..."
mkdir -p $mountpoint
cp -p /etc/fstab /etc/fstab.backup.$$
echo "$BLKID $mountpoint ext4 defaults,nofail 0 2" >> /etc/fstab
echo "Info: Mounting device $DEVINFO ..."
mount -a
echo "Info: Change owner $fileowner for $mountpoint"
chown $fileowner:$fileowner $mountpoint

df -h

return 0

}

########################################
# main routing
########################################

echo "Info: Inside mountFS.sh script."

REGION=`curl -s http://169.254.169.254/latest/meta-data/public-hostname | awk -F. '{print $2}'`
INSTID=`curl -s http://169.254.169.254/latest/meta-data/instance-id`

EBSFILE=$1
if [ ! -f $EBSFILE ] ; then
   echo "Info:  No extra volume to attach and mount..."
   exit 1
fi

filecount=1
cat $EBSFILE | while read inrec
do
  volinfo=`echo $inrec | awk '{print $1}'`
  mountp=`echo $inrec | awk  '{print $2}'`
  fowner=`echo $inrec | awk  '{print $3}'`
  echo "Calling mountebs function $volinfo $fowner $mountp $filecount ..."
  mountebs $volinfo  $fowner  $mountp  $filecount
  filecount=$((filecount))
done
echo "Info: End of script mountFS.sh"
#  end of script
