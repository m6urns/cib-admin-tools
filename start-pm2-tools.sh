#!/bin/bash

# Services to start or update
declare -a services=(
    "Raikou:/opt/web/raikou:pm2 start npm --name=raikou -- run start"
    "KBLDB:/opt/internal/kbldb:pm2 start npm --name=kbldb -- run start"
    "Beautyfile:/opt/internal/beautyfile:pm2 start npm server.config.json"
    "PSC:/opt/internal/beautyfile:pm2 start npm psc.config.json"
    "Data:/opt/internal/bt-file-data:pm2 start data.config.json"
    "HuCoPIA Backend:/home/dock_user/web/hbe/:pm2 start npm --name=hbe -- run start"
    "HuCoPIA Frontend:/home/dock_user/web/hucopia/:pm2 start npm --name=hucopia -- run local"
    "HPInet Backend:/home/dock_user/web/hpinetdb/hpinetbackend/:pm2 start npm --name=hpinetbackend -- run start"
    "HPInet Frontend:/home/dock_user/web/hpinetdb/hpinetdb/:pm2 start npm --name=hpinetdb -- run local"
    "Tritikbdb Backend:/home/dock_user/web/kbunt/wheatbackend/:pm2 start npm --name=wheatbackend -- run start"
    "Tritikbdb Frontend:/home/dock_user/web/kbunt/tritikdb:pm2 start npm --name=tritikbdb -- run local"
    "RanchSATdb Backend:/home/dock_user/web/ranch/ranchbackend/:pm2 start npm --name=ranchbackend -- run start"
    "RanchSATdb Frontend:/home/dock_user/web/ranch/ranchsatdb:pm2 start npm --name=ranchsatdb -- run local"
    "Hucovaria:/opt/web/hucovaria:pm2 start npm --name=hucovaria -- run start"
    "pyseqrna-api:/opt/web/pyseqrna-api:pm2 start npm --name=pyseqrna-api -- run start"
    "MyDockDB Backend:/home/dock_user/web/RoxyFinalProject/backend:pm2 start npm --name=mydockbackend -- run start"
    "MyDockDB Frontend:/opt/web/RoxyFinalProject/Docking_project_frontend:pm2 start npm --name=mydockdb -- run start"
)

# Ensure script is run by dock_user (running as another user will end the current pm2 process)
if [[ "$(whoami)" != "dock_user" ]]; then
    echo "This script should only be run by the user 'dock_user'."
    exit 1
fi

# Function to display help
show_help() {
    echo "Usage: $0 [OPTION]"
    echo "Options:"
    echo "  --start     Start or update the services listed."
    echo "  --dry-run   Simulate the actions without making any changes."
    echo "  --help      Display this help and exit."
    echo "  --info      List all services that can be started or updated by this script along with their locations and startup options."
}

# Function to display services info
show_info() {
    echo "Services included in this script with their locations and startup options:"
    for service in "${services[@]}"; do
        IFS=":" read -r name location command <<< "$service"
        echo "Service Name: $name"
        echo "Location: $location"
        echo "Startup Command: $command"
        echo "-----------------------------------"
    done
}

# Function to start or update a service
start_service() {
    local service_name="$1"
    local location="$2"
    local command="$3"

    echo "Processing $service_name..."
    read -p "Do you want to start/update $service_name? (y/n): " start_answer
    if [[ "$start_answer" == "y" ]]; then
        cd "$location" || return
        if [[ "$dry_run" == "true" ]]; then
            echo "DRY RUN: $command in $location"
        else
            echo "Starting $service_name..."
            eval "$command"
        fi
    else
        echo "Skipping $service_name..."
    fi
    echo "-----------------------------------"
}

# Initialize flags
dry_run="false"
start_services="false"

# Parse command-line options
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --start)
            start_services="true"
            shift # Remove --start from processing
            ;;
        --dry-run)
            dry_run="true"
            shift # Remove --dry-run from processing
            ;;
        --help)
            show_help
            exit 0
            ;;
        --info)
            show_info
            exit 0
            ;;
        *)
            echo "Invalid option: $1"
            show_help
            exit 1
            ;;
    esac
done

if [[ "$dry_run" == "true" ]]; then
    echo "Running in dry-run mode. No changes will be made."
fi

# Start/update services if --start option is provided
if [[ "$start_services" == "true" ]]; then
    for service in "${services[@]}"; do
        IFS=":" read -r name location command <<< "$service"
        start_service "$name" "$location" "$command"
    done
else
    echo "Use --start option to start or update services."
    show_help
fi
