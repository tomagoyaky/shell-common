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
CONTAINER_NAME=
HOST_WORKSPACE=
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
    read -p "[+] Please enter the Docker image name (default: $DEFAULT_IMAGE_NAME): " IMAGE_NAME
    if [[ "$IMAGE_NAME" == "y" || "$IMAGE_NAME" == "Y" || "$IMAGE_NAME" == "" ]]; then
        IMAGE_NAME=$DEFAULT_IMAGE_NAME
    fi
    read -p "[+] Do you want to enable Python support? (Y/n): " PYTHON_SUPPORT
    if [[ "$PYTHON_SUPPORT" == "y" || "$PYTHON_SUPPORT" == "Y" || "$PYTHON_SUPPORT" == "" ]]; then
        PYTHON_SUPPORT=true
    fi
    read -p "[+] Do you want to enable Docker support? (Y/n): " DOCKER_SUPPORT
    if [[ "$DOCKER_SUPPORT" == "y" || "$DOCKER_SUPPORT" == "Y" || "$DOCKER_SUPPORT" == "" ]]; then
        DOCKER_SUPPORT=true
    fi
}
export_directories() {
    export DIR_ROOT="$DIR_ROOT"
    export DIR_PROJECTS="$DIR_ROOT/projects"
    export DIR_PROJECT="$DIR_PROJECTS/$PROJECT_NAME"
    export DIR_WORKSPACE="$DIR_ROOT/workspace"
    export DIR_STATUS="$DIR_PROJECT/status"
    export DIR_LOG="$DIR_PROJECT/logs"
    export DIR_DATA="$DIR_PROJECT/data"
    export DIR_SOURCES="$DIR_PROJECT/sources"
    export DIR_UPLOAD="$DIR_PROJECT/input"
    export DIR_OUTPUT="$DIR_PROJECT/output"
    export DIR_TARS="$DIR_PROJECT/tars"
    export DIR_TEMP="$DIR_PROJECT/tmp"
}
setup_docker_vars(){
    CONTAINER_NAME="${PROJECT_NAME}-${IMAGE_NAME}"
    CONTAINER_NAME=$(echo "$CONTAINER_NAME" | sed 's/:/_/g')
    HOST_WORKSPACE="$DIR_PROJECT"
    CONTAINER_WORKSPACE="/local/data/workspace/$PROJECT_NAME"
}
source_files() {
    source "${DIR_ROOT}/common.sh"
    source "${DIR_ROOT}/docker.common.sh"
    source "${DIR_ROOT}/python.common.sh"
}

print_info(){
    log_info "#################################################"
    log_info " Project info ..."
    log_info "* Using project name: $PROJECT_NAME"
    log_info "* Using Docker image: $IMAGE_NAME"
    log_info "* Using container name: $CONTAINER_NAME"
    log_info "* Host workspace: $HOST_WORKSPACE"
    log_info "* Container workspace: $CONTAINER_WORKSPACE"
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
    cp -r "$DIR_ROOT/container.template" "$DIR_PROJECT/" && \
    mv "$DIR_PROJECT/container.template" "$DIR_PROJECT/container.sh" && \
    chmod +x "$DIR_PROJECT/container.sh"
    
    if $docker_support; then
        log_info "Docker support enabled."
        #*********************** source file *************************
        
        # Function to check if Docker is running
        docker_is_running

        # Function to pull a Docker image
        docker_pull "$IMAGE_NAME"

        # Function to run a Docker container
        docker_run "$IMAGE_NAME" "$CONTAINER_NAME"
        source_file=$DIR_ROOT/container.sh
        echo "source_file1=$source_file"
        # source_file将/替换为\
        source_file=$(echo "$source_file" | sed 's/\//\\\\/g')
        echo "source_file2=$source_file"
        docker_copy $source_file $CONTAINER_WORKSPACE/container.sh $CONTAINER_NAME
        docker_shell_cmd "$CONTAINER_NAME" "mkdir -p $CONTAINER_WORKSPACE"
        docker_shell_cmd "$CONTAINER_NAME" "cd $CONTAINER_WORKSPACE && pwd && ls -lah && ./container.sh"
    fi

    if $python_support; then
        log_info "Python support enabled."
        
        # Function to set up Python virtual environment
        if [ ! -f "$DIR_STATUS/venv.ok.status" ]; then
            venv_setup
            touch "$DIR_STATUS/venv.ok.status"
            log_info "Virtual environment setup complete."
        else
            log_info "Virtual environment already set up."
        fi
    fi
}

check_params
export_directories
setup_docker_vars
source_files
create_directories
print_info
project_setup