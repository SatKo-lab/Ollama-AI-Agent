#!/bin/bash


DOCKER_IMAGE="codiumai/pr-agent:latest"
PR_URL="https://github.com/icomdev/ARC/pull/404"
PR_URL="https://github.com/SatKo-lab/Test_PR_Agent/pull/1"


promt0="ask the author to add a test for this PR"
promt1="and write me a poem about this PR"

# Check if Docker is installed and use it if available, otherwise fallback to CLI
if [[ "$1" == "docker" ]]; then
    echo "Docker is available or explicitly requested. Running with Docker..."
    docker run --rm -it \
        --network host \
        --env-file ./codium/.env \
        $DOCKER_IMAGE --pr_url $PR_URL $promt0 $promt1
else
    echo "Docker is not available. Running with CLI..."

    cd codium && source .venv/bin/activate && \
        python3 -m pr_agent.cli \
        --pr_url $PR_URL $promt0 "$promt1"
fi