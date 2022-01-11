## VAULT SETUP
```shell
vault secrets enable aws

vault write aws/config/root
    access_key=** \
    secret_key=** \
    region=**
    
vault write aws/roles/read-s3 \
    credential_type=iam_user \
    policy_document=-<<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": "arn:aws:s3:::*"
    }
  ]
}
EOF

vault auth enable aws

vault write -force auth/aws/config/client \
    access_key=** \ 
    secret_key=**

vault policy write read-s3 - <<EOF
path "aws/creds/read-s3" {
    capabilities = ["read"]
}
EOF

vault write auth/aws/role/kabu-lambda-extension-demo-lambda-role \
    auth_type=iam \
    bound_iam_principal_arn="${GET_FROM_TF_OUTPUT}" \
    policies=read-s3 \
    ttl=5m
```

## CREATE INFRA
* replace `vault_addr` in main.tf
* do `terraform apply`
* copy an arn from output


## TEST
* test a function from AWS console
* see the log