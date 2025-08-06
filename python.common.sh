#!/bin/bash
# desc: 
# Author: tomagoyaky@gmail.com
dir_workspace=$1
dir_status="$dir_workspace/status"
#################################################
export dir_venv="$dir_workspace/.venv"
#################################################

venv_setup() {
    log_info "Setting up Python virtual environment..."
    if [ ! -d "$dir_venv" ]; then
        python3 -m venv "$dir_venv"
        log_info "Virtual environment created at $dir_venv."
    else
        log_info "Virtual environment already exists at $dir_venv."
    fi
}
activate_venv() {
    if [ -d "$dir_venv" ]; then
        # For Unix/Linux compatibility
        if [ -f $dir_venv/bin/activate ];then
            log_info "Activating virtual environment for Unix/Linux..."
            source "$dir_venv/bin/activate"
            log_info "Activated virtual environment at $dir_venv."
        elif [ -f "$dir_venv/Scripts/activate" ]; then
            log_info "Activating virtual environment for Windows..."
            source "$dir_venv/Scripts/activate"
            log_info "Activated virtual environment at $dir_venv."
        else
            log_error "Python executable not found in virtual environment."
            exit 1
        fi
    else
        log_error "Virtual environment not found at $dir_venv.   Please run venv_setup first."
        exit 1
    fi
}

#################################################
# Check if virtual environment is set up and activate it
#################################################
if [ ! -f "$dir_status/venv.ok.status" ]; then
    venv_setup
    touch "$dir_status/venv.ok.status"
    log_info "Virtual environment setup complete."
else
    log_info "Virtual environment already set up."
fi

activate_venv