#!/bin/bash
clear
# CURRENT="$(cd $(dirname $0); pwd)"
CURRENT="D:\llm-docker\workspace\mem0"
FATHER="$(dirname "${CURRENT}")"
GRANDFATHER="$(dirname "${FATHER}")"
shell_name="mem0"
ubuntu_image_name="ubuntu:24.04"
ubuntu_container_name="mem0-ubuntu-24.04"
# ubuntu_host_workspace="$CURRENT/workspace/$shell_name"
ubuntu_host_workspace="D:\llm-docker\workspace\\$shell_name"
ubuntu_container_workspace="/local/data/workspace"
#################################################
source "${GRANDFATHER}/common.sh" $shell_name
source "${GRANDFATHER}/docker.common.sh" $ubuntu_image_name $ubuntu_container_name $ubuntu_host_workspace $ubuntu_container_workspace
source "${GRANDFATHER}/python.common.sh"
#################################################


# Function to pull a Docker image
if [ ! -f $DIR_STATUS/docker.mem0.pull.status ]; then
    docker_pull "$ubuntu_image_name"
    echo "" > $DIR_STATUS/docker.mem0.pull.status
else
    log_info "Docker image '$ubuntu_image_name' already pulled."
fi

# Function to run a Docker container
if [ ! -f $DIR_STATUS/docker.mem0.run.status ]; then
    docker_run "$ubuntu_image_name" "$ubuntu_container_name"
    echo "" > $DIR_STATUS/docker.mem0.run.status
else
    log_info "Docker container '$ubuntu_container_name' already running."
fi

# docker_copy $CURRENT/container.sh $ubuntu_container_workspace/container.sh $ubuntu_container_name
docker_copy 'D:\llm-docker\projects\mem0\container.sh' $ubuntu_container_workspace/container.sh $ubuntu_container_name
# docker_shell $ubuntu_container_name
docker_shell_cmd "$ubuntu_container_name" "mkdir -p $ubuntu_container_workspace"
docker_shell_cmd "$ubuntu_container_name" "pwd && cd $ubuntu_container_workspace && ./container.sh"
