#!/usr/bin/env bash

usage() {
    echo "Usage: $0 <key_file>"
    exit
}

[[ $# -ne 1 ]] && usage
key_file=$1
initfile="$(dirname $0)/00-init.sh"
[[ ! -f ${initfile} ]] && echo "${initfile}: file not found!" && exit
. ${initfile}

gcloud iam service-accounts keys create ${key_file} --iam-account=${SERVICE_ACCOUNT}
echo "${key_file} key file created for ${SERVICE_ACCOUNT}"
ls -l ${key_file}