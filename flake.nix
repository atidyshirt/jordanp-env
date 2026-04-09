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
        # Use gitMinimal: default `git` pulls a full Python stack (~1+ GiB closure).
        # nodejs-slim (+ npm output): Mason needs Node for many LSP installers; slimmer than `nodejs`.
        # Closure "stripping" in Nix is mostly package choice — deps are hard-linked by reference.
        envPkgs = with pkgs; [
          # Minimal /etc/passwd and /etc/group for containerized environments.
          dockerTools.fakeNss
          coreutils
          ncurses
          gnugrep
          neovim
          tmux
          zsh
          gitMinimal
          curl
          jq
          nodejs-slim
          nodejs-slim.npm
          python3Minimal
          luajit
          cacert
        ];
      in
      {
        packages.default = pkgs.buildEnv {
          name = "jordanp-env";
          paths = envPkgs;
          # Only link usual runtime outputs; avoids pulling dev/doc-only outputs where split.
          extraOutputsToInstall = [ "out" "bin" "lib" ];
        };

        devShells.default = pkgs.mkShell {
          buildInputs = envPkgs;
        };
      }
    );
}
