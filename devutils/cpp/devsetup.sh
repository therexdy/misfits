#!/bin/bash

set -e

echo "Requesting sudo access..."
sudo -v

while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

echo "Setting up Neovim..."
curl -fsSL https://raw.githubusercontent.com/therexdy/linuxscripts/refs/heads/main/utils/quick_personalize.sh | bash

detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    else
        echo "unknown"
    fi
}

install_snap_if_needed() {
    if ! command -v snap &> /dev/null; then
        sudo apt update
        sudo apt install -y snapd
        sudo systemctl enable --now snapd.socket
        if [ ! -L /snap ]; then
            sudo ln -s /var/lib/snapd/snap /snap
        fi
        export PATH="/snap/bin:$PATH"
    fi
}

DISTRO=$(detect_distro)

case "$DISTRO" in
    ubuntu)
        sudo apt update
        sudo apt install -y build-essential gcc g++ clang valgrind cmake make gdb lldb
        ;;
    debian)
        install_snap_if_needed
        sudo apt update
        sudo apt install -y build-essential gcc g++ clang valgrind cmake make gdb lldb
        ;;
    arch|manjaro)
        sudo pacman -Syu --noconfirm
        sudo pacman -S --noconfirm base-devel gcc clang valgrind cmake make gdb lldb
        ;;
    fedora|rhel|centos|rocky|almalinux)
        sudo dnf update -y
        sudo dnf groupinstall -y "Development Tools"
        sudo dnf install -y gcc-c++ clang valgrind cmake make gdb lldb
        ;;
    *)
        echo "Unsupported distribution: $DISTRO"
        exit 1
        ;;
esac

echo "C++ development tools installation complete!"

