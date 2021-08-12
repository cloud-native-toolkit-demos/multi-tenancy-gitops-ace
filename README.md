# Cloud Native Toolkit Deployment Guides

This is demo gitops git repository for IBM Cloud Paks.

This demo repo have a default selection to deploy IBM App Connect (ACE).

### Prerequisites
- Install the Github CLI and login https://github.com/cli/cli
- Install the OpenShift CLI `oc` latest version 4.7 or 4.8
- Create a new organization on github https://docs.github.com/en/organizations/collaborating-with-groups-in-organizations/creating-a-new-organization-from-scratch


### Setup
- Setup a local git directory to clone all the git repositories
    ```bash
    mkdir -p ace-production
    cd ace-production
    ```


- Download [sealed-secrets-ibm-demo-key.yaml](https://bit.ly/demo-sealed-master) and save in the default location `~/Downloads/sealed-secrets-ibm-demo-key.yaml`. You can override the location when running the script with `SEALED_SECRET_KEY_FILE`. Remember do not check this file to git.

- Run the bootstrap script, specify the git org `GITHUB_ORG` and the output directory to clone all repos `OUTPUT_DIR`. You can use `DEBUG=true` for verbose output
    ```bash
    curl -sfL https://raw.githubusercontent.com/cloud-native-toolkit-demos/multi-tenancy-gitops-ace/ocp47-2021-2/scripts/bootstrap.sh | DEBUG=true GITHUB_ORG=<YOUR_GITHUB_ORG> OUTPUT_DIR=ace-production bash
    ```

- Open the ArgoCD UI from the OpenShift Console, then use `admin` as the username and password should have printed in the previous command

- You can open the directory with VSCode
    ```bash
    code ace-production
    ```
- You can install a different cluster profile using `GITOPS_PROFILE` variable for example `GITOPS_PROFILE=0-bootstrap/argocd/others/3-multi-cluster/bootstrap-cluster-n-prod.yaml`

- The following git repositories will be fork into a new github organization
    - https://github.com/cloud-native-toolkit-demos/multi-tenancy-gitops-ace
    - https://github.com/cloud-native-toolkit-demos/multi-tenancy-gitops-apps
    - https://github.com/cloud-native-toolkit/multi-tenancy-gitops-infra
    - https://github.com/cloud-native-toolkit/multi-tenancy-gitops-services




This repository shows the reference architecture for gitops directory structure for more info https://cloudnativetoolkit.dev/learning/gitops-int/gitops-with-cloud-native-toolkit

