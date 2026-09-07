{
  description = "jordanp-env dev environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    devenv.url = "github:cachix/devenv";
  };

  outputs = { self, nixpkgs, flake-utils, devenv, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        commonPackages = import ./nix/modules/common-packages.nix { inherit pkgs; };
        neovimDockerImage = pkgs.buildEnv {
          name = "jordanp-env";
          paths = commonPackages.containerPackages;
          extraOutputsToInstall = [ "out" "bin" "lib" ];
        };
        neovimNixPackage = pkgs.writeShellApplication {
          name = "neovim";
          runtimeInputs = commonPackages.hostPackages;
          text = ''
            exec nvim "$@"
          '';
        };
      in
      {
        packages.default = neovimDockerImage;
        packages.neovim-env = neovimDockerImage;
        packages.neovim = neovimNixPackage;

        apps.neovim = {
          type = "app";
          program = "${neovimNixPackage}/bin/neovim";
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
