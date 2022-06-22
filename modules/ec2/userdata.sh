#! /bin/bash
LogMessage "Running package update"
sudo apt update -y
LogMessage "Running package upgrade"
sudo apt upgrade -y

#Format data disk
sudo mkfs -t ext4 /dev/nvme1n1
sudo mkdir /data
sudo mount /dev/nvme1n1 /data
UUID=$(blkid -o value -s UUID /dev/nvme1n1)
echo UUID=$UUID /data ext4 defaults,nofail  0  2 >> /etc/fstab

# Configure Cloudwatch agent
LogMessage "Configure Cloudwatch agent"
LogMessage "Download Cloudwatch package"
sudo wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
LogMessage "Install Cloudwatch package"
sudo dpkg -i -E ./amazon-cloudwatch-agent.deb

LogMessage "Configure SSM agent"
LogMessage "Download SSM package"
sudo wget https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/debian_amd64/amazon-ssm-agent.deb
sudo dpkg -i amazon-ssm-agent.deb

# Use cloudwatch config from SSM
LogMessage "Activate Cloudwatch using SSM"
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
-a fetch-config \
-m ec2 \
-c ssm:${ssm_cloudwatch_config} -s
sudo systemctl enable amazon-cloudwatch-agent.service
sudo service amazon-cloudwatch-agent start
