{ pkgs, ... }:
let
  inherit (pkgs) lib writeShellApplication;
  runtimePkgs = {
    inherit (pkgs) coreutils gnused emacs;
  };
  SPC =
    args:
    let
      app = writeShellApplication {
        name = "SPC";
        runtimeInputs = lib.attrValues args;
        text = lib.readFile ../bin/SPC;
      };
    in
    app
    // {
      runtimePackages = args // {
        SPC = app;
      };
    };
in
pkgs.lib.makeOverridable SPC runtimePkgs
