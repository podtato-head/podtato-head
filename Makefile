GITHUB_USER ?= podtato-head

install-requirements:
	scripts/requirements.sh /usr/local/bin

### podtato-head-microservices

podtato-head-verify:
	$(MAKE) -C podtato-head-microservices vet
	$(MAKE) -C podtato-head-microservices fmt
	$(MAKE) -C podtato-head-microservices test

build-microservices-images:
	podtato-head-microservices/build/build_images.sh
	podtato-head-microservices/build/build_images.sh '' '' '' \
		gcr.io/distroless/static:latest distroless
	podtato-head-microservices/build/build_images.sh '' '' '' \
		registry.access.redhat.com/ubi8/ubi:latest ubi
	podtato-head-microservices/build/build_images.sh '' '' '' \
		distroless.dev/alpine-base chainguard

push-microservices-images:
	PUSH_TO_REGISTRY=1 podtato-head-microservices/build/build_images.sh
	PUSH_TO_REGISTRY=1 podtato-head-microservices/build/build_images.sh '' '' '' \
		gcr.io/distroless/static:latest distroless
	PUSH_TO_REGISTRY=1 podtato-head-microservices/build/build_images.sh '' '' '' \
		registry.access.redhat.com/ubi8/ubi:latest ubi
	PUSH_TO_REGISTRY=1 podtato-head-microservices/build/build_images.sh '' '' '' \
		distroless.dev/alpine-base chainguard

test-microservices: push-microservices-images
	IMAGE_VERSION=test PUSH_TO_REGISTRY=1 podtato-head-microservices/build/build_images.sh
	IMAGE_VERSION=test scripts/test_with_kind.sh
	IMAGE_VERSION=test-distroless scripts/test_with_kind.sh
	IMAGE_VERSION=test-ubi scripts/test_with_kind.sh
	IMAGE_VERSION=test-chainguard scripts/test_with_kind.sh

### podtato-head-server

build-server-images:
	podtato-head-server/build/build_image.sh

push-server-images:
	PUSH_TO_REGISTRY=1 podtato-head-server/build/build_image.sh

test-server:
	PUSH_TO_REGISTRY=1 podtato-head-server/build/build_image.sh
	podtato-head-server/build/test_image.sh
	podtato-head-server/build/test_image.sh '' '' '' distroless
	podtato-head-server/build/test_image.sh '' '' '' ubi
	podtato-head-server/build/test_image.sh '' '' '' chainguard

.PHONY: build-microservices-images push-microservices-images test-microservices install-requirements build-server-images push-server-images test-server podtato-head-verify
