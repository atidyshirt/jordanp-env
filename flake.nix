{
  description = "jordanp-env dev environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    devenv.url = "github:cachix/devenv";
    neovim = {
      url = "github:atidyshirt/neovim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, devenv, neovim, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfreePredicate =
            pkg: builtins.elem (nixpkgs.lib.getName pkg) [ "claude-code" ];
        };
        commonPackages = import ./nix/modules/common-packages.nix {
          inherit pkgs;
          neovimPackage = neovim.packages.${system}.default;
        };
        shellRc = pkgs.writeText "jordanp-shell.bashrc" ''
          # Standard Debian/VS Code devcontainer .bashrc prompt: bold green
          # user@host, bold blue cwd. Also sets the terminal tab title.
          PS1='\[\e]0;\u@\h: \w\a\]\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

          # GNU coreutils' stock dircolors scheme is low-contrast on dark
          # backgrounds (near-black blue dirs); use a more readable palette.
          export LS_COLORS='di=01;36:ln=01;36:so=01;35:pi=33:ex=01;32:bd=01;33:cd=01;33:su=37;41:sg=30;43:tw=30;42:ow=34;42'
          alias ls='ls --color=auto'
          alias grep='grep --color=auto'
          alias ll='ls -alF'
          alias la='ls -A'
          alias l='ls -CF'

          echo -e "\033[2mjordanp-env shell (type 'exit' to leave)\033[0m"
          trap 'echo -e "\033[2mleft jordanp-env shell\033[0m"' EXIT
        '';

        jordanpShell = pkgs.writeShellApplication {
          name = "jordanp-shell";
          runtimeInputs = commonPackages.containerPackages;
          text = ''exec bash --rcfile ${shellRc} -i "$@"'';
        };

        neovimDockerImage = pkgs.buildEnv {
          name = "jordanp-env";
          paths = commonPackages.containerPackages ++ [ jordanpShell ];
          extraOutputsToInstall = [ "out" "bin" "lib" ];
        };
      in
      {
        packages.default = neovimDockerImage;
        packages.neovim-env = neovimDockerImage;
        packages.neovim = neovim.packages.${system}.default;

        apps.neovim = {
          type = "app";
          program = "${neovim.packages.${system}.default}/bin/nvim";
        };

        apps.shell = {
          type = "app";
          program = "${jordanpShell}/bin/jordanp-shell";
        };

        devShells.default = devenv.lib.mkShell {
          inherit inputs pkgs;
          modules = [
            ({ ... }: {
              devenv.root = builtins.toString ./.;
              imports = [ ./devenv.nix ];
            })
          ];
        };
      }
    );
}
