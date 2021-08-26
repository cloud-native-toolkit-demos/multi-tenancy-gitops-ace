#!/usr/bin/env bash

set -eo pipefail

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
[[ -n "${DEBUG:-}" ]] && set -x


SEALED_SECRET_KEY_FILE=${SEALED_SECRET_KEY_FILE:-~/Downloads/sealed-secrets-ibm-demo-key.yaml}

if [[ ! -f ${SEALED_SECRET_KEY_FILE} ]]; then
  echo "File Not Found: ${SEALED_SECRET_KEY_FILE}"

  exit 1
fi

CP_EXAMPLES=${CP_EXAMPLES:-true}
ACE_SCENARIO=${ACE_SCENARIO:-true}

TEMP_SCRIPT=$(mktemp)
curl -sfL https://raw.githubusercontent.com/cloud-native-toolkit/multi-tenancy-gitops/master/scripts/bootstrap.sh > ${TEMP_SCRIPT}
source ${TEMP_SCRIPT}
