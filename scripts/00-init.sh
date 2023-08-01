#!/usr/bin/env bash

export APP="cloud-run-microservice"
export REPOSITORY="chugai"
export IMAGE_VER="0.1.0"
export IMAGE="${APP}:${IMAGE_VER}"
export GOOGLE_CLOUD_PROJECT="aiml-play"
export REGION="us-central1"
export GOOGLE_APPLICATION_CREDENTIALS="/home/shyamg/dev/keys/aiml-play-557204fa5644.json"
export PROJECT_ID="$(gcloud config get-value project)"
export PROJECT_NUMBER="$(gcloud projects describe $(gcloud config get-value project) --format='value(projectNumber)')"
export SERVICE_ACCOUNT="token-creator"