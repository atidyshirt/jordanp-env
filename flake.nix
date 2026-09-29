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
        neovimDockerImage = pkgs.buildEnv {
          name = "jordanp-env";
          paths = commonPackages.containerPackages;
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
