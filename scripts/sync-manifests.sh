#!/usr/bin/env bash

set -euo pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOTDIR="$(cd ${SCRIPTDIR}/..; pwd )"
[[ -n "${DEBUG:-}" ]] && set -x

for LAYER in 1-infra 2-services 3-apps
do

    for CLUSTER in 1-shared-cluster/cluster-1-cicd-dev-stage-prod 1-shared-cluster/cluster-n-prod 2-isolated-cluster/cluster-1-cicd-dev-stage 2-isolated-cluster/cluster-n-prod 3-multi-cluster/cluster-1-cicd 3-multi-cluster/cluster-2-dev 3-multi-cluster/cluster-3-stage 3-multi-cluster/cluster-n-prod
    do

        cp -a 0-bootstrap/argocd/single-cluster/${LAYER}/argocd 0-bootstrap/argocd/others/${CLUSTER}/${LAYER}/

    done

done
exit 0

cp 0-bootstrap/argocd/single-cluster/2-services/argocd/instances/* 0-bootstrap/argocd/others/1-shared-cluster/cluster-1-cicd-dev-stage-prod/2-services/argocd/instances/
cp 0-bootstrap/argocd/single-cluster/2-services/argocd/operators/* 0-bootstrap/argocd/others/1-shared-cluster/cluster-1-cicd-dev-stage-prod/2-services/argocd/operators/
cp 0-bootstrap/argocd/single-cluster/2-services/argocd/instances/* 0-bootstrap/argocd/others/1-shared-cluster/cluster-n-prod/2-services/argocd/instances/
cp 0-bootstrap/argocd/single-cluster/2-services/argocd/operators/* 0-bootstrap/argocd/others/1-shared-cluster/cluster-n-prod/2-services/argocd/operators/

cp 0-bootstrap/argocd/single-cluster/2-services/argocd/instances/* 0-bootstrap/argocd/others/2-isolated-cluster/cluster-1-cicd-dev-stage/2-services/argocd/instances/
cp 0-bootstrap/argocd/single-cluster/2-services/argocd/operators/* 0-bootstrap/argocd/others/2-isolated-cluster/cluster-1-cicd-dev-stage/2-services/argocd/operators/
cp 0-bootstrap/argocd/single-cluster/2-services/argocd/instances/* 0-bootstrap/argocd/others/2-isolated-cluster/cluster-n-prod/2-services/argocd/instances/
cp 0-bootstrap/argocd/single-cluster/2-services/argocd/operators/* 0-bootstrap/argocd/others/2-isolated-cluster/cluster-n-prod/2-services/argocd/operators/

cp 0-bootstrap/argocd/single-cluster/2-services/argocd/instances/* 0-bootstrap/argocd/others/3-multi-cluster/cluster-1-cicd/2-services/argocd/instances/
cp 0-bootstrap/argocd/single-cluster/2-services/argocd/operators/* 0-bootstrap/argocd/others/3-multi-cluster/cluster-1-cicd/2-services/argocd/operators/
cp 0-bootstrap/argocd/single-cluster/2-services/argocd/instances/* 0-bootstrap/argocd/others/3-multi-cluster/cluster-2-dev/2-services/argocd/instances/
cp 0-bootstrap/argocd/single-cluster/2-services/argocd/operators/* 0-bootstrap/argocd/others/3-multi-cluster/cluster-2-dev/2-services/argocd/operators/
cp 0-bootstrap/argocd/single-cluster/2-services/argocd/instances/* 0-bootstrap/argocd/others/3-multi-cluster/cluster-3-stage/2-services/argocd/instances/
cp 0-bootstrap/argocd/single-cluster/2-services/argocd/operators/* 0-bootstrap/argocd/others/3-multi-cluster/cluster-3-stage/2-services/argocd/operators/
cp 0-bootstrap/argocd/single-cluster/2-services/argocd/instances/* 0-bootstrap/argocd/others/3-multi-cluster/cluster-n-prod/2-services/argocd/instances/
cp 0-bootstrap/argocd/single-cluster/2-services/argocd/operators/* 0-bootstrap/argocd/others/3-multi-cluster/cluster-n-prod/2-services/argocd/operators/
