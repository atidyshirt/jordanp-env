{
  description = "jordanp-env dev environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    devenv.url = "github:cachix/devenv";
    neovim-config = {
      url = "github:atidyshirt/neovim";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, devenv, neovim-config, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        commonPackages = import ./nix/modules/common-packages.nix { inherit pkgs; };
        neovimDockerImage = pkgs.buildEnv {
          name = "jordanp-env";
          paths = commonPackages.containerPackages;
          extraOutputsToInstall = [ "out" "bin" "lib" ];
        };
        neovimConfig = pkgs.stdenvNoCC.mkDerivation {
          pname = "jordanp-neovim-config";
          version = "git";

          src = neovim-config;

          installPhase = ''
            mkdir -p $out/nvim
            cp -r . $out/nvim/
          '';
        };

        neovimNixPackage = pkgs.writeShellApplication {
          name = "neovim";

          runtimeInputs = commonPackages.hostPackages;

          text = ''
            export PATH="/usr/bin:/bin:${pkgs.lib.makeBinPath commonPackages.hostPackages}:$PATH"
            export XDG_CONFIG_HOME="${neovimConfig}"
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
