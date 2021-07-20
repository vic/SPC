{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.flake-utils.inputs.nixpkgs.follows = "nixpkgs";

  inputs.bats-support.url = "github:ztombol/bats-support";
  inputs.bats-support.flake = false;
  inputs.bats-assert.url = "github:bats-core/bats-assert";
  inputs.bats-assert.flake = false;

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    let
      allSystems = flake-utils.lib.defaultSystems ++ [ "aarch64-darwin" ];
      perSystem = (system:
        let
          pkgs = import nixpkgs {
            system =
              if system == "aarch64-darwin" then "x86_64-darwin" else system;
          };

          lib = nixpkgs.lib;

          mkDerivation = builtins.trace system pkgs.stdenvNoCC.mkDerivation;

          devPkgs = with pkgs; [ shellcheck bats shfmt nixfmt ];

          batsRunner = mkDerivation (with pkgs; rec {
            name = "bats-runner";
            nativeBuildInputs = [ makeWrapper ];
            runner = writeShellScriptBin "bats-runner" "bats ${./test}";
            batsLib = writeTextFile {
              name = "load.bash";
              text = ''
                source ${inputs.bats-support}/load.bash
                source ${inputs.bats-assert}/load.bash
              '';
            };
            phases = [ "wrap" ];
            wrap = ''
              mkdir -p $out/bin
              ln -s ${./bin/SPC} $out/bin/SPC
              makeWrapper ${runner}/bin/bats-runner $out/bin/bats-runner \
                --prefix PATH : ${
                  lib.makeBinPath (devPkgs ++ [ coreutils emacs-nox ])
                } \
                --prefix PATH : $out/bin \
                --set BATS_LIB "${batsLib}"
            '';
          });

        in rec {

          devShell = pkgs.mkShell {
            name = "dev";
            packages = devPkgs;
          };

          checks.test = mkDerivation (with lib;
            with pkgs; {
              name = "test";
              phases = [ "shfmt" "shellcheck" "bats" ];

              shfmt = ''
                ${shfmt}/bin/shfmt -i 2 -ci -sr -d .
                touch $out
              '';

              shellcheck = ''
                ${shellcheck}/bin/shellcheck -s bash ${./.}/bin/SPC
                touch $out
              '';

              bats = ''
                ${batsRunner}/bin/bats-runner
                touch $out
              '';

            });

        });

    in (flake-utils.lib.eachSystem allSystems perSystem);
}
