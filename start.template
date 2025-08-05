#!/bin/bash
clear
CURRENT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FATHER="$(dirname "${CURRENT}")"
GRANDFATHER="$(dirname "${FATHER}")"
shell_name="templeate"
ubuntu_image_name="ubuntu:24.04"
ubuntu_container_name="templeate-ubuntu-24.04"
ubuntu_host_workspace="$CURRENT/workspace/$shell_name"
ubuntu_container_workspace="/local/data/workspace"
#################################################
source "${GRANDFATHER}/common.sh" $shell_name
source "${GRANDFATHER}/docker.common.sh" $ubuntu_image_name $ubuntu_container_name $ubuntu_host_workspace $ubuntu_container_workspace
source "${GRANDFATHER}/python.common.sh"
#################################################

# Function to pull a Docker image
if [ ! -f $DIR_STATUS/docker.templeate.pull.status ]; then
    docker_pull "$ubuntu_image_name"
    echo "" > $DIR_STATUS/docker.templeate.pull.status
else
    log_info "Docker image '$ubuntu_image_name' already pulled."
fi

# Function to run a Docker container
if [ ! -f $DIR_STATUS/docker.templeate.run.status ]; then
    docker_run "$ubuntu_image_name" "$ubuntu_container_name"
    echo "" > $DIR_STATUS/docker.templeate.run.status
else
    log_info "Docker container '$ubuntu_container_name' already running."
fi

docker_copy $CURRENT/container.sh $ubuntu_container_workspace/container.sh $ubuntu_container_name
docker_shell_cmd "$ubuntu_container_name" "mkdir -p $ubuntu_container_workspace"
docker_shell_cmd "$ubuntu_container_name" "pwd && cd $ubuntu_container_workspace && ./container.sh"
