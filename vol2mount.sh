#!/bin/bash
#  This script create the file contains the volume need to be checked and mount
#  for the server with the tag server=hostname
#  Next --> Should call the script to do the actual attach and mount the volumes.  
#  ScriptName: vol2mount.sh
#  Creator   : toaivo

TFILE1=/tmp/tfile1.out
TFILE2=/tmp/tfile2.out
VOL2MOUNT=/tmp/volume2mount.txt
HN=`hostname`

:> $TFILE1
:> $TFILE2
:> $VOL2MOUNT

# list all volumes that available for this host (not mounted yet)
aws ec2 describe-volumes --region us-west-2 --query "Volumes[].[VolumeId,State]" --filters "Name=tag:Server,Values=$HN" --output text | grep available > $TFILE1

echo "There is `wc -l $TFILE1` to mount"

# generate the list of volumes with vol-id, mounting point, owner info from the tags.
if [ -s $TFILE1 ] ; then
  cat $TFILE1 | while read inrec
  do
     VOLID=`echo $inrec | awk '{print $1}'`
     aws ec2 describe-volumes --region us-west-2 --volume-ids $VOLID --query "Volumes[].Tags[]" --output text > $TFILE2
     MP=`grep Mounting $TFILE2 | awk '{print $2}'`
     OWNER=`grep Owner $TFILE2 | awk '{print $2}'`
     echo "$VOLID $MP $OWNER" >> $VOL2MOUNT
   done
else
   echo "No Volume to mount."
fi
echo "End of vol2mount.sh script"
