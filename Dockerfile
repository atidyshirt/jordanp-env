# syntax=docker/dockerfile:1.7
# @author Jordan Pyott

ARG PREWARM_NVIM=1
FROM nixos/nix:latest AS builder
ARG PREWARM_NVIM
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

RUN if [ "${PREWARM_NVIM}" = "1" ]; then \
      PATH="/nix/jordanp-env/bin:${PATH}" nvim --headless "+lua vim.pack.update()" "+qall"; \
    fi

RUN nix-store --optimise && \
  nix-store -qR /nix/jordanp-env > /tmp/pabs && \
  while IFS= read -r p; do echo "${p#/}"; done < /tmp/pabs | LC_ALL=C sort -u > /tmp/nix-paths.txt && \
  echo nix/jordanp-env >> /tmp/nix-paths.txt && \
  nix-store --gc && \
  tar -cf /tmp/nix-closure.tar -C / -T /tmp/nix-paths.txt && \
  mkdir -p /tmp/rootfs && \
  tar -xf /tmp/nix-closure.tar -C /tmp/rootfs

FROM scratch
ENV TERM=xterm-256color \
    HOME=/root \
    PATH=/nix/jordanp-env/bin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

COPY --from=builder /tmp/rootfs/ /

COPY --chmod=755 entrypoint.sh /entrypoint.sh
COPY ./config/ /root/.config/
COPY ./home/ /root/
COPY --from=builder /root/.local /root/.local

WORKDIR /root

ENTRYPOINT ["/entrypoint.sh"]
CMD ["zsh", "-il"]
