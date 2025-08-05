#!/bin/bash
clear
echo "Hello from the container!"

CURRENT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DIR_WORKSPACE="$CURRENT"
export DIR_STATUS="$DIR_WORKSPACE/$shell_name/status"
export DIR_LOG="$DIR_WORKSPACE/$shell_name/logs"
export DIR_DATA="$DIR_WORKSPACE/$shell_name/data"
export DIR_SOURCES="$DIR_WORKSPACE/$shell_name/sources"
export DIR_UPLOAD="$DIR_WORKSPACE/$shell_name/input"
export DIR_OUTPUT="$DIR_WORKSPACE/$shell_name/output"
export DIR_TARS="$DIR_WORKSPACE/$shell_name/tars"
export DIR_TEMP="$DIR_WORKSPACE/$shell_name/tmp"

FILE_APT_SOURCES="/etc/apt/sources.list.d/ubuntu.sources"

log_info() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')][Container] INFO: $1"
}

log_warning() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')][Container] WARNING: $1"
}
log_error() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')][Container] ERROR: $1"
}
log_debug() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')][Container] DEBUG: $1"
}
exist() {
    if [ command -v "$1" >/dev/null 2>&1 ]; then
        log_info "Command '$1' exists."
    else
        log_error "Command '$1' does not exist."
        exit 1
    fi
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
    if [ ! -f $DIR_STATUS/container.filesystem.ok.status ]; then
        log_info "Setting up filesystem..."
        setup_filesystem
        touch $DIR_STATUS/container.filesystem.ok.status
        log_info "Filesystem setup complete."
    else
        log_info "Filesystem already set up."
    fi
}

step1() {
    log_info "setup apt sources on tsinghua mirror..."
    # 从 Ubuntu 24.04 开始，Ubuntu 的软件源配置文件变更为 DEB822 格式，
    # 路径为 /etc/apt/sources.list.d/ubuntu.sources
    if [ ! -f $DIR_STATUS/container.apt.sources.ok.status ]; then
        sudo tee $FILE_APT_SOURCES > /dev/null <<EOF
Types: deb
URIs: https://mirrors.tuna.tsinghua.edu.cn/ubuntu
Suites: noble noble-updates noble-backports
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg

# 默认注释了源码镜像以提高 apt update 速度，如有需要可自行取消注释
# Types: deb-src
# URIs: https://mirrors.tuna.tsinghua.edu.cn/ubuntu
# Suites: noble noble-updates noble-backports
# Components: main restricted universe multiverse
# Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg

# 以下安全更新软件源包含了官方源与镜像站配置，如有需要可自行修改注释切换
Types: deb
URIs: http://security.ubuntu.com/ubuntu/
Suites: noble-security
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg

# Types: deb-src
# URIs: http://security.ubuntu.com/ubuntu/
# Suites: noble-security
# Components: main restricted universe multiverse
# Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg

# 预发布软件源，不建议启用

# Types: deb
# URIs: https://mirrors.tuna.tsinghua.edu.cn/ubuntu
# Suites: noble-proposed
# Components: main restricted universe multiverse
# Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg

# # Types: deb-src
# # URIs: https://mirrors.tuna.tsinghua.edu.cn/ubuntu
# # Suites: noble-proposed
# # Components: main restricted universe multiverse
# # Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
EOF
        if [ $? -ne 0 ]; then
            log_error "Failed to write APT sources to $FILE_APT_SOURCES."
            exit 1
        fi
        touch $DIR_STATUS/container.apt.sources.ok.status
        log_info "APT sources configured at $FILE_APT_SOURCES."
    else
        log_info "APT sources already configured."
    fi
}

step2() {
    log_info "apt update..."
    if [ ! -f $DIR_STATUS/container.apt.update.ok.status ]; then
        sudo apt-get update
        if [ $? -ne 0 ]; then
            log_error "Failed to update APT packages."
            exit 1
        fi
        touch $DIR_STATUS/container.apt.update.ok.status
        log_info "apt update complete."
    else
        log_info "apt already updated."
    fi
}

step3() {
    log_info "Installing apt dependencies..."
    if [ ! -f $DIR_STATUS/container.apt.install.ok.status ]; then
        sudo apt-get install -y \
            python3 \
            python3-venv \
            python3-pip \
            curl \
            git \
            docker.io \
            docker-compose \
            build-essential \
            libssl-dev \
            libffi-dev \
            python3-dev \
            python3-setuptools \
            python3-wheel \
            python3-virtualenv
        if [ $? -ne 0 ]; then
            log_error "Failed to install APT dependencies."
            exit 1
        fi
        touch $DIR_STATUS/container.apt.install.ok.status
        log_info "Apt dependencies installed."
    else
        log_info "Apt dependencies already installed."
    fi
}

step4() {
    if [ ! -f $DIR_STATUS/container.python.venv.ok.status ]; then
        log_info "Setting up Python virtual environment..."
        python3 -m venv $CURRENT/.venv
        if [ $? -ne 0 ]; then
            log_error "Failed to create Python virtual environment."
            exit 1
        fi
        touch $DIR_STATUS/container.python.venv.ok.status
        log_info "Python virtual environment created at $CURRENT/.venv."
    else
        log_info "Python virtual environment already set up."
    fi
}

step5() {
    log_info "Setting Python package source to Tsinghua University mirror..."
    if [ ! -f $DIR_STATUS/container.pip.source.setting.ok.status ]; then
        pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple/
        if [ $? -ne 0 ]; then
            log_error "Failed to set Python package source."
            exit 1
        fi
        pip config set install.trusted-host pypi.tuna.tsinghua.edu.cn
        if [ $? -ne 0 ]; then
            log_error "Failed to set trusted host for Python package source."
            exit 1
        fi
        touch $DIR_STATUS/container.pip.source.setting.ok.status
        log_info "Python package source set to Tsinghua University mirror."
    else
        log_info "Python package source already set."
    fi
}

step6() {
    log_info "Upgrade pip packages..."
    if [ ! -f $DIR_STATUS/container.python.packages.ok.status ]; then
        python -m pip install --upgrade pip
        if [ $? -ne 0 ]; then
            log_error "Failed to upgrade pip."
            exit 1
        fi
        touch $DIR_STATUS/container.python.packages.ok.status
        log_info " pip packages upgraded successfully."
    else
        log_info "pip packages upgrade already installed."
    fi
}

step7() {
    log_info "Installing Python packages from requirements.txt..."
    if [ ! -f $DIR_STATUS/container.python.requirements.ok.status ]; then
        if [ ! -f "$DIR_WORKSPACE/requirements.txt" ]; then
            log_warning "No requirements.txt found, skipping package installation."
        else
            pip install -r "$DIR_WORKSPACE/requirements.txt"
            if [ $? -ne 0 ]; then
                log_error "Failed to install Python packages from requirements.txt."
                exit 1
            fi
        fi
        touch $DIR_STATUS/container.python.requirements.ok.status
        log_info "Python packages installed from requirements.txt."
    else
        log_info "Python packages already installed from requirements.txt."
    fi
}

#################################################
# default call step0 to initialize the filesystem
#################################################
exist sudo
step0
step1
step2
step3
step4
step5
step6
step7