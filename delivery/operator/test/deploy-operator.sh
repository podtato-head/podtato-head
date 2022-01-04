#! /usr/bin/env bash

# root_dir
# github_user
# github_token
# image_base_url
# operator_version
# operator_name
# operators_namespace
# catalog_name
# catalog_namespace

source ${root_dir}/scripts/registry-secrets.sh
# install registry secret in catalog namespace
install_ghcr_secret "${catalog_namespace}" "${github_user}" "${github_token}"
# install registry secret in operators namespace
install_ghcr_secret "${operators_namespace}" "${github_user}" "${github_token}"

kubectl apply -f - <<EOF
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
    name: ${catalog_name}
    namespace: ${catalog_namespace}
spec:
    sourceType: grpc
    image: ${image_base_url}-catalog:v${operator_version}
    secrets:
      - ghcr
    displayName: ${catalog_name}
    publisher: podtato-head
    updateStrategy:
        registryPoll:
            interval: 10m
EOF

kubectl apply -f - <<EOF
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
    name: ${operator_name}
    namespace: ${operators_namespace}
spec:
    channel: alpha
    installPlanApproval: Automatic
    name: ${operator_name}
    source: ${catalog_name}
    sourceNamespace: ${catalog_namespace}
    startingCSV: ${operator_name}.v${operator_version}
EOF

operator_controller_name=${operator_name}-controller-manager

declare -i tries=90
found=
for ((i = 0 ; i < ${tries} ; i++)); do
    if [[ -z "${found}" ]]; then
        echo "awaiting service account creation... ${i}/${tries}"
        sleep 1
        found=$(kubectl get -n ${operators_namespace} serviceaccounts ${operator_controller_name} -o name 2> /dev/null || true)
    else
        echo "serviceaccount created, breaking"
        break
    fi
done
kubectl patch serviceaccount -n ${operators_namespace} ${operator_controller_name} --patch '{ "imagePullSecrets": [{ "name": "ghcr" }]}'

found=
for ((i = 0 ; i < ${tries} ; i++)); do
    if [[ -z "${found}" ]]; then
        echo "awaiting deployment creation... ${i}/${tries}"
        sleep 1
        found=$(kubectl get -n ${operators_namespace} deployment ${operator_controller_name} -o name 2> /dev/null || true)
    else
        echo "deployment created, breaking"
        break
    fi
done
kubectl wait --for=condition=Available -n ${operators_namespace} --timeout=90s deployment ${operator_controller_name}
