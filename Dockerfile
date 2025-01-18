# Docker file for jordanp-env image.
# @author Jordan Pyott

FROM alpine:3.18 AS builder

ARG BUILD_DEPS="ninja-build gettext-dev libevent-dev ncurses-dev build-base bison libtool autoconf automake cmake g++ pkgconfig unzip git binutils wget fontconfig"
ARG TMUX_VERSION="3.3a"
ARG TARGET=stable

RUN apk add --no-cache ${BUILD_DEPS} \
    && git clone https://github.com/neovim/neovim.git /tmp/neovim \
    && cd /tmp/neovim \
    && git fetch --all --tags -f \
    && git checkout ${TARGET} \
    && make CMAKE_BUILD_TYPE=MinSizeRel CMAKE_INSTALL_PREFIX=/usr/local/ \
    && make install \
    && strip /usr/local/bin/nvim

RUN wget https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz \
    && tar xvf tmux-${TMUX_VERSION}.tar.gz \
    && cd ./tmux-${TMUX_VERSION} \
    && ./configure \
    && make \
    && make install

FROM alpine:3.18

COPY --from=builder /usr/local /usr/local/

ENV TERM=xterm-256color
ENV NVIM_LSP_DOCKER=true

ARG RUNTIME_LIBS="gettext ncurses-dev libevent musl-dev gcompat"
ARG RUNTIME_UTILS="ca-certificates curl gnupg zsh git make ripgrep gcc nodejs npm python3 lua luajit zsh-vcs bash man docker"
ARG RUNTIME_NODE_DEPS="yarn typescript"

RUN apk add --no-cache ${RUNTIME_LIBS} ${RUNTIME_UTILS} && npm install -g ${RUNTIME_NODE_DEPS}

COPY ./config/ /root/.config/
COPY ./home/ /root/

ARG SETTINGS_PATH="/root/.config/nvim/lua/core/resources/defaults/core/settings.lua"
RUN sed -i "s/nerd_font_enabled\s*=\s*true/nerd_font_enabled = false/g" $SETTINGS_PATH \
    && sed -i "s/luarocks_enabled\s*=\s*true/luarocks_enabled = false/g" $SETTINGS_PATH

RUN nvim --headless "+Lazy! sync" +qa
RUN nvim --headless "MasonInstall --target=linux_arm64_gnu lua-language-server" +qa

WORKDIR /home/workspace

CMD ["/bin/zsh"]
