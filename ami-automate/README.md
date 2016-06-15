# AMI Creation / Rotation

This bash script will do the follwing tasks:

 * Automated AMI creation for the specified instances 
 * Automated removal of week AMIs created by this tool
 * All AMI names are formatted using the date 

### Prerequisites

* AWS micro/nano instance (you may also use existing instances)
* Python / PIP installtion
* AWS ClI installation
* IAM user creation for running the bash script
* IAM user access can be AmazonEC2FullAccess for simplicity sake 
 

AWS CLI tools come pre bundled in Amazon Linux AMI instances 
Alternatively AWS-CLI tool can be installed as follows for Centos/ Redhat systems

### Installation on Red Hat/CentOS

```
# Install epel repo for pip 
sudo yum install epel-release -y

# Install PIP
sudo yum install python-pip -y

# Install AWS CLI tool 
sudo pip install awscli

```

### Steps to be performed on AWS EC2 panel

* Create IAM user 
* Preserve Access Key, Secret Key securely 
* Attach correct policy to the user

For simplicity sake we are giving full access to the IAM user.
This needs to be updated with a more limited permission to harden security  
Following is the sample IAM policy 



```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "ec2:*",
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
```

### Configure AWS-CLI on server  

Login to server having the bash script 
Run the following command

```
sudo aws configure

AWS Access Key ID: (Enter in the IAM credentials generated above.)
AWS Secret Access Key: (Enter in the IAM credentials generated above.)
Default region name: (The region that this instance is in: i.e. us-east-1, eu-west-1, etc.)
Default output format: (Enter "text".)```

```

Post the above steps the server will be ready to run the bash sctipt.

Please don't forget to create a new folder for the script like below.

```
sudo mkdir -p /custom_scripts/
```
Both the files should be kept in folder above.

Also add the instance-ids of all the EC2 instances of which AMI need to be created, to the file named  /custom_scripts/ami.txt

```
sudo vim /custom_scripts/ami.txt
```
