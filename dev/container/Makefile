
REGISTRY_URL = asia-northeast1-docker.pkg.dev/gcloud-and-terraform/django-app

buildpush:
	cd app && \
	docker build --platform linux/x86_64 -t $(REGISTRY_URL)/app:latest . && \
	docker push $(REGISTRY_URL)/app:latest
