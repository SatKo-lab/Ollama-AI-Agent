# Create a folder
#!/bin/bash

# This script sets up a GitHub Actions self-hosted runner on macOS.
# See https://github.com/organizations/SatKoLab/settings/actions/runners/new

if [ ! -f .runner/actions-runner-osx-x64-2.324.0.tar.gz ]; then
    # Create a folder
    mkdir .runner && cd .runner
    # Download the latest runner package
    curl -o actions-runner-osx-x64-2.324.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.324.0/actions-runner-osx-x64-2.324.0.tar.gz

    # Optional: Validate the hash
    echo "fbf97cc843c480f0104e2a3d2b1bda86ca467c88da666ac76e432caa2748c683  actions-runner-osx-x64-2.324.0.tar.gz" | shasum -a 256 -c
    
    cd ..
else
    echo "Runner already exists. Skipping download and extraction."
    # Remove all files and folders in .runner except actions-runner-osx-x64-2.324.0.tar.gz
    find .runner -mindepth 1 ! -name 'actions-runner-osx-x64-2.324.0.tar.gz' -exec rm -rf {} +
    sleep 2
    ls -la .runner
fi

cleanup() {
    echo "Removing runner..."
    ./config.sh remove --unattended --token ${RUNNER_ORG_TOKEN} --name "AI-AGENT-RUNNER-*"
}

cd .runner
# Extract the installer
tar xzf ./actions-runner-osx-x64-2.324.0.tar.gz

chmod +x ./config.sh
chmod +x ./run.sh

# Ensure required variables are set
if [[ -z "${RUNNER_ORG_REPO}" || -z "${RUNNER_ORG_TOKEN}" || -z "${RUNNER_INSTANCE_COUNT}" ]]; then
    echo "Error: RUNNER_ORG_REPO, RUNNER_ORG_TOKEN, and RUNNER_INSTANCE_COUNT must be set."
    exit 1
fi

echo "Runner Repo: ${RUNNER_ORG_REPO}"
echo "Runner Count: ${RUNNER_INSTANCE_COUNT}"
echo "Runner Token: ${RUNNER_ORG_TOKEN}"

#RUNNER_SUFFIX=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 5 | head -n 1)
#RUNNER_NAME="AI-AGENT-RUNNER-${RUNNER_SUFFIX}"
export LC_CTYPE=C 
export LANG=C
for ((i=1; i<=${RUNNER_INSTANCE_COUNT}; i++)); do
    RUNNER_SUFFIX=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 5 | head -n 1)
    RUNNER_NAME="AI-AGENT-RUNNER-${i}-${RUNNER_SUFFIX}"
    echo "Starting runner instance: ${RUNNER_NAME} "
    ./config.sh --unattended --url $RUNNER_ORG_REPO --token ${RUNNER_ORG_TOKEN} --name ${RUNNER_NAME}

    trap 'cleanup; exit 130' INT
    trap 'cleanup; exit 143' TERM

    ./run.sh &
done



cd ..

wait