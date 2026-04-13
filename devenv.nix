{ pkgs, ... }:

let
  commonPackages = import ./nix/modules/common-packages.nix { inherit pkgs; };
in
{
  packages = commonPackages;
}
