FROM custom_arch

RUN pacman -Syu --noconfirm
RUN pacman -S --needed --noconfirm \
    git \
    fd \
    wget \
    xclip \
    ripgrep \
    base-devel \
    unzip \
    cmake \
    python-pip \
    npm \
    yarn \
    rustup \
    exa \
    tmux \
    zsh \
    neovim \

RUN mkdir dev_scripts .bin
ENV SHELL="/bin/zsh"
ENV PATH="~/.bin:${PATH}"
ENV PATH="~/.local/bin:${PATH}"
ENV PATH="~/.cargo/bin:${PATH}"
ENV PATH="~/.yarn/bin:${PATH}"

RUN wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/FiraCode.zip
RUN unzip FiraCode.zip -d ~/.local/share/fonts
RUN fc-cache -fv

RUN git clone --recurse-submodules -j8 https://github.com/atidyshirt/terminal-configs.git ~
RUN sed -i "s/max_jobs *= *[0-9]\+,*//" ~/.config/nvim/lua/nvim/plugins/packer/install.lua

RUN nvim \
    --headless \
    -c 'autocmd User PackerComplete quitall' \
    -c 'silent PackerSync'

RUN nvim \
    --headless \
    -c 'silent TSInstallSync all' \
    -c 'sleep 20' \
    -c 'qall'

WORKDIR /root
