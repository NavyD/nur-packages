# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage
{
  system ? builtins.currentSystem,
  pkgs ? import <nixpkgs> {},
}: {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib {inherit pkgs;}; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  # example-package = pkgs.callPackage ./pkgs/example-package {};
  # some-qt5-package = pkgs.libsForQt5.callPackage ./pkgs/some-qt5-package { };
  # ...

  # [nix-build -A sheldon --show-trace --argstr system aarch64-linux] https://nixos.org/guides/nix-pills/nixpkgs-parameters.html#idm140737319698496
  sheldon = pkgs.callPackage ./pkgs/sheldon {inherit system;};
}
