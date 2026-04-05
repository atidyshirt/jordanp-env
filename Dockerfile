# Multi-stage: the final image is Debian slim + only the /nix/store closure for jordanp-env.
# A single-stage nixos/nix image keeps the whole Nix install and grows past ~3 GB.
# @author Jordan Pyott

FROM nixos/nix:latest AS builder
ENV TERM=xterm-256color

COPY flake.nix flake.lock /root/
# QEMU user emulation (Buildx arm64 on amd64): seccomp BPF fails; see https://github.com/NixOS/nix/issues/5258
RUN nix --extra-experimental-features "nix-command flakes" build "/root#default" --out-link /nix/jordanp-env \
    --option filter-syscalls false

COPY ./config/ /root/.config/
COPY ./home/ /root/
RUN mkdir -p /root/.local/share /root/.local/state /root/.cache

ENV XDG_CONFIG_HOME=/root/.config \
    XDG_DATA_HOME=/root/.local/share \
    XDG_STATE_HOME=/root/.local/state \
    XDG_CACHE_HOME=/root/.cache

RUN PATH="/nix/jordanp-env/bin:${PATH}" nvim --headless "+lua vim.pack.update()" "+qall"

# List closure paths before GC (after GC, image tar may not be on PATH). Preserve /nix/jordanp-env symlink.
RUN nix-store --optimise && \
  nix-store -qR /nix/jordanp-env > /tmp/pabs && \
  while IFS= read -r p; do echo "${p#/}"; done < /tmp/pabs | LC_ALL=C sort -u > /tmp/nix-paths.txt && \
  echo nix/jordanp-env >> /tmp/nix-paths.txt && \
  nix-store --gc && \
  tar -cf /tmp/nix-closure.tar -C / -T /tmp/nix-paths.txt

FROM debian:bookworm-slim
ENV TERM=xterm-256color \
    PATH=/nix/jordanp-env/bin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

COPY --from=builder /tmp/nix-closure.tar /tmp/nix-closure.tar
RUN tar -xf /tmp/nix-closure.tar -C / && rm /tmp/nix-closure.tar

COPY --chmod=755 entrypoint.sh /entrypoint.sh
COPY ./config/ /root/.config/
COPY ./home/ /root/
COPY --from=builder /root/.local /root/.local
COPY --from=builder /root/.cache /root/.cache

VOLUME /root
WORKDIR /root

ENTRYPOINT ["/entrypoint.sh"]
CMD ["zsh", "-l"]
