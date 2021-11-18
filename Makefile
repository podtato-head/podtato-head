GITHUB_USER ?= podtato-head

build-images:
	build/build_containers.sh "${GITHUB_USER}" "${GITHUB_TOKEN}"

push-images:
	PUSH_TO_REGISTRY=1 build/build_containers.sh "${GITHUB_USER}" "${GITHUB_TOKEN}"

test-services:
	build/test_services.sh "${GITHUB_USER}" "${GITHUB_TOKEN}"

.PHONY: build-images push-images test-services