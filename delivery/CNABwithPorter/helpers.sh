#!/usr/bin/env bash
set -euo pipefail

relocate() {
  NEWIMAGE=$1
  yq write -d 1 -i manifests/manifest.yaml 'spec.template.spec.containers.(name==server).image' $NEWIMAGE
}

# Call the requested function and pass the arguments as-is
"$@"
