#!/bin/bash
clear
DIR_ROOT="$(cd $(dirname $0); pwd)"
# if DIR_ROOT contain '/cygdrive/d/' or '/cygdrive/c/' then replace it with 'D:/' or 'C:/'
DIR_ROOT=$(echo "$DIR_ROOT" | sed -e 's|/cygdrive/d/|D:/|' -e 's|/cygdrive/c/|C:/|')
export DIR_ROOT="$DIR_ROOT"

#################################################
if [ -z "$1" ]; then
    project_name="demo"
else
    project_name="$1"
fi

image_name="ubuntu:24.04"
container_name="${project_name}-${image_name}"
host_workspace="$DIR_ROOT/workspace/$project_name"
container_workspace="/local/data/workspace/$project_name"

#################################################
export DIR_PROJECT="$DIR_ROOT/projects"
export DIR_WORKSPACE="$DIR_ROOT/workspace"
export DIR_STATUS="$DIR_WORKSPACE/$project_name/status"
export DIR_LOG="$DIR_WORKSPACE/$project_name/logs"
export DIR_DATA="$DIR_WORKSPACE/$project_name/data"
export DIR_SOURCES="$DIR_WORKSPACE/$project_name/sources"
export DIR_UPLOAD="$DIR_WORKSPACE/$project_name/input"
export DIR_OUTPUT="$DIR_WORKSPACE/$project_name/output"
export DIR_TARS="$DIR_WORKSPACE/$project_name/tars"
export DIR_TEMP="$DIR_WORKSPACE/$project_name/tmp"
mkdir_if_not_exists() {
    if [ ! -d "$1" ]; then
        mkdir -p "$1"
        log_info "Created directory: $1"
    else
        log_info "Directory already exists: $1"
    fi
}

setup_filesystem() {
    mkdir_if_not_exists "$DIR_STATUS"
    mkdir_if_not_exists "$DIR_LOG"
    mkdir_if_not_exists "$DIR_DATA"
    mkdir_if_not_exists "$DIR_SOURCES"
    mkdir_if_not_exists "$DIR_UPLOAD"
    mkdir_if_not_exists "$DIR_OUTPUT"
    mkdir_if_not_exists "$DIR_TARS"
    mkdir_if_not_exists "$DIR_TEMP"
}
usage() {
    echo "Usage: $0 your_project_name [--p] [--d]"
    echo "Options:"
    echo "  -p   Enable Python support"
    echo "  -d   Enable Docker support"
    echo "Example: $0 demo -p -d"
}
usage

# Function to import dependencies based on input flags
python_support=false
docker_support=false

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

setup_project() {
    _project_dir=$1
    _project_name=$2

    if [ -z "$_project_name" ] || [ -z "$_project_dir" ]; then
        log_error "Project name and directory cannot be empty."
        usage
        exit 1
    fi

    mkdir_if_not_exists $_project_dir
    log_info "Project directory created: $_project_dir"
    
    mkdir_if_not_exists $host_workspace
    log_info "Project workspace directory created: $host_workspace"
}

# Input
if [ -z "$project_name" ]; then
    read -p "Please enter project name: " project_name
    if [ -z "$project_name" ]; then
        log_error "Project name cannot be empty."
        usage
        exit 1
    fi
fi
#*********************** source file *************************
set -x
source "${DIR_ROOT}/common.sh" $project_name 
set +x
export DIR_PROJECT="$DIR_ROOT/projects/$project_name"

if $docker_support; then
    log_info "Docker support enabled."
    read -p "Please enter Docker image name (e.g., $image_name): " image_name
    if [ -z "$image_name" ]; then
        log_error "Docker image name cannot be empty."
        exit 1
    fi
    read -p "Please enter Docker container name (e.g., $container_name): " container_name
    if [ -z "$container_name" ]; then
        log_error "Docker container name cannot be empty."
        exit 1
    fi
    read -p "Please enter host workspace path (e.g., $host_workspace): " host_workspace
    if [ -z "$host_workspace" ]; then
        log_error "Host workspace path cannot be empty."
        exit 1
    fi
    read -p "Please enter container workspace path (e.g., $container_workspace): " container_workspace
    if [ -z "$container_workspace" ]; then
        log_error "Container workspace path cannot be empty."
        exit 1
    fi
    #*********************** source file *************************
    set -x
    source "${DIR_ROOT}/docker.common.sh" $image_name $container_name $host_workspace $container_workspace
    set +x
fi

if $python_support; then
    log_info "Python support enabled."
    #*********************** source file *************************
    set -x
    source "${DIR_ROOT}/python.common.sh" $DIR_WORKSPACE
    set +x
fi

log_info "-> project_name=$project_name"
if [ "$python_support" == "false" ];then
    log_info "-> python_support=$python_support (default)"
else
    log_info "-> python_support=$python_support"
fi

if [ "$docker_support" == "false" ];then
    log_info "-> docker_support=$docker_support (default)"
else
    log_info "-> docker_support=$docker_support"
    if [ "$image_name" == "ubuntu:24.04" ];then
        log_info "-> image_name=$image_name (default)"
    else
        log_info "-> image_name=$image_name"
    fi

    if [ "$container_name" == "${project_name}-ubuntu:24.04" ];then
        log_info "-> container_name=$container_name (default)"
    else
        log_info "-> container_name=$container_name"
    fi

    if [ "$host_workspace" == "$DIR_ROOT/workspace/${project_name}" ];then
        log_info "-> host_workspace=$host_workspace (default)"
    else
        log_info "-> host_workspace=$host_workspace"
    fi

    if [ "$container_workspace" == "/local/data/workspace/${project_name}" ];then
        log_info "-> container_workspace=$container_workspace (default)"
    else
        log_info "-> container_workspace=$container_workspace"
    fi
fi


# main
setup_filesystem
setup_project $DIR_PROJECT $project_name
if [ ! -f "$DIR_PROJECT/start.$project_name.sh" ]; then
    cp -r "$DIR_ROOT/start.template" "$DIR_PROJECT/"
    mv "$DIR_PROJECT/start.template" "$DIR_PROJECT/start.$project_name.sh"
    sed -i "s/template/$project_name/g" "$DIR_PROJECT/start.$project_name.sh"
    chmod +x "$DIR_PROJECT/start.$project_name.sh"
fi
if [ ! -f "$DIR_PROJECT/container.sh" ]; then
    cp -r "$DIR_ROOT/container.template" "$DIR_PROJECT/"
    mv "$DIR_PROJECT/container.template" "$DIR_PROJECT/container.sh"
fi
# if [ ! -f "$DIR_PROJECT/docker.common.sh" ]; then
#     cp -r "$DIR_ROOT/docker.common.template" "$DIR_PROJECT/"
#     mv "$DIR_PROJECT/docker.common.template" "$DIR_PROJECT/docker.common.sh"
# fi
# if [ ! -f "$DIR_PROJECT/python.common.sh" ]; then
#     cp -r "$DIR_ROOT/python.common.template" "$DIR_PROJECT/"
#     mv "$DIR_PROJECT/python.common.template" "$DIR_PROJECT/python.common.sh"
# fi
log_info "Project setup complete. You can now run the project using the start script: cd $DIR_PROJECT && ./start.$project_name.sh $DIR_ROOT $project_name -p -d"
cd $DIR_PROJECT && ./start.$project_name.sh $DIR_ROOT $project_name -p -d