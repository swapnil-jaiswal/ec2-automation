#!/bin/bash
#Script to create AMI of server on daily basis and deleting AMI older than n (= 7) no of days

## Location of this bash file should be in /custom_scripts/
mkdir -p /custom_scripts/
cd /custom_scripts/
## in case you don't want to take instance id from an external text file you can hardcode as below##
#declare -a ami_ids=('i-dummy-id1' 'i-dummy-id2' 'i-dummy-id3' );
ami_ids='/custom_scripts/ami.txt'

for i in `cat $ami_ids`
do

echo -e "----------------------------------\n Picking up instance $i at `date`   \n----------------------------------"

##To create a unique AMI name for this script
echo "$i-`date +%d%b%y`" > /tmp/$i\_aminame.txt

echo -e "Starting the Daily AMI creation for  instance: `cat /tmp/$i\_aminame.txt`\n"

#To create AMI of defined instance
aws ec2 create-image --instance-id $i --name "`cat /tmp/$i\_aminame.txt`"  --description "Automated AMI for \$i\ " --no-reboot >  /tmp/$i\_amiID.txt

##Showing the AMI name created by AWS
echo -e "AMI ID is: `cat  /tmp/$i\_amiID.txt `\n"

##Finding AMI older than 3 days which needed to be removed
echo -e "Looking for AMI older than 7 days:\n "
echo "instance-`date +%d%b%y --date '8 days ago'`" > /tmp/$i\_amidel.txt

##Finding Image ID of instance which needed to be Deregistered
aws ec2 describe-images --filters "Name=name,Values=`cat /tmp/$i\_amidel.txt`" | grep -i imageid | awk '{ print  $4 }' > /tmp/$i\_imageid.txt

if [[ -s /tmp/$i\_imageid.txt ]];
then

echo -e "Following AMI is found : `cat /tmp/$i\_imageid.txt`\n"

##Find the snapshots attached to the Image need to be Deregister
aws ec2 describe-images --image-ids `cat /tmp/$i\_imageid.txt` | grep snap | awk ' { print $4 }' > /tmp/snap.txt

echo -e "Following are the snapshots associated with it : `cat /tmp/$i\_snap.txt`:\n "
echo -e "Starting the Deregister of AMI... \n"

##Deregistering the AMI 
aws ec2 deregister-image --image-id `cat /tmp/$i\_imageid.txt`

##Deleting snapshots attached to AMI
echo -e "\nDeleting the associated snapshots.... \n"
for i in `cat /tmp/$i\_snap.txt`;do aws ec2 delete-snapshot --snapshot-id $i ; done

else

echo -e "No AMI found older than minimum required no of days"
fi


done
