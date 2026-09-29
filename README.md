# Jordanp Env

This repo uses a shared Nix + `devenv` package definition to power both local
and containerized dev environments. It includes Neovim (config from
[atidyshirt/neovim](https://github.com/atidyshirt/neovim), consumed as a flake
input), tmux, and Claude Code, alongside the rest of the toolchain
(Node/npm, Python, LuaJIT, git, etc.).

## Local Neovim (Nix Flake)

Run Neovim with the full toolchain:

```sh
nix run github:atidyshirt/jordanp-env#neovim
```

## Dockerized Neovim

From your project directory, run:

```sh
bash <(curl -sL https://raw.githubusercontent.com/atidyshirt/jordanp-env/main/install.sh)
```

The container mounts your current directory and starts `nvim` in that same path.
