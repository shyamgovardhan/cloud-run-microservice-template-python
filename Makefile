include ./scripts/00-init.sh

FORCE:

check: 
	echo "SRC_DIR: ${SRC_DIR}"

install:
	source venv/bin/activate && pip install -r ${SRC_DIR}/requirements.txt -r ${SRC_DIR}/requirements-test.txt

repo:
	gcloud artifacts repositories create ${REPOSITORY} --location ${REGION} --repository-format=docker

define removeDockerImages =
for f in `docker images | grep -v REPOSITORY | awk '{print $3}'`; do docker image rm -f $f; done
endef

dockerClean:
	${value removeDockerImages}

clean: dockerClean
	rm -rf app/__pycache__
	gcloud artifacts docker images delete ${IMAGE_PATH} --quiet

build:
	invoke build

deploy:
	invoke deploy

make deployDelete:
	gcloud run deploy ${APP} \
	--image us-central1-docker.pkg.dev/aiml-play/chugai/${IMAGE} \
	--region us-central1 \
	--port 8080 \
	--platform managed \
	--allow-unauthenticated

dev:
	source venv/bin/activate && invoke dev

lint:
	source venv/bin/activate && invoke lint

test:
	invoke test

curl:
	curl -s http://localhost:8080 | jq

runImageLocal:
	docker run -d --name ${APP} -p ${PORT}:${PORT} myimage:latest

runImage:
	docker run -d --name ${APP} -p ${PORT}:${PORT} ${IMAGE_PATH}

run:
	source venv/bin/activate  && uvicorn app.main:app --host 0.0.0.0 --port ${PORT} --reload