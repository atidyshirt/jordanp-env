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
          PS1='\[\033[38;5;73m\]jordanp-env\[\033[0m\] \[\033[2m\]\w\[\033[0m\] \[\033[38;5;73m\]\$\[\033[0m\] '
          echo -e "\033[2m\033[38;5;73mjordanp-env\033[0m\033[2m shell (type 'exit' to leave)\033[0m"
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
