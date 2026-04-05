# Dev image: Nix-built binary closure (no source builds) + nerd-ttyd.
# @author Jordan Pyott

# ENV TERM=xterm-256color
FROM nixos/nix:latest

# Layer cache: flake changes less often than dotfiles.
COPY flake.nix flake.lock /root/

RUN nix --extra-experimental-features "nix-command flakes" build "/root#default" --out-link /nix/jordanp-env

COPY ./config/ /root/.config/
COPY ./home/ /root/
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /root

ENTRYPOINT ["/entrypoint.sh"]
CMD ["zsh", "-l"]
