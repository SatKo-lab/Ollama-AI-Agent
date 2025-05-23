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
if [[ "$action" != "build" && "$action" != "run" && "$action" != "both" ]]; then
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
esac