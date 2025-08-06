#!/bin/bash
# desc: This script manages Docker images and containers.
# It provides functions to list, remove, pull images, run containers, and check their states
# Author: tomagoayky@gmail.com
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
    if [ command -v "$1" >/dev/null 2>&1 ]; then
        log_info "Command '$1' exists."
    else
        log_error "Command '$1' does not exist."
        exit 1
    fi
}