#!/bin/bash

RUNNER_SUFFIX=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 5 | head -n 1)
RUNNER_NAME="AI-AGENT-RUNNER-${RUNNER_SUFFIX}"

cd /home/docker/actions-runner

echo "Runner Name: ${RUNNER_NAME}"
echo "Runner Repo: ${RUNNER_ORG_REPO}"

./config.sh --unattended --url $RUNNER_ORG_REPO --token ${RUNNER_ORG_TOKEN} --name ${RUNNER_NAME}

cleanup() {
    echo "Removing runner..."
    ./config.sh remove --unattended --token ${RUNNER_ORG_TOKEN}
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

./run.sh & wait $!