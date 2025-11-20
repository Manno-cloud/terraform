#!/bin/bash

# Enable logging
exec > >(tee /var/log/ssm-check.log | logger -t user-data -s 2>/dev/console) 2>&1

echo "===== Starting SSM Health Check ====="

echo "===== Updating OS ====="
yum update -y

echo "===== Installing AWS CLI (if missing) ====="
yum install -y awscli

echo "===== Checking SSM Agent Status ====="
systemctl status amazon-ssm-agent || echo "SSM agent not running!"
systemctl restart amazon-ssm-agent

echo "===== AWS CLI Version ====="
aws --version

echo "===== EC2 Metadata (Instance ID) ====="
curl -s http://169.254.169.254/latest/meta-data/instance-id

echo "===== Checking Reachability: ssm ====="
nc -zv ssm.ap-northeast-1.amazonaws.com 443 || echo "NG: ssm endpoint unreachable"

echo "===== Checking Reachability: ssmmessages ====="
nc -zv ssmmessages.ap-northeast-1.amazonaws.com 443 || echo "NG: ssmmessages endpoint unreachable"

echo "===== Checking Reachability: ec2messages ====="
nc -zv ec2messages.ap-northeast-1.amazonaws.com 443 || echo "NG: ec2messages endpoint unreachable"

echo "===== Checking Logs Endpoint ====="
nc -zv logs.ap-northeast-1.amazonaws.com 443 || echo "NG: CloudWatch Logs endpoint unreachable"

echo "===== IAM Role check (metadata) ====="
curl -s http://169.254.169.254/latest/meta-data/iam/info

echo "===== DNS Resolution Test ====="
nslookup amazonaws.com || dig amazonaws.com

echo "===== Checking SSM Agent Logs ====="
tail -n 50 /var/log/amazon/ssm/amazon-ssm-agent.log || echo "Log file missing"

echo "===== Route Table ====="
ip route

echo "===== SSM Health Check Completed ====="