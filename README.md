# Jordanp Env

This repo uses a shared Nix + `devenv` package definition to power both local
and containerized Neovim environments.

## Local Neovim (Nix Flake)

Run Neovim with the full toolchain (Node/npm, Python, LuaJIT, git, etc.):

```sh
nix run github:atidyshirt/jordanp-env#neovim
```

## Dockerized Neovim

From your project directory, run:

```sh
bash <(curl -sL https://raw.githubusercontent.com/atidyshirt/jordanp-env/main/install.sh)
```

The container mounts your current directory and starts `nvim` in that same path.
