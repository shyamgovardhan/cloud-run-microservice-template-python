#!/usr/bin/env bash

export APP="cloud-run-fastapi"
export REPOSITORY="chugai"
export REGION="us-central1"
export PROJECT_ID="aiml-play"
export IMAGE_VER="0.1.0"
export GOOGLE_APPLICATION_CREDENTIALS="/home/shyamg/dev/keys/aiml-play-557204fa5644.json"
export SERVICE_ACCOUNT_ID="chugai-token-creator-sa"

export PROJECT_NUMBER="$(gcloud projects describe ${PROJECT_ID} --format='value(projectNumber)')"
export SERVICE_ACCOUNT="${SERVICE_ACCOUNT_ID}@${PROJECT_ID}.iam.gserviceaccount.com"
export CLOUD_BUILD_SERVICE_ACCOUNT="$PROJECT_NUMBER@cloudbuild.gserviceaccount.com"
export IMAGE="${APP}:${IMAGE_VER}"
export IMAGE_PATH="${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPOSITORY}/${IMAGE}"
export SRC_DIR="."
export CB_YAML="${SRC_DIR}/cloudbuild.yaml"
export PORT="8080"