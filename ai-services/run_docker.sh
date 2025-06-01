#!/bin/bash

# Function to display help
show_help() {
    echo "Usage: $0 [build|run|both] [service_name...]"
    echo
    echo "This script builds and/or runs specified services from a docker-compose file."
    echo
    echo "Options:"
    echo "  --help    Show this help message and exit"
    echo
    echo "Examples:"
    echo "  $0 build service1 service2"
    echo "  $0 run service1"
    echo "  $0 both service1 service2"
    echo "  $0 --help"
}

# Check if --help is passed
if [[ "$1" == "--help" ]]; then
    show_help
    exit 0
fi

# Check if at least one argument is provided
if [[ $# -lt 2 ]]; then
    echo "Error: Insufficient arguments."
    echo "Use --help for usage information."
    exit 1
fi

# Extract the action and shift arguments
action=$1
shift

# Check if action is valid
if [[ "$action" != "build" && "$action" != "run" && "$action" != "both" && "$action" != "ai-git-runner" && "$action" != "local-host-runner" ]]; then
    echo "Error: Invalid action '$action'."
    echo "Use --help for usage information."
    exit 1
fi

# Perform the specified action
case $action in
    build)
        echo "Building services: $@"
        docker-compose build "$@"
        ;;
    run)
        echo "Running services: $@"
        docker-compose up "$@"
        ;;
    both)
        echo "Building and running services: $@"
        docker-compose up --build "$@"
        ;;
    ai-git-runner)
        echo "Launch Git Runner services: $@"
        scale_count=${2:-1}
        docker-compose up --build --scale ai-git-runner="$scale_count" -d

        #(cd git-runner && docker build -t ai-git-runner . && docker run -d --name ai-git-runner --privileged ai-git-runner -v /var/run/docker.sock:/var/run/docker.sock)
        # Enable systemd in the container by passing the --privileged flag and overriding the entrypoint
        #docker-compose up --build ai-git-runner
        #docker exec --privileged -it $(docker-compose ps -q ai-git-runner) /usr/sbin/init

        ;;
    local-host-runner)
        echo "Launch Git Runner services in local host : $@"
        scale_count=${2:-1}
        
        cd git-runner && \
        chmod +x ./local-host-runner.sh && \
        # Run the local-host-runner.sh script with the scale count
        # Load RUNNER_ORG_TOKEN from .env file if it exists

        # Export all variables from git-runner/.env if it exists
        if [ -f ./.env ]; then
            export $(grep -v '^#' ./.env | xargs)
        fi
        env $(grep -v '^#' ./.env | xargs) sh local-host-runner.sh
        ;;
esac