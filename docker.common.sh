#!/bin/bash
# desc: This script manages Docker images and containers.
# It provides functions to list, remove, pull images, run containers, and check their states.
# It also includes logging functions for better traceability.
# Usage: ./start.mem0.sh <docker_image> <docker_container>
# Author: tomagoyaky@gmail.com
CURRENT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
#################################################
docker_image=$1
docker_container=$2

print_parameters() {
    log_info "Docker Image: $docker_image"
    log_info "Docker Container: $docker_container"
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

    if [ -z "$_image_name" ] || [ -z "$_container_name" ]; then
        log_error "Image name and container name must be provided."
        usage
    fi

    log_info "Running Docker container '$_container_name' from image '$_image_name'..."
    if docker run --name "$_container_name" "$_image_name"; then
        log_info "Successfully started Docker container '$_container_name'."
    else
        log_error "Failed to start Docker container '$_container_name'."
        exit 1
    fi
}
docker_bash() {
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