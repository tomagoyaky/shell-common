#!/bin/bash
clear

download_visualbox() {
    _dir_tar=$1
    vb_url_mac="https://download.virtualbox.org/virtualbox/7.1.12/VirtualBox-7.1.12-169651-OSX.dmg"
    vb_url_windows="https://download.virtualbox.org/virtualbox/7.1.12/VirtualBox-7.1.12-169651-Win.exe"

    # 如果是Windows则下载，如果是 macOS 或Linux则不下载
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
        echo "Downloading VisualBox: $vb_url_windows"
        if [ ! -f $_dir_tar/VirtualBox-7.1.12-169651-Win.exe ]; then
            curl $vb_url_windows -o $_dir_tar/VirtualBox-7.1.12-169651-Win.exe
        fi
    else
        echo "Downloading VisualBox: $vb_url_mac"
        if [ ! -f $_dir_tar/VirtualBox-7.1.12-169651-OSX.dmg ]; then
            curl $vb_url_mac -o $_dir_tar/VirtualBox-7.1.12-169651-OSX.dmg
        fi
    fi

    if [ ! -f $DIR_STATUS/visualbox.install.ok.status ]; then
        if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
            open $_dir_tar/VirtualBox-7.1.12-169651-Win.exe
        else
            open $_dir_tar/VirtualBox-7.1.12-169651-OSX.dmg
        fi
        touch $DIR_STATUS/visualbox.install.ok.status
        log_info "VisualBox download complete."
    else
        log_warning "VisualBox already downloaded. Skipping download."
    fi
}

download_ubuntu_image() {
    _dir_tar=$1
    ubuntu_url="https://mirrors.aliyun.com/ubuntu-releases/24.04/ubuntu-24.04.3-desktop-amd64.iso"

    if [ ! -f $_dir_tar/ubuntu-24.04.3-desktop-amd64.iso ]; then
        echo "Downloading Ubuntu 24.04 image: $ubuntu_url"
        curl $ubuntu_url -o $_dir_tar/ubuntu-24.04.3-desktop-amd64.iso
        log_info "Ubuntu 24.04 image download complete."
    else
        log_warning "Ubuntu 24.04 image already downloaded. Skipping download."
    fi
}

# 使用visualbox加载本地的ubuntu 24.04虚拟镜像
visualbox_load_local_ubuntu() {
    local_ubuntu_image=$1
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
        echo "Loading local Ubuntu 24.04 image in VisualBox..."
        # Windows specific commands to load the image
        # Example: VBoxManage import <path_to_ubuntu_image>
        vbboxmanage import "$local_ubuntu_image"
    else
        echo "Loading local Ubuntu 24.04 image in VisualBox..."
        # macOS/Linux specific commands to load the image
        # Example: VBoxManage import <path_to_ubuntu_image>
        vbboxmanage import "$local_ubuntu_image"
    fi
    log_info "Local Ubuntu 24.04 image loaded in VisualBox."
}