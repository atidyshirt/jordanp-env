# Docker file for jordanp-env image.
# @author Jordan Pyott

FROM ubuntu:20.04 AS builder

LABEL maintainer="atidyshirt"

ARG BUILD_APT_DEPS="ninja-build gettext libevent-dev ncurses-dev build-essential bison libtool libtool-bin autoconf automake cmake g++ pkg-config unzip git binutils wget fontconfig apt-transport-https ca-certificates curl gnupg-agent software-properties-common"
ARG FONT_VERSION="3.0.1"
ARG DEBIAN_FRONTEND=noninteractive
ARG TARGET=stable

RUN apt update && apt upgrade -y && \
  apt install -y ${BUILD_APT_DEPS} && \
  git clone https://github.com/neovim/neovim.git /tmp/neovim && \
  cd /tmp/neovim && \
  git fetch --all --tags -f && \
  git checkout ${TARGET} && \
  make CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_INSTALL_PREFIX=/usr/local/ && \
  make install && \
  strip /usr/local/bin/nvim

RUN wget https://github.com/tmux/tmux/releases/download/3.3a/tmux-3.3a.tar.gz && \
  tar xvf tmux-3.3a.tar.gz && \
  cd ./tmux-3.3a && \
  ./configure && \
  make && make install

RUN wget https://github.com/ryanoasis/nerd-fonts/releases/download/v${FONT_VERSION}/FiraCode.zip && \
  unzip FiraCode.zip -d /usr/share/fonts && \
  fc-cache -fv

FROM ubuntu:20.04

COPY --from=builder /usr/local /usr/local/
COPY --from=builder /usr/share/fonts /usr/share/fonts/

ENV TERM=xterm-256color
ENV NVIM_LSP_DOCKER=true

# Ensure we don't get asked for timezone data - provide via ipapi api
RUN ln -fs /usr/share/zoneinfo/$(curl https://ipapi.co/timezone) /etc/localtime
RUN export DEBIAN_FRONTEND=noninteractive

RUN apt update && apt upgrade -y
RUN apt install -y ca-certificates curl gnupg
RUN mkdir -p /etc/apt/keyrings
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
RUN curl -sSL https://get.docker.com/ | sh

ENV NODE_MAJOR=18
RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list

ARG ENVIRONMENT_TOOLS="wget git make ripgrep zsh gcc libevent-core-2.1-7 nodejs python software-properties-common"

RUN apt update && apt upgrade -y && \
  apt install -y ${ENVIRONMENT_TOOLS}

RUN npm install --global yarn typescript

RUN mkdir -p /root/.config/nvim
COPY ./config/ /root/.config/
RUN git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions

ARG SETTINGS_PATH="/root/.config/nvim/lua/core/resources/defaults/core/settings.lua"

RUN sed -i "s/nerd_font_enabled\s*=\s*true/nerd_font_enabled = false/g" $SETTINGS_PATH
RUN sed -i "s/luarocks_enabled\s*=\s*true/luarocks_enabled = false/g" $SETTINGS_PATH

COPY ./home/ /root/
RUN chsh -s $(which zsh)

RUN nvim --headless "+Lazy! sync" +qa

RUN mkdir -p /home/workspace
WORKDIR /home/workspace

CMD ["/bin/zsh"]
