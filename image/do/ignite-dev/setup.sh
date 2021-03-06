#!/usr/bin/env bash

set -e

# Update the system.
apt-get update -y
apt-get upgrade -y

# - python3-setuptools and python-pip are required for deoplete.nvim to install
# pynvim.
# - silversearcher-ag is required to perform code-searching.
# - ripgrep is required for recursively searching directories for a regex
# pattern.
sudo apt-get install -y --no-install-recommends build-essential \
    python3-setuptools python3-pip silversearcher-ag zip unzip

# Install ripgrep.
curl -LO https://github.com/BurntSushi/ripgrep/releases/download/12.1.1/ripgrep_12.1.1_amd64.deb
sudo dpkg -i ripgrep_12.1.1_amd64.deb
rm ripgrep_12.1.1_amd64.deb

# Install neovim.
sudo curl -Lo /usr/local/bin/nvim https://github.com/neovim/neovim/releases/download/v0.4.4/nvim.appimage
sudo chmod +x /usr/local/bin/nvim
pip3 install pynvim

# Install gimme for golang.
sudo curl -sL -o /usr/local/bin/gimme https://raw.githubusercontent.com/travis-ci/gimme/master/gimme \
    && chmod +x /usr/local/bin/gimme

# Install kubectl with autocompletion.
curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
sudo sh -c 'kubectl completion bash > /etc/bash_completion.d/kubectl'

# Install kustomize.
curl -s "https://raw.githubusercontent.com/\
kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash
sudo mv kustomize /usr/local/bin/

# Install kind.
sudo curl -sL -o /usr/local/bin/kind https://github.com/kubernetes-sigs/kind/releases/download/v0.8.1/kind-linux-amd64 \
    && sudo chmod +x /usr/local/bin/kind
sudo sh -c 'kind completion bash > /etc/bash_completion.d/kind'

# Install k3d.
sudo curl -sL -o /usr/local/bin/k3d https://github.com/rancher/k3d/releases/download/v3.0.0/k3d-linux-amd64 \
    && sudo chmod +x /usr/local/bin/k3d
sudo sh -c 'k3d completion bash > /etc/bash_completion.d/k3d'

# Install all the dependencies for ignite. Install docker for container tooling.
# This installs containerd as well.
apt-get install -y --no-install-recommends dmsetup openssh-client git binutils \
    docker.io make

# Install CNI binaries.
export CNI_VERSION=v0.8.7
export ARCH=$([ $(uname -m) = "x86_64" ] && echo amd64 || echo arm64)
mkdir -p /opt/cni/bin
curl -sSL https://github.com/containernetworking/plugins/releases/download/${CNI_VERSION}/cni-plugins-linux-${ARCH}-${CNI_VERSION}.tgz | tar -xz -C /opt/cni/bin

# Set long ssh session timeouts.
sudo cat <<EOT >> /etc/ssh/sshd_config
ClientAliveInterval 120
ClientAliveCountMax 720
EOT

# Setup a sudo user.
USERNAME=demouser
# users file contains list of users to be created using newusers command.
USERS_FILE=/tmp/users
# bashrc path.
BASHRC_SRC=/tmp/bashrc
BASHRC="/home/$USERNAME/.bashrc"
# bash profile path.
BASH_PROFILE_SRC=/tmp/bash_profile
BASH_PROFILE="/home/$USERNAME/.bash_profile"
# bash aliases
BASH_ALIASES_SRC=/tmp/bash_aliases
BASH_ALIASES="/home/$USERNAME/.bash_aliases"
# gitconfig path.
GITCONFIG_SRC=/tmp/gitconfig
GITCONFIG="/home/$USERNAME/.gitconfig"
# init.vim path.
INITVIM_SRC=/tmp/init.vim
INITVIM="/home/$USERNAME/.config/nvim/init.vim"

if [ -f "$USERS_FILE" ]; then
    echo "creating new users..."
    newusers $USERS_FILE
    adduser $USERNAME sudo

    # Grant docker group access to the user.
    usermod -aG docker $USERNAME

    # Copy bashrc for the user and change the ownership.
    cp $BASHRC_SRC $BASHRC
    chown $USERNAME:$USERNAME $BASHRC

    # Copy bash profile for the user and change the ownership.
    cp $BASH_PROFILE_SRC $BASH_PROFILE
    chown $USERNAME:$USERNAME $BASH_PROFILE

    # Copy bash aliases for the user and change the ownership.
    cp $BASH_ALIASES_SRC $BASH_ALIASES
    chown $USERNAME:$USERNAME $BASH_ALIASES

    # Copy gitconfig for the user and change the ownership.
    cp $GITCONFIG_SRC $GITCONFIG
    chown $USERNAME:$USERNAME $GITCONFIG

    # Create neovim config dir and install vim-plug.
    mkdir -p "/home/$USERNAME/.config/nvim"
    cp $INITVIM_SRC $INITVIM
    chown -R $USERNAME:$USERNAME /home/$USERNAME/.config
    curl -fLo "/home/$USERNAME/.local/share/nvim/site/autoload/plug.vim" --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    chown -R $USERNAME:$USERNAME /home/$USERNAME/.local

    # Create ~/.kube/config to avoid any root program from changing the
    # permission of the default kubeconfig. This happens when KinD-ignite is
    # run.
    mkdir -p "/home/$USERNAME/.kube"
    touch "/home/$USERNAME/.kube/config"
    chown -R $USERNAME:$USERNAME /home/$USERNAME/.kube

    # Install docker buildx.
    # NOTE: Enabling docker cli experimental doesn't installs buildx
    # automatically as documented. Downloading the binary is more reliable.
    mkdir -p /home/$USERNAME/.docker/cli-plugins
    curl -Lo docker-buildx https://github.com/docker/buildx/releases/download/v0.4.1/buildx-v0.4.1.linux-amd64 \
        && chmod +x docker-buildx \
        && mv docker-buildx /home/$USERNAME/.docker/cli-plugins/
    chown -R $USERNAME:$USERNAME /home/$USERNAME/.docker

fi
