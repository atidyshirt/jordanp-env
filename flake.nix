{
  description = "jordanp-env dev environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        envPkgs = with pkgs; [
          bash
          coreutils
          ncurses
          neovim
          tmux
          zsh
          git
          curl
          wget
          jq
          nodejs
          python3Minimal
          luajit
          docker-client
          cacert
        ];
      in
      {
        packages.default = pkgs.buildEnv {
          name = "jordanp-env";
          paths = envPkgs;
        };

        devShells.default = pkgs.mkShell {
          buildInputs = envPkgs;
        };
      }
    );
}
