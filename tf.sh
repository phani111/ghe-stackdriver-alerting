#!/bin/bash

tf_command=$@

# vars
[[ -z "${TF_VAR_branch}" ]] && branch=$(git rev-parse --abbrev-ref HEAD) || branch=$TF_VAR_branch
echo "branch is set to \"$branch\""
gcs_bucket="sap-tools-secrets-$branch"
gcs_prefix="stackdriver-tf-state/$branch"
gcp_project="sap-pi-ops-tools-$branch-github"

# Locate Root Dir
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

if [[ $tf_command == "init" ]] || [[ $tf_command == "init*" ]]; then
    # Remove Terraform Files and Dirs
    rm -rf $DIR/.terraform
    rm -f $DIR/.terraform.tfstate
    rm -f $DIR/.terraform.tfstate.backup

    terraform $tf_command \
        -backend-config="bucket=$gcs_bucket" \
        -backend-config="prefix=$gcs_prefix"
else
    terraform $tf_command \
        -var="branch=$branch" \
        -var="gcp_project=$gcp_project"
fi
