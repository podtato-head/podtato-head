#! /usr/bin/env bash

# app_namespace
# app_name
# operators_namespace
# operator_name
# catalog_namespace
# catalog_name

# delete podtatoheadapp resource
echo "deleting podtatoheadapp resource ${app_name}"
kubectl delete podtatoheadapp -n ${app_namespace} ${app_name}
kubectl delete namespace ${app_namespace}

# delete operator and collateral
echo "deleting subscription et al for operator ${operator_name}"
kubectl delete subscription -n ${operators_namespace} ${operator_name}
kubectl delete csv -n ${operators_namespace} -l "operators.coreos.com/${operator_name}.operators"
kubectl delete installplan -n ${operators_namespace} -l "operators.coreos.com/${operator_name}.operators"
kubectl delete services -n ${operators_namespace} -l "operators.coreos.com/${operator_name}.operators"
kubectl delete deployments -n ${operators_namespace} -l "operators.coreos.com/${operator_name}.operators"

# delete catalogsource
echo "deleting catalog that publishes operator ${operator_name}"
kubectl delete catalogsource -n ${catalog_namespace} ${catalog_name}

# delete olm
echo "uninstalling OLM"
operator-sdk olm uninstall
