# Images

## Image build

Images are built by the [scripts/build-image.sh](../scripts/build-image.sh)
script in the repo; both the microservices and single-server projects delegate
to it. `cosign` and `trivy` are optionally used in that script. Consider
contributing new build functionality by starting from the script.

## Runtime images

Runtime images built in this repo are based on each of the following base
images. The image build script takes a parameter for the name and tag suffix for
additional base images.

name | source
-----|-------
scratch | N/A
Google distroless | <https://github.com/GoogleContainerTools/distroless>
Chainguard distroless | <https://github.com/distroless/alpine-base>
ubi-micro | <https://catalog.redhat.com/software/containers/ubi9/ubi-micro/615bdf943f6014fa45ae1b58?tag=latest>
