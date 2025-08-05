#!/bin/bash
# desc: This script manages Docker images and containers.
# It provides functions to list, remove, pull images, run containers, and check their states
# Author: tomagoayky@gmail.com
shell_name=$1
CURRENT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIR_WORKSPACE="$CURRENT/workspace"
DIR_STATUS="$DIR_WORKSPACE/$shell_name/status"
DIR_LOG="$DIR_WORKSPACE/$shell_name/logs"
DIR_DATA="$DIR_WORKSPACE/$shell_name/data"
DIR_SOURCES="$DIR_WORKSPACE/$shell_name/sources"
DIR_UPLOAD="$DIR_WORKSPACE/$shell_name/input"
DIR_OUTPUT="$DIR_WORKSPACE/$shell_name/output"
DIR_TARS="$DIR_WORKSPACE/$shell_name/tars"
DIR_TEMP="$DIR_WORKSPACE/$shell_name/tmp"

log_info() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] INFO: $1"
}

log_warning() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1"
}
log_error() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1"
}
log_debug() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] DEBUG: $1"
}
exist() {
    command -v "$1" >/dev/null 2>&1
}
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

step0() {
    log_info "Step 0: Initializing workspace directories..."
    if [ ! -f $DIR_STATUS/filesystem.ok.status ]; then
        log_info "Setting up filesystem..."
        setup_filesystem
        touch $DIR_STATUS/filesystem.ok.status
        log_info "Filesystem setup complete."
    else
        log_info "Filesystem already set up."
    fi
}

#################################################
# default call step0 to initialize the filesystem
#################################################
step0