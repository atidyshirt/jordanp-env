FROM debian:latest

RUN sudo apt install git \
    neovim \
    zsh \
    node \
    yarn \
    npm \
    python3 \
    zsh-autosuggestions \
    tmux \
    -y

RUN bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh)

ENTRYPOINT [ "/bin/zsh" ]
CMD ["-l"]
