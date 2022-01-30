{
 "Version": "2012-10-17",
 "Statement": [
	{
	 "Sid": "BucketReadAccess",
	 "Effect": "Allow",
	 "Action": [
		"s3:ListBucket*",
		"s3:GetBucket*"
	 ],
	 "Resource": [
		"arn:aws:s3:::${website_bucket}"
	 ]
	},
	{
	 "Sid": "BucketObjectsReadAccess",
	 "Effect": "Allow",
	 "Action": [
		"s3:Get*Object*",
		"s3:List*Object*"
	 ],
	 "Resource": [
		"arn:aws:s3:::${website_bucket}/*"
	 ]
	}
 ]
}
