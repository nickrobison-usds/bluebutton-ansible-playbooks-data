#!/usr/bin/env bash

set -e

exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

export AWS_DEFAULT_REGION=us-east-1
export AWS_BIN=/usr/local/bin/aws

EBS_JENKINS_AVAILABLE="$($AWS_BIN ec2 describe-volumes \
  --filter Name=attachment.status,Values=attached \
  --filter Name=tag-key,Values="Name" Name=tag-value,Values="bcda-jenkins-data" \
  --query 'Volumes[*].{Status:State}' \
  --output text | grep 'available')"

if [ -n "$EBS_JENKINS_AVAILABLE" ];
then
  export JENKINS_DATA_VOLUME="$($AWS_BIN ec2 describe-volumes \
    --filter Name=attachment.status,Values=attached \
    --filter Name=tag-key,Values="Name" Name=tag-value,Values="bcda-jenkins-data" \
    --query 'Volumes[*].{VolumeID:VolumeId}' --output text)"
  export INSTANCE_ID=$(curl http://169.254.169.254/latest/meta-data/instance-id)

  if $AWS_BIN ec2 attach-volume --volume-id $JENKINS_DATA_VOLUME --instance-id $INSTANCE_ID --device /dev/sdf; then
    sleep 60
    mkdir -p /var/lib/jenkins_home
    mount /dev/xvdf /var/lib/jenkins_home
  fi
fi
