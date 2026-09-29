{ pkgs, neovimPackage ? pkgs.neovim }:
with pkgs;
let
  hostPackages = [
    coreutils
    ncurses
    gnugrep
    gnutar
    gnumake
    bash
    unzip
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
    tmux
    claude-code
  ];
in
{
  inherit hostPackages;

  # neovimPackage (the atidyshirt/neovim flake's wrapped package) replaces the
  # bare `neovim` from hostPackages here so the container gets nvim with its
  # config baked in, instead of a config-less editor.
  containerPackages = [
    dockerTools.fakeNss
    neovimPackage
  ] ++ lib.remove neovim hostPackages;
}
