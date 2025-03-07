{ inputs, pkgs, ... }:
let
  treefmt = inputs.treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
in
treefmt.config.build.wrapper
