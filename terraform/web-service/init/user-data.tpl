#!/bin/bash -x
INSTANCE_ID="$(curl -s http://169.254.169.254/latest/meta-data/instance-id)"
apt-get update
apt-get install -y awscli s3fs
# curl -s http://169.254.169.254/latest/meta-data/role/website-dev-eu-west-2-instance-profile
# aws sts assume-role --role-arn "arn:aws:iam::${aws_account_id}:instance-profile/${instance_profile}" --role-session-name EC2-Instance-Session
mkdir -p /var/www/html/ /var/cache/s3fs-website
apt-get install -y apache2 apache2-bin apache2-data apache2-utils
s3fs "${website_bucket}" /var/www/html -o allow_other -o gid=$(id -g www-data) -o iam_role=auto -o use_cache=/var/cache/s3fs-website \
  -o check_cache_dir_exist -o del_cache -o nonempty -o use_sse -o endpoint="${aws_region}"

echo "website bucket: ${website_bucket}"
