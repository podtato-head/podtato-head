GITHUB_USER ?= podtato-head

build-images:
	podtato-head/build/build_images.sh "${GITHUB_USER}" "${GITHUB_TOKEN}"

push-images:
	PUSH_TO_REGISTRY=1 podtato-head/build/build_images.sh "${GITHUB_USER}" "${GITHUB_TOKEN}"

test-services:
	podtato-head/build/test_services.sh "${GITHUB_USER}" "${GITHUB_TOKEN}"

.PHONY: build-images push-images test-services