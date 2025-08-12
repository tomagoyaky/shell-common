#!/bin/bash
clear
usage() {
    echo "Usage: $0 YOUR_PROJECT_NAME"
}

# Function to import dependencies based on input flags
PROJECT_NAME=$1
IMAGE_NAME=$2
PYTHON_SUPPORT=false
DOCKER_SUPPORT=false
VISUALBOX_SUPPORT=false
CONTAINER_NAME=
HOST_WORKSPACE=
CONTAINER_PARENT=
CONTAINER_WORKSPACE=
DEFAULT_IMAGE_NAME="ubuntu:24.04"
DIR_ROOT="$(cd $(dirname $0); pwd)"
if [[ "$(uname -s)" == CYGWIN* || "$(uname -s)" == MINGW* ]]; then
    DIR_ROOT=$(cygpath -m "$DIR_ROOT")
    echo "Converted DIR_ROOT to Unix path: $DIR_ROOT"
fi

check_params() {
    if [ -z "$PROJECT_NAME" ]; then
        read -p "[+] Please enter the project name: " PROJECT_NAME
    fi
    if [ -z "$PROJECT_NAME" ]; then
        echo "Project name cannot be empty."
        usage
        exit 1
    fi
    read -p "[+] Please enter the Docker image name (default: $DEFAULT_IMAGE_NAME): " _IMAGE_NAME
    if [[ "$_IMAGE_NAME" == "y" || "$_IMAGE_NAME" == "Y" || "$_IMAGE_NAME" == "" ]]; then
        IMAGE_NAME=$DEFAULT_IMAGE_NAME
    fi
    read -p "[+] Do you want to enable Python support? (Y/n): " _PYTHON_SUPPORT
    if [[ "$_PYTHON_SUPPORT" == "y" || "$_PYTHON_SUPPORT" == "Y" || "$_PYTHON_SUPPORT" == "" ]]; then
        PYTHON_SUPPORT=true
    fi
    read -p "[+] Do you want to enable Docker support? (Y/n): " _DOCKER_SUPPORT
    if [[ "$_DOCKER_SUPPORT" == "y" || "$_DOCKER_SUPPORT" == "Y" || "$_DOCKER_SUPPORT" == "" ]]; then
        DOCKER_SUPPORT=true
    fi
    read -p "[+] Do you want to download VisualBox? (Y/n): " _VISUALBOX_SUPPORT
    if [[ "$_VISUALBOX_SUPPORT" == "y" || "$_VISUALBOX_SUPPORT" == "Y" || "$_VISUALBOX_SUPPORT" == "" ]]; then
        VISUALBOX_SUPPORT=true
    fi
}
export_directories() {
    export DIR_ROOT="$DIR_ROOT"
    export DIR_PROJECTS="$DIR_ROOT/projects"
    export DIR_PROJECT="$DIR_PROJECTS/$PROJECT_NAME"
    export DIR_WORKSPACE="$DIR_ROOT/workspace"
    export DIR_STATUS="$DIR_WORKSPACE/status"
    export DIR_LOG="$DIR_WORKSPACE/logs"
    export DIR_DATA="$DIR_WORKSPACE/data"
    export DIR_SOURCES="$DIR_WORKSPACE/sources"
    export DIR_UPLOAD="$DIR_WORKSPACE/input"
    export DIR_OUTPUT="$DIR_WORKSPACE/output"
    export DIR_TARS="$DIR_WORKSPACE/tars"
    export DIR_TEMP="$DIR_WORKSPACE/tmp"
}
setup_docker_vars(){
    CONTAINER_NAME="${PROJECT_NAME}-${IMAGE_NAME}"
    CONTAINER_NAME=$(echo "$CONTAINER_NAME" | sed 's/:/_/g')
    HOST_WORKSPACE="$DIR_WORKSPACE"
    CONTAINER_PARENT="/local/data"
    CONTAINER_WORKSPACE="$CONTAINER_PARENT/workspace"
}
source_files() {
    source "${DIR_ROOT}/common.sh"
    source "${DIR_ROOT}/docker.common.sh"
    source "${DIR_ROOT}/python.common.sh"
    source "${DIR_ROOT}/visualbox.common.sh"
}

print_info(){
    log_info "#################################################"
    log_info " Project info ..."
    log_info "* Using project name: $PROJECT_NAME"
    log_info "* Using Docker image: $IMAGE_NAME"
    log_info "* Using container name: $CONTAINER_NAME"
    log_info "* Host workspace: $HOST_WORKSPACE"
    log_info "* Container workspace: $CONTAINER_WORKSPACE"

    log_info "* Python support: $PYTHON_SUPPORT"
    log_info "* Docker support: $DOCKER_SUPPORT"
    log_info "* VisualBox support: $VISUALBOX_SUPPORT"

    log_info "Directories:"
    log_info "* Using project name: $PROJECT_NAME"
    log_info "  - Root: $DIR_ROOT"
    log_info "  - Project: $DIR_PROJECTS"
    log_info "  - Workspace: $DIR_WORKSPACE"
    log_info "  - Status: $DIR_STATUS"
    log_info "  - Logs: $DIR_LOG"
    log_info "  - Data: $DIR_DATA"
    log_info "  - Sources: $DIR_SOURCES"
    log_info "  - Upload: $DIR_UPLOAD"
    log_info "  - Output: $DIR_OUTPUT"
    log_info "  - Tars: $DIR_TARS"
    log_info "  - Temp: $DIR_TEMP"
    log_info "#################################################"
}

create_directories() {
    if [ ! -f "$DIR_STATUS/filesystem.ok.status" ]; then
        log_info "Creating necessary directories..."
        mkdir_if_not_exists "$DIR_PROJECTS"
        mkdir_if_not_exists "$DIR_PROJECT"
        mkdir_if_not_exists "$DIR_WORKSPACE"
        mkdir_if_not_exists "$DIR_STATUS"
        mkdir_if_not_exists "$DIR_LOG"
        mkdir_if_not_exists "$DIR_DATA"
        mkdir_if_not_exists "$DIR_SOURCES"
        mkdir_if_not_exists "$DIR_UPLOAD"
        mkdir_if_not_exists "$DIR_OUTPUT"
        mkdir_if_not_exists "$DIR_TARS"
        mkdir_if_not_exists "$DIR_TEMP"
        touch "$DIR_STATUS/filesystem.ok.status"
        log_info "All necessary directories created successfully."
    else
        log_warning "Directories already created. Skipping creation."
    fi
}

project_setup(){
    # if [ ! -f $HOST_WORKSPACE/container.sh ]; then
        log_info "Creating container.sh from template..."
        cp -r "$DIR_ROOT/container.template" "$HOST_WORKSPACE/" && \
        mv "$HOST_WORKSPACE/container.template" "$HOST_WORKSPACE/container.sh"
    # else
        # log_warning "container.sh already exists. Skipping creation."
    # fi

    if [ "$DOCKER_SUPPORT" == "true" ]; then
        log_info "Docker support enabled."
        #*********************** source file *************************
        
        # Function to check if Docker is running
        docker_is_running

        # Function to pull a Docker image
        docker_pull "$IMAGE_NAME"

        # Function to run a Docker container
        docker_run "$IMAGE_NAME" "$CONTAINER_NAME" "$HOST_WORKSPACE" "$CONTAINER_WORKSPACE"

        # Function to copy files to the Docker container
        docker_shell_cmd "$CONTAINER_NAME" "mkdir -p $CONTAINER_WORKSPACE"
        docker_shell_cmd "$CONTAINER_NAME" "chmod -R a+rw $CONTAINER_WORKSPACE"
        docker_copy "$DIR_WORKSPACE" "$CONTAINER_PARENT" "$CONTAINER_NAME"
        docker_shell_cmd "$CONTAINER_NAME" "cd $CONTAINER_WORKSPACE && pwd && ls -lah && ./container.sh"
    fi

    if [ "$PYTHON_SUPPORT" == "true" ]; then
        log_info "Python support enabled."
        
        # Function to set up Python virtual environment
        if [ ! -f "$DIR_STATUS/venv.ok.status" ]; then
            venv_setup "$DIR_WORKSPACE/venv"
            touch "$DIR_STATUS/venv.ok.status"
            log_info "Virtual environment setup complete."
        else
            log_info "Virtual environment already set up."
        fi
    fi

    if [ "$VISUALBOX_SUPPORT" == "true" ]; then
        log_info "VisualBox support enabled."
        download_visualbox "$DIR_TARS"
        # Download Ubuntu 24.04 image if not already downloaded
        download_ubuntu_image "$DIR_TARS"
        # Load local Ubuntu image into VisualBox
        visualbox_load_local_ubuntu "$DIR_TARS/ubuntu-24.04.3-desktop-amd64.iso"
    fi
}

check_params
export_directories
setup_docker_vars
source_files
create_directories
print_info
project_setup

if [ "$DOCKER_SUPPORT" == "true" ]; then
    docker_shell "$CONTAINER_NAME"
fi