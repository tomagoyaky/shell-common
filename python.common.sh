#!/bin/bash
# desc: 
# Author: tomagoyaky@gmail.com
venv_setup() {
    dir_venv=$1
    log_info "Setting up Python virtual environment at $dir_venv ..."
    if [ ! -d "$dir_venv" ]; then
        python3 -m venv "$dir_venv"
        log_info "Virtual environment created at $dir_venv."
    else
        log_info "Virtual environment already exists at $dir_venv."
    fi
}
activate_venv() {
    dir_venv=$1
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
