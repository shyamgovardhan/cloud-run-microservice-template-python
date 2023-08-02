#!/usr/bin/env bash

initfile="$(dirname $0)/00-init.sh"
[[ ! -f ${initfile} ]] && echo "${initfile}: file not found!" && exit
. ${initfile}

createSa() {
    sa=$1
    status=$(gcloud iam service-accounts list --filter=chugai-token-creator-sa1 --format="value(disabled)")
    [ "${status}" == "False" ]] && echo "${sa}: service account exists!" && return
    gcloud iam service-accounts create ${SERVICE_ACCOUNT_ID}
}

grantPerm() {
    sa=$1
    role=$2
    echo "sa: <$sa>"
    echo "role: <$role>"
    gcloud projects add-iam-policy-binding ${PROJECT_ID} \
        --member="serviceAccount:${sa}" \
        --role="roles/${role}"
}


grantPerm ${SERVICE_ACCOUNT} "iam.serviceAccountTokenCreator"
grantPerm ${SERVICE_ACCOUNT} "run.invoker"
grantPerm ${CLOUD_BUILD_SERVICE_ACCOUNT} "iam.serviceAccountTokenCreator"
grantPerm ${CLOUD_BUILD_SERVICE_ACCOUNT} "run.admin"
grantPerm ${CLOUD_BUILD_SERVICE_ACCOUNT} "iam.serviceAccountUser"
grantPerm ${CLOUD_BUILD_SERVICE_ACCOUNT} "artifactregistry.repoAdmin"