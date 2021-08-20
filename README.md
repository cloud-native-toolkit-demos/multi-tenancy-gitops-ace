# Cloud Native Toolkit Deployment Guides

This is demo gitops git repository for IBM Cloud Paks.

This demo repo have a default selection to deploy IBM App Connect (ACE).

### Prerequisites
1. Install the OpenShift CLI `oc`, [download latest oc](https://mirror.openshift.com/pub/openshift-v4/clients/crc/latest/) version 4.7 or 4.8
1. Create [Github](https://github.com) account
2. Install the Github `gh` CLI and login https://github.com/cli/cli
3. Create a new organization on github https://docs.github.com/en/organizations/collaborating-with-groups-in-organizations/creating-a-new-organization-from-scratch
4. Create a [Personal Access Token (PAT)](https://docs.github.com/en/github/authenticating-to-github/keeping-your-account-and-data-secure/creating-a-personal-access-token)
    - Select the check box **repo**
    - Select the check box **admin:repo_hook**

### Setup
- Setup a local git directory to clone all the git repositories
    ```bash
    mkdir -p ace-production
    ```


- Download [sealed-secrets-ibm-demo-key.yaml](https://bit.ly/demo-sealed-master) and save in the default location `~/Downloads/sealed-secrets-ibm-demo-key.yaml`. You can override the location when running the script with `SEALED_SECRET_KEY_FILE`. Remember do not check this file to git.

- Make sure you are connected to the correct OpenShift cluster
    ```bash
    oc whoami --show-console
    ```

- Run the bootstrap script, specify the git org `GIT_ORG`,the Github personal access token `GIT_TOKEN` and the output directory to clone all repos `OUTPUT_DIR`.You can use `DEBUG=true` for verbose output
    ```bash
    curl -sfL https://raw.githubusercontent.com/cloud-native-toolkit-demos/multi-tenancy-gitops-ace/ocp47-2021-2/scripts/bootstrap.sh | \
    GIT_ORG=$REPLACE_WITH_GIT_ORG \
    GIT_TOKEN=$REPLACE_WITH_GIT_TOKEN \
    OUTPUT_DIR=ace-production \
    sh ./scripts/bootstrap.sh
    ```

- When the script is done it prints the ArgoCD UI url that you can open in your browser. To login use the user name `admin` and to get the password use the following command:
    ```bash
    oc extract secrets/openshift-gitops-cluster --keys=admin.password -n openshift-gitops --to=-
    ```

- You can open the output directory containing all the git repositories with VSCode
    ```bash
    code ace-production
    ```

- You can install a different cluster profile using `GITOPS_PROFILE` variable for example `GITOPS_PROFILE=0-bootstrap/argocd/others/3-multi-cluster/bootstrap-cluster-n-prod.yaml`


- The following git repositories will be fork into a new github organization
    - https://github.com/cloud-native-toolkit-demos/multi-tenancy-gitops-ace
    - https://github.com/cloud-native-toolkit-demos/multi-tenancy-gitops-apps
    - https://github.com/cloud-native-toolkit/multi-tenancy-gitops-infra
    - https://github.com/cloud-native-toolkit/multi-tenancy-gitops-services

### References
- This repository shows the reference architecture for gitops directory structure for more info https://cloudnativetoolkit.dev/learning/gitops-int/gitops-with-cloud-native-toolkit

