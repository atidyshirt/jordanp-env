# Docker file for jordanp-env image.
# @author Jordan Pyott

FROM ubuntu:20.04 AS builder

LABEL maintainer="atidyshirt"

ARG BUILD_APT_DEPS="ninja-build gettext libevent-dev ncurses-dev build-essential bison libtool libtool-bin autoconf automake cmake g++ pkg-config unzip git binutils wget fontconfig"
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

RUN git clone https://github.com/tmux/tmux.git && \
  cd tmux && \
  sh autogen.sh && \
  ./configure && \
  make && make install

RUN wget https://github.com/ryanoasis/nerd-fonts/releases/download/v${FONT_VERSION}/FiraCode.zip && \
  unzip FiraCode.zip -d /usr/share/fonts && \
  fc-cache -fv

FROM ubuntu:20.04

COPY --from=builder /usr/local /usr/local/
COPY --from=builder /usr/share/fonts /usr/share/fonts/

ENV TERM=xterm-256color

ARG ENVIRONMENT_TOOLS="git zsh"

RUN apt update && apt upgrade -y && \
  apt install -y ${ENVIRONMENT_TOOLS}

RUN mkdir -p /root/.config/nvim
COPY ./config/ /root/.config/
RUN git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
COPY ./home/ /root/
RUN chsh -s $(which zsh)
RUN mkdir -p /home/workspace
WORKDIR /home/workspace

CMD ["/bin/zsh"]
