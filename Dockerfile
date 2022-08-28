FROM archlinux:latest

RUN pacman -Syu --noconfirm

RUN pacman -S make git neovim zsh yarn python3 tmux python-pip --noconfirm

RUN bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh) -y

ENTRYPOINT [ "/bin/zsh" ]
CMD ["-l"]
