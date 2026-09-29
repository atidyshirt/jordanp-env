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

Or drop into a shell instead, with tmux/Claude Code/git/etc. on `PATH`
but no container involved:

```sh
nix run github:atidyshirt/jordanp-env#shell
```

## Dockerized Neovim

From your project directory, run:

```sh
bash <(curl -sL https://raw.githubusercontent.com/atidyshirt/jordanp-env/main/install.sh)
```

The container mounts your current directory and starts `nvim` in that same path.

## Dockerized shell

Same image and mount, but drops you into a bash shell instead of Neovim -
useful as a devcontainer-style environment with Claude Code, tmux, and
friends available, independent of any editor. The prompt gets a
`jordanp-env` badge and enter/exit banners so it's obvious when you're
inside it:

```sh
bash <(curl -sL https://raw.githubusercontent.com/atidyshirt/jordanp-env/main/install.sh) jordanp-shell
```
