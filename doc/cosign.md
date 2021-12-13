## Sign your own images

The build-images.sh script may sign your images using `cosign`. To do so you'll
need to generate your own key pair and a password for its private key, then
publish the private key password as `COSIGN_PASSWORD`. 

First install `cosign` with these instructions: <https://github.com/sigstore/cosign/tree/main#installation>

Then generate your own key pair:

```bash
pushd .github/workflows
rm cosign.key cosign.pub
export COSIGN_PASSWORD=podtato
cosign generate-key-pair
popd
```

Finally, invoke the `build_images.sh` script:

```bash
PUSH_TO_REGISTRY=1 ./podtato-head/build/build_images.sh
```
