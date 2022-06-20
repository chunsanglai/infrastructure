#! /bin/bash
LogMessage "Running package update"
apt update -y
LogMessage "Running package upgrade"
apt upgrade -y

# Configure Cloudwatch agent
LogMessage "Configure Cloudwatch agent"
LogMessage "Download Cloudwatch package"
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
LogMessage "Install Cloudwatch package"
dpkg -i -E ./amazon-cloudwatch-agent.rpm
LogMessage "Cloudwatch package deleted after install"
rm amazon-cloudwatch-agent.rpm

# Use cloudwatch config from SSM
LogMessage "Activate Cloudwatch using SSM"
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
-a fetch-config \
-m ec2 \
-c ssm:${ssm_cloudwatch_config} -s

# Install AWS CLI package
LogMessage "Installing AWS CLI package"
apt install awscli -y

