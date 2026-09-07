{ pkgs }:
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
  ];
in
{
  inherit hostPackages;

  containerPackages = [
    dockerTools.fakeNss
  ] ++ hostPackages;
}
