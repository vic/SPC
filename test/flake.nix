{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.flake-utils.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    let allSystems = flake-utils.lib.defaultSystems ++ [ "aarch64-darwin" ];
    in flake-utils.lib.eachSystem allSystems (system:
      let
        pkgs = import nixpkgs { inherit system; };
        mkDerivation = builtins.trace system pkgs.stdenvNoCC.mkDerivation;
        SPC = pkgs.writeScriptBin "SPC" (builtins.readFile ./bin/SPC);
        devPkgs = with pkgs; []; #  [ SPC shellcheck bats shfmt nixfmt ];

      in rec {

        devShell = pkgs.mkShell {
          name = "dev";
          packages = devPkgs;
        };

        checks.test = mkDerivation (with pkgs; {
          name = "test";
          phases = ["check"];
          check = ''
            ${shfmt}/bin/shfmt -i 2 -ci -sr -d .
            touch $out
          '';
        });

      });
}
