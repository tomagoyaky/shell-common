#!/bin/bash
# desc: 
# Author: tomagoyaky@gmail.com
CURRENT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
#################################################
DIR_VENV="$DIR_WORKSPACE/.venv"
#################################################

venv_setup() {
    log_info "Setting up Python virtual environment..."
    if [ ! -d "$DIR_VENV" ]; then
    set -x
        python3 -m venv "$DIR_VENV"
    set +x
        log_info "Virtual environment created at $DIR_VENV."
    else
        log_info "Virtual environment already exists at $DIR_VENV."
    fi

    source "$DIR_VENV/bin/activate"
    log_info "Activated virtual environment."
}
activate_venv() {
    if [ -d "$DIR_VENV" ]; then
        source "$DIR_VENV/bin/activate"
        log_info "Activated virtual environment at $DIR_VENV."
    else
        log_error "Virtual environment not found at $DIR_VENV. Please run venv_setup first."
        exit 1
    fi
}

#################################################
# Check if virtual environment is set up and activate it
#################################################
if [ ! -f "$DIR_STATUS/venv.ok.status" ]; then
    venv_setup
    touch "$DIR_STATUS/venv.ok.status"
    log_info "Virtual environment setup complete."
else
    log_info "Virtual environment already set up."
fi
activate_venv