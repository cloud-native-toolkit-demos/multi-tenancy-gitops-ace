#!/usr/bin/env bash

set -eo pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
[[ -n "${DEBUG:-}" ]] && set -x

pushd () {
    command pushd "$@" > /dev/null
}

popd () {
    command popd "$@" > /dev/null
}

set +e
oc version --client | grep '4.7\|4.8'
OC_VERSION_CHECK=$?
set -e
if [[ $OC_VERSION_CHECK -ne 0 ]]; then
  echo "Please use oc client version 4.7 or 4.8 download from https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/stable/ "
fi


if [[ -z ${GITHUB_USER} ]]; then
  echo "We recommend to create a new github organization for all your gitops repos"
  echo "Setup a new organization on github https://docs.github.com/en/organizations/collaborating-with-groups-in-organizations/creating-a-new-organization-from-scratch"
  echo "Please set the environment variable GITHUB_USER when running the script like:"
  echo "GITHUB_USER=acme-org OUTPUT_DIR=gitops-production ./bootstrap.sh"

  exit 1
fi

if [[ -z ${OUTPUT_DIR} ]]; then
  echo "Please set the environment variable OUTPUT_DIR when running the script like:"
  echo "GITHUB_USER=acme-org OUTPUT_DIR=gitops-production ./bootstrap.sh"

  exit 1
fi
mkdir -p "${OUTPUT_DIR}"


SEALED_SECRET_KEY_FILE=${SEALED_SECRET_KEY_FILE:-~/Downloads/sealed-secrets-ibm-demo-key.yaml}

if [[ ! -f ${SEALED_SECRET_KEY_FILE} ]]; then
  echo "File Not Found: ${SEALED_SECRET_KEY_FILE}"

  exit 1
fi

GITOPS_PROFILE=${GITOPS_PROFILE:-0-bootstrap/argocd/single-cluster/bootstrap.yaml}

fork_repos () {
    echo "Github user/org is ${GITHUB_USER}"

    pushd ${OUTPUT_DIR}

    if [[ ! -d gitops-0-bootstrap-ace ]]; then
      gh repo fork cloud-native-toolkit-demos/multi-tenancy-gitops-ace --clone --org ${GITHUB_USER} --remote
      mv multi-tenancy-gitops-ace gitops-0-bootstrap-ace
      cd gitops-0-bootstrap-ace
      git remote set-url --push upstream no_push
      cd ..
    fi

    if [[ ! -d gitops-1-infra ]]; then
      gh repo fork cloud-native-toolkit/multi-tenancy-gitops-infra --clone --org ${GITHUB_USER} --remote
      mv multi-tenancy-gitops-infra gitops-1-infra
      cd gitops-1-infra
      git remote set-url --push upstream no_push
      cd ..
    fi

    if [[ ! -d gitops-2-services ]]; then
      gh repo fork cloud-native-toolkit/multi-tenancy-gitops-services --clone --org ${GITHUB_USER} --remote
      mv multi-tenancy-gitops-services gitops-2-services
      cd gitops-2-services
      git remote set-url --push upstream no_push
      cd ..
    fi

    if [[ ! -d gitops-3-apps ]]; then
      gh repo fork cloud-native-toolkit-demos/multi-tenancy-gitops-apps --clone --org ${GITHUB_USER} --remote
      mv multi-tenancy-gitops-apps gitops-3-apps
      cd gitops-3-apps
      git remote set-url --push upstream no_push
      cd ..
    fi

    popd

}



init_sealed_secrets () {
    echo "Intializing sealed secrets with file ${SEALED_SECRET_KEY_FILE}"
    oc new-project sealed-secrets || true

    oc apply -f ${SEALED_SECRET_KEY_FILE}
}

install_pipelines () {
  echo "Installing OpenShift Pipelines Operator"
  oc apply -n openshift-operators -f https://raw.githubusercontent.com/cloud-native-toolkit/multi-tenancy-gitops-services/master/operators/openshift-pipelines/operator.yaml
}

install_argocd () {
    echo "Installing OpenShift GitOps Operator for OpenShift v4.7"
    pushd ${OUTPUT_DIR}
    oc apply -f gitops-0-bootstrap-ace/setup/ocp47/
    while ! kubectl wait --for=condition=Established crd applications.argoproj.io 2>/dev/null; do sleep 30; done
    popd
}

gen_argocd_patch () {
echo "Generating argocd instance patch for resourceCustomizations"
pushd ${OUTPUT_DIR}
cat <<EOF >argocd-instance-patch.yaml
spec:
  resourceCustomizations: |
    argoproj.io/Application:
      ignoreDifferences: |
        jsonPointers:
        - /spec/source/targetRevision
        - /spec/source/repoURL
    argoproj.io/AppProject:
      ignoreDifferences: |
        jsonPointers:
        - /spec/sourceRepos
EOF
popd
}

patch_argocd () {
  echo "Applying argocd instance patch"
  pushd ${OUTPUT_DIR}
  oc patch -n openshift-gitops argocd openshift-gitops --type=merge --patch-file=argocd-instance-patch.yaml
  popd
}

create_argocd_git_override_configmap () {
echo "Creating argocd-git-override configmap file ${OUTPUT_DIR}/argocd-git-override-configmap.yaml"
pushd ${OUTPUT_DIR}

cat <<EOF >argocd-git-override-configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-git-override
data:
  map.yaml: |-
    map:
    - upstreamRepoURL: https://github.com/cloud-native-toolkit-demos/multi-tenancy-gitops-ace.git
      originRepoUrL: https://github.com/${GITHUB_USER}/multi-tenancy-gitops-ace.git
      originBranch: ocp47-2021-2
    - upstreamRepoURL: https://github.com/cloud-native-toolkit/multi-tenancy-gitops-infra.git
      originRepoUrL: https://github.com/${GITHUB_USER}/multi-tenancy-gitops-infra.git
    - upstreamRepoURL: https://github.com/cloud-native-toolkit/multi-tenancy-gitops-services.git
      originRepoUrL: https://github.com/${GITHUB_USER}/multi-tenancy-gitops-services.git
    - upstreamRepoURL: https://github.com/cloud-native-toolkit-demos/multi-tenancy-gitops-apps.git
      originRepoUrL: https://github.com/${GITHUB_USER}/multi-tenancy-gitops-apps.git
      originBranch: ocp47-2021-2
EOF

popd
}

apply_argocd_git_override_configmap () {
  echo "Applying ${OUTPUT_DIR}/argocd-git-override-configmap.yaml"
  pushd ${OUTPUT_DIR}

  oc apply -n openshift-gitops -f argocd-git-override-configmap.yaml

  popd
}
argocd_git_override () {
  echo "Deploying argocd-git-override webhook"
  oc apply -n openshift-gitops -f https://github.com/csantanapr/argocd-git-override/releases/download/v1.1.0/deployment.yaml
  oc apply -f https://github.com/csantanapr/argocd-git-override/releases/download/v1.1.0/webhook.yaml
  oc label ns openshift-gitops cntk=experiment --overwrite=true
  sleep 10
  oc wait pod --timeout=-1s --for=condition=Ready -l '!job-name' -n openshift-gitops > /dev/null
}

deploy_bootstrap_argocd () {
  echo "Deploying top level bootstrap ArgoCD Application for cluster profile ${GITOPS_PROFILE}"
  pushd ${OUTPUT_DIR}
  oc apply -n openshift-gitops -f gitops-0-bootstrap-ace/${GITOPS_PROFILE}
  popd
}

print_argo_password () {
    echo "Openshift Console UI: $(oc whoami --show-console)"
    echo "Openshift GitOps UI: $(oc get route -n openshift-gitops openshift-gitops-server -o template --template='https://{{.spec.host}}')"
    echo "Openshift GitOps Password: $(oc extract secrets/openshift-gitops-cluster --keys=admin.password -n openshift-gitops)"
}

# main

fork_repos

init_sealed_secrets

install_pipelines

install_argocd

gen_argocd_patch

patch_argocd

create_argocd_git_override_configmap

apply_argocd_git_override_configmap

argocd_git_override

deploy_bootstrap_argocd

print_argo_password

exit 0



