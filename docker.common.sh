#!/bin/bash
# desc: This script manages Docker images and containers.
# It provides functions to list, remove, pull images, run containers, and check their states.
# It also includes logging functions for better traceability.
# Usage: ./start.mem0.sh <docker_image> <docker_container>
# Author: tomagoyaky@gmail.com
#################################################
export docker_image=$1
export docker_container=$2
export docker_host_workspace=$3
export docker_container_workspace=$4

print_parameters() {
    log_info "Docker Image: $docker_image"
    log_info "Docker Container: $docker_container"
    log_info "Docker Host Workspace: $docker_host_workspace"
    log_info "Docker Container Workspace: $docker_container_workspace"
}
usage() {
    log_error "Usage: $0 <docker_image> <docker_container>"
    exit 1
}
docker_list_images(){
    log_info "Listing all Docker images..."
    docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.ID}}\t{{.CreatedAt}}"
}
docker_list_containers() {
    log_info "Listing all Docker containers..."
    docker ps -a --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.CreatedAt}}"
}
docker_remove_image() {
    _image_name=$1

    if [ -z "$_image_name" ]; then
        log_error "Image name must be provided."
        usage
    fi

    log_info "Removing Docker image '$_image_name'..."
    if docker rmi "$_image_name"; then
        log_info "Successfully removed Docker image '$_image_name'."
    else
        log_error "Failed to remove Docker image '$_image_name'."
        exit 1
    fi
}
docker_remove_container() {
    _container_name=$1

    if [ -z "$_container_name" ]; then
        log_error "Container name must be provided."
        usage
    fi

    log_info "Removing Docker container '$_container_name'..."
    if docker rm "$_container_name"; then
        log_info "Successfully removed Docker container '$_container_name'."
    else
        log_error "Failed to remove Docker container '$_container_name'."
        exit 1
    fi
}
docker_get_state() {
    _image_name=$1
    _container_name=$2

    if [ -z "$_image_name" ] || [ -z "$_container_name" ]; then
        log_error "Image name and container name must be provided."
        usage
    fi

    # Check if the image exists
    if ! docker image inspect "$_image_name" >/dev/null 2>&1; then
        log_error "Docker image '$_image_name' does not exist."
        return -1
    fi
    # Check if the container exists
    if ! docker ps -a --format '{{.Names}}' | grep -q "^$_container_name$"; then
        log_error "Docker container '$_container_name' does not exist."
        return -2
    fi
}
docker_pull() {
    _image_name=$1

    if [ -z "$_image_name" ]; then
        log_error "Image name must be provided."
        usage
    fi

    log_info "Pulling Docker image '$_image_name'..."
    if docker pull "$_image_name"; then
        log_info "Successfully pulled Docker image '$_image_name'."
    else
        log_error "Failed to pull Docker image '$_image_name'."
        exit 1
    fi
}
docker_run() {
    _image_name=$1
    _container_name=$2

    print_parameters

    if [ -z "$_image_name" ] || [ -z "$_container_name" ]; then
        log_error "Image name and container name must be provided."
        usage
    fi

    log_info "Running Docker container '$_container_name' from image '$_image_name'..."
set -x
    docker run --name "$_container_name" \
        -v "$docker_host_workspace:$docker_container_workspace" \
        "$_image_name" \
        /bin/bash -c "while true; do sleep 30; done" &
set +x
    if [ $? -eq 0 ]; then
        log_info "Successfully started Docker container '$_container_name'."
    else
        log_error "Failed to start Docker container '$_container_name'."
        exit 1
    fi
}
docker_copy() {
    _source_path=$1
    _destination_path=$2
    _container_name=$3

    if [ -z "$_source_path" ] || [ -z "$_destination_path" ] || [ -z "$_container_name" ]; then
        log_error "Source path, destination path, and container name must be provided."
        usage
    fi

    log_info "Copying files from '$_source_path' to '$_container_name:$_destination_path'..."
set -x
    docker cp "$_source_path" "$_container_name:$_destination_path"
set +x
    if [ $? -eq 0 ]; then
        log_info "Successfully copied files to Docker container '$_container_name'."
    else
        log_error "Failed to copy '$_source_path' to '$_destination_path' on Docker container '$_container_name'."
        exit 1
    fi
}
docker_shell() {
    _container_name=$1

    if [ -z "$_container_name" ]; then
        log_error "Container name must be provided."
        usage
    fi

    log_info "Opening bash shell in Docker container '$_container_name'..."
    if docker exec -it "$_container_name" bash; then
        log_info "Bash shell opened successfully in Docker container '$_container_name'."
    else
        log_error "Failed to open bash shell in Docker container '$_container_name'."
        exit 1
    fi
}
docker_shell_cmd() {
    _container_name=$1
    _command=$2

    if [ -z "$_container_name" ] || [ -z "$_command" ]; then
        log_error "Container name and command must be provided."
        usage
    fi

    log_info "Executing command: '$_command'"
    docker exec "$_container_name" bash -c "$_command"
    if [ $? -ne 0 ]; then
        log_error "Failed to execute command '$_command' in Docker container '$_container_name'."
        exit 1
    fi
}
docker_is_installed() {
    if command -v docker >/dev/null 2>&1; then
        log_info "Docker is installed."
    else
        log_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
}
docker_is_running() {
    log_info "Checking if Docker is running..."
    if [ $OSTYPE == "linux-gnu" ]; then
        if systemctl is-active --quiet docker; then
            log_info "Docker is running."
        else
            log_error "Docker is not running. Please start Docker first."
            exit 1
        fi
    elif [ $OSTYPE == "darwin"* ]; then
        if pgrep -x "Docker" >/dev/null; then
            log_info "Docker is running."
        else
            log_error "Docker is not running. Please start Docker first."
            exit 1
        fi
    elif [[ "$OSTYPE" == cygwin* ]] || [[ "$OSTYPE" == msys* ]] || [[ "$OSTYPE" == win32* ]]; then
        if docker info >/dev/null 2>&1; then
            log_info "Docker is running."
        else
            log_error "Docker is not running. Please start Docker Desktop first."
            exit 1
        fi
    else
        log_error "Unsupported OS type: $OSTYPE"
        exit 1
    fi
}
docker_is_running