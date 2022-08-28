FROM archlinux:latest

RUN pacman -S git neovim zsh yarn python3 tmux python-pip --noconfirm

RUN bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh)

ENTRYPOINT [ "/bin/zsh" ]
CMD ["-l"]
