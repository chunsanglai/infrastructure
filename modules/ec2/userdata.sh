#! /bin/bash
LogMessage "Running package update"
sudo apt update -y
LogMessage "Running package upgrade"
sudo apt upgrade -y

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
systemctl enable amazon-cloudwatch-agent.service
service amazon-cloudwatch-agent start

# Install AWS CLI package
LogMessage "Installing AWS CLI package"
sudo apt install awscli -y

