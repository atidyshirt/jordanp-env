# Docker file for jordanp-env image.
# @author Jordan Pyott

FROM archlinux:base

ENV PATH="${PATH}:/root/.local/bin"
ENV TERM=xterm-256color
ENV NVIM_LSP_DOCKER=true

# neovim enviornment variables - disable defaults for quick work in containers
ENV NERD_FONT_ENABLED=false
ENV AUTO_DARK_MODE_ENABLED=false

RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm \
      base-devel \
      bison \
      libtool \
      autoconf \
      automake \
      cmake \
      unzip \
      git \
      wget \
      fontconfig \
      linux-headers \
      ca-certificates \
      curl \
      gnupg \
      zsh \
      make \
      ripgrep \
      gcc \
      nodejs \
      npm \
      python \
      lua \
      luajit \
      bash \
      docker && \
    pacman -Scc --noconfirm

ARG TMUX_VERSION="3.3a"

RUN git clone https://github.com/neovim/neovim.git /tmp/neovim \
    && cd /tmp/neovim \
    && git fetch --all --tags -f \
    && git checkout nightly \
    && make CMAKE_BUILD_TYPE=MinSizeRel CMAKE_INSTALL_PREFIX=/usr/local/ \
    && make install \
    && strip /usr/local/bin/nvim \
    && rm -rf /tmp/neovim

RUN wget https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz \
    && tar xf tmux-${TMUX_VERSION}.tar.gz \
    && cd ./tmux-${TMUX_VERSION} \
    && ./configure \
    && make \
    && make install \
    && cd / \
    && rm -rf ./tmux-${TMUX_VERSION} tmux-${TMUX_VERSION}.tar.gz

RUN npm install -g yarn typescript

RUN wget -q -O /usr/sbin/ttyd.nerd https://github.com/Lanjelin/nerd-ttyd/releases/download/1.7.7/ttyd.x86_64 && \
    chmod +x /usr/sbin/ttyd.nerd

RUN mkdir -p /edit

COPY entrypoint.sh .
COPY ./config/ /root/.config/
COPY ./home/ /root/

RUN nvim --headless "+lua vim.pack.update()" +qa
RUN nvim --headless "MasonInstall --target=linux_arm64_gnu lua-language-server" +qa

VOLUME /root
WORKDIR /home/workspace

EXPOSE 7681
CMD ["ttyd.nerd", "-W", "-t", "fontFamily=JetBrains", "zsh"]
