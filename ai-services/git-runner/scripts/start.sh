#!/bin/bash

RUNNER_SUFFIX=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 5 | head -n 1)
RUNNER_NAME="AI-AGENT-RUNNER-${RUNNER_SUFFIX}"

export HOME=$DIND_USER_HOME
mkdir -p $DIND_USER_HOME/_work/_temp/_github_workflow
cd $DIND_USER_HOME #/home/docker/actions-runner


echo "Runner Name: ${RUNNER_NAME}"
echo "Runner Repo: ${RUNNER_ORG_REPO}"

./config.sh --unattended --url $RUNNER_ORG_REPO --token ${RUNNER_ORG_TOKEN} --name ${RUNNER_NAME}

cleanup() {
    echo "Removing runner..."
    docker volume remove runner-action-data
    docker volume remove workflow-data
    ./config.sh remove --unattended --token ${RUNNER_ORG_TOKEN}
}

docker volume create runner-action-data
docker volume create --opt type=none --opt device=$DIND_USER_HOME/_work/_temp/_github_workflow --opt o=bind workflow-data

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

./run.sh & wait $!