GITHUB_USER ?= podtato-head

install-requirements:
	hack/requirements.sh /usr/local/bin

build-images:
	podtato-head/build/build_images.sh

push-images:
	PUSH_TO_REGISTRY=1 podtato-head/build/build_images.sh

test-services:
	podtato-head/build/test_services.sh

.PHONY: build-images push-images test-services install-requirements