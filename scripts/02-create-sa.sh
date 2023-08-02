#!/usr/bin/env bash

initfile="$(dirname $0)/00-init.sh"
[[ ! -f ${initfile} ]] && echo "${initfile}: file not found!" && exit
. ${initfile}

createSa() {
    sa=$1
    echo "Creating service account <${sa}>"
    status=$(gcloud iam service-accounts list --filter=${sa} --format="value(disabled)")
    echo "status: <${status}>"
    [[ "${status}" == "False" ]] && echo "${sa}: service account exists!" && return
    gcloud iam service-accounts create ${sa}
}

createSa ${SERVICE_ACCOUNT_ID}