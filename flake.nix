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
        neovimEnv = pkgs.buildEnv {
          name = "jordanp-env";
          paths = commonPackages;
          extraOutputsToInstall = [ "out" "bin" "lib" ];
        };
        neovimLauncher = pkgs.writeShellApplication {
          name = "neovim";
          runtimeInputs = commonPackages;
          text = ''
            exec nvim "$@"
          '';
        };
      in
      {
        packages.default = neovimEnv;
        packages.neovim-env = neovimEnv;
        packages.neovim = neovimLauncher;

        apps.neovim = {
          type = "app";
          program = "${neovimLauncher}/bin/neovim";
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
