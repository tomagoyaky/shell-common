#!/bin/bash
dir_root=$1
dir_workspace=${dir_root}/workspace
dir_status=${dir_workspace}/status
project_name=$2
image_name="ubuntu:24.04"
container_name="$project_name-ubuntu-24.04"
host_workspace="$dir_workspace/$project_name"
container_workspace="/local/data/workspace"
#################################################
source "${dir_root}/common.sh" $project_name
#################################################
python_support=$2
docker_support=$3

if [ -z "$project_name" ]; then
    log_error "Project name is required."
    exit 1
fi
if [ -z "$python_support" ]; then
    python_support=false
fi
if [ -z "$docker_support" ]; then
    docker_support=false
fi

log_info "project_name=$project_name"
log_info "python_support=$python_support"
log_info "docker_support=$docker_support"
log_info "image_name=$image_name"
log_info "container_name=$container_name"
log_info "host_workspace=$host_workspace"
log_info "container_workspace=$container_workspace"

while [[ $# -gt 0 ]]; do
    case "$1" in
        -p)
            python_support=true
            shift
            ;;
        -d)
            docker_support=true
            shift
            ;;
        *)
            shift
            ;;
    esac
done

if $docker_support; then
    log_info "Docker support enabled."
    #*********************** source file *************************
    source "${dir_root}/docker.common.sh" $image_name $container_name $host_workspace $container_workspace

    # Function to pull a Docker image
    if [ ! -f $dir_status/docker.$project_name.pull.status ]; then
        docker_pull "$image_name"
        echo "" > $dir_status/docker.$project_name.pull.status
    else
        log_info "Docker image '$image_name' already pulled."
    fi
fi

if $python_support; then
    log_info "Python support enabled."
    #*********************** source file *************************
    source "${dir_root}/python.common.sh" "$dir_workspace"

    # Function to run a Docker container
    if [ ! -f $dir_status/docker.$project_name.run.status ]; then
        docker_run "$image_name" "$container_name"
        echo "" > $dir_status/docker.$project_name.run.status
    else
        log_info "Docker container '$container_name' already running."
    fi
fi

if $docker_support; then
    docker_copy $dir_root/container.sh $container_workspace/container.sh $container_name
    docker_shell_cmd "$container_name" "mkdir -p $container_workspace"
    docker_shell_cmd "$container_name" "pwd && cd $container_workspace && ./container.sh"
fi

#################################################