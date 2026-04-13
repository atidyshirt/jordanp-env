{ pkgs }:
with pkgs; [
  # Minimal /etc/passwd and /etc/group for containerized environments.
  dockerTools.fakeNss
  coreutils
  ncurses
  gnugrep
  fd
  neovim
  zsh
  gitMinimal
  curl
  jq
  nodejs-slim
  nodejs-slim.npm
  python3Minimal
  luajit
  cacert
]
