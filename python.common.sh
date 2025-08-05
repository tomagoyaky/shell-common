#!/bin/bash
# desc: 
# Author: tomagoyaky@gmail.com
CURRENT="$(cd $(dirname $0); pwd)"
#################################################
export DIR_VENV="$DIR_WORKSPACE/.venv"
#################################################

venv_setup() {
    log_info "Setting up Python virtual environment..."
    if [ ! -d "$DIR_VENV" ]; then
        python3 -m venv "$DIR_VENV"
        log_info "Virtual environment created at $DIR_VENV."
    else
        log_info "Virtual environment already exists at $DIR_VENV."
    fi
}
activate_venv() {
    if [ -d "$DIR_VENV" ]; then
        # For Unix/Linux compatibility
        if [ -f $DIR_VENV/bin/activate ];then
            log_info "Activating virtual environment for Unix/Linux..."
            source "$DIR_VENV/bin/activate"
            log_info "Activated virtual environment at $DIR_VENV."
        elif [ -f "$DIR_VENV/Scripts/activate" ]; then
            log_info "Activating virtual environment for Windows..."
            source "$DIR_VENV/Scripts/activate"
            log_info "Activated virtual environment at $DIR_VENV."
        else
            log_error "Python executable not found in virtual environment."
            exit 1
        fi
    else
        log_error "Virtual environment not found at $DIR_VENV.   Please run venv_setup first."
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