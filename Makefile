APP ?= cloud-run-microservice
REPO ?= chugai
PROJECT ?= aiml-play
REGION ?= us-central1
IMAGE_VER ?= 0.1.0
IMAGE ?= $(APP):$(IMAGE_VER)
IMAGE_PATH ?= $(REGION)-docker.pkg.dev/$(PROJECT)/$(REPO)/$(IMAGE)
PORT ?= 8080
CB_YAML ?= cloudbuild.yaml
SRC_DIR ?= .

FORCE:

install:
	source venv/bin/activate && pip install -r $(SRC_DIR)/requirements.txt && pip install invoke

repo:
	gcloud artifacts repositories create $(REPO) --location $(REGION) --repository-format=docker

build: FORCE 
	time gcloud builds submit --config=$(CB_YAML) \
	--substitutions=_LOCATION="$(REGION)",_REPOSITORY="$(REPO)",_IMAGE="$(IMAGE)" $(SRC_DIR)

deploy:
	source scripts/00-init.sh && invoke deploy

build:
	source scripts/00-init.sh && invoke build

dev:
	source scripts/00-init.sh && invoke dev

test:
	source scripts/00-init.sh && invoke test