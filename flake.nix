{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.flake-utils.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    let
      allSystems = flake-utils.lib.defaultSystems ++ ["aarch64-darwin"];
      perSystem = (system:
        let
        pkgs = import nixpkgs {
          system = if system == "aarch64-darwin" then "x86_64-darwin" else system;
        };
        mkDerivation = builtins.trace system pkgs.stdenvNoCC.mkDerivation;
        SPC = pkgs.writeScriptBin "SPC" (builtins.readFile ./bin/SPC);
        devPkgs = with pkgs; [ SPC shellcheck bats shfmt nixfmt ];

      in rec {

        devShell = pkgs.mkShell {
          name = "dev";
          packages = devPkgs;
        };

        checks.test = mkDerivation (with pkgs; {
          name = "test";
          buildInputs = devPkgs;
          phases = [ "shfmt" "shellcheck"];

          shfmt = ''
            ${shfmt}/bin/shfmt -i 2 -ci -sr -d .
            touch $out
          '';

          shellcheck = ''
            ${shellcheck}/bin/shellcheck -s bash ${./.}/bin/SPC
            touch $out
          '';

        });

      });

    in (flake-utils.lib.eachSystem allSystems perSystem);
}
