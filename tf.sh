#!/bin/bash

branch=$1
tf_command=$2

# Locate Root Dir
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# Remove Terraform Files and Dirs
rm -rf $DIR/.terraform
rm -f $DIR/.terraform.tfstate
rm -f $DIR/.terraform.tfstate.backup

gcs_bucket="sap-tools-secrets-$branch"
gcs_prefix="stackdriver-tf-state/$branch"

terraform $tf_command \
    -backend-config="bucket=$gcs_bucket" \
    -backend-config="prefix=$gcs_prefix" \
    -var="branch=$branch" \
    -var="gcp_project=sap-pi-ops-tools-$branch-github"
