GITHUB_USER ?= podtato-head

install-requirements:
	scripts/requirements.sh /usr/local/bin

build-images:
	podtato-head-microservices/build/build_images.sh

push-images:
	PUSH_TO_REGISTRY=1 podtato-head-microservices/build/build_images.sh

test-services:
	podtato-head-microservices/build/test_services.sh

.PHONY: build-images push-images test-services install-requirements