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
        # Bash (not zsh/whatever the host uses) on purpose, and visually
        # distinct - a devcontainer-style badge on the prompt plus
        # enter/exit banners - so it's obvious at a glance whether a given
        # terminal is inside this environment or not.
        shellRc = pkgs.writeText "jordanp-shell.bashrc" ''
          PS1='\[\033[1;97;44m\] jordanp-env \[\033[0m\] \[\033[36m\]\w\[\033[0m\] \$ '
          echo -e "\033[1;97;44m>>> entering jordanp-env shell <<<\033[0m"
          trap 'echo -e "\033[1;97;41m<<< left jordanp-env shell >>>\033[0m"' EXIT
        '';

        jordanpShell = pkgs.writeShellApplication {
          name = "jordanp-shell";
          runtimeInputs = commonPackages.hostPackages;
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
