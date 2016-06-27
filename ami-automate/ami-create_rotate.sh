#!/bin/bash
# Script to create AMI of server on daily basis and deleting AMI older than n no of days ( 2 < n < 30 )
# Location of this bash file & ami.txt should be in /custom_scripts/
# run this program as root or make sure the user is owner of /custom_scripts/ dir
mkdir -p /custom_scripts/
cd /custom_scripts/
ami_ids='/custom_scripts/ami.txt'

for i in `cat $ami_ids`
do
echo -e "----------------------------------\n Picking up instance $i at `date`   \n----------------------------------"

#Create a unique AMI name for this script
echo "$i-`date +%d%b%y`" > /tmp/$i\_aminame.txt
echo -e "Starting the Daily AMI creation for  instance: `cat /tmp/$i\_aminame.txt`\n"

# Create AMI of defined instance
aws ec2 create-image --instance-id $i --name "`cat /tmp/$i\_aminame.txt`"  --description "Automated AMI for \$i\ " --no-reboot >  /tmp/$i\_amiID.txt

#Showing the AMI name created by AWS
echo -e "AMI ID is: `cat  /tmp/$i\_amiID.txt `\n"

# Clean up ami-name-list, ami-ID, snapid for this iteration #
> /tmp/$i\_amidel.txt  ; > /tmp/$i\_imageid.txt  ; > /tmp/$i\_snap.txt ;
echo -e "Calculating name of  AMI which need to be removed for instance $i which are older than 7 days but not older than 30 days"
for d in `seq 7 30`;
  do
    echo "$i-`date +%d%b%y --date "$d days ago"`" > /tmp/$i\_amidel.txt
# Finding Image ID corresponding to instance name above - which needed to be Deregistered
    aws ec2 describe-images --filters "Name=name,Values=`cat /tmp/$i\_amidel.txt`" | grep -i ami | awk '{ print  $9 }' >> /tmp/$i\_imageid.txt
done

if [[ -s /tmp/$i\_imageid.txt ]];
then
echo -e "AMI id corresponfing to above AMI names: `cat /tmp/$i\_imageid.txt`\n"
# Find the snapshots attached to the Image need to be Deregister
for imageid in `cat /tmp/$i\_imageid.txt`; do
aws ec2 describe-images --image-ids $imageid | grep snap | awk ' { print $4 }' >> /tmp/$i\_snap.txt
echo -e "Deregistering the AMI... \n $imageid"
aws ec2 deregister-image --image-id $imageid
done

echo -e "Following are the snapshots associated with it :\n`cat /tmp/$i\_snap.txt`\n"
echo -e "Waiting for the AMI deregistration to complete.. for 5 mins  "
sleep 300
# Deleting snapshots attached to AMI
echo -e "\nDeleting the associated snapshots.... \n"
for snapid in `cat /tmp/$i\_snap.txt`; do
aws ec2 delete-snapshot --snapshot-id $snapid
echo -e "Deleted the snapshot... \n $snapid"
sleep 1
done

else
echo -e "No AMI found older than minimum required no of days"
fi

done
