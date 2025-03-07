{ pkgs, inputs, ... }:
let

  spc = inputs.self.packages.${pkgs.system}.SPC.override { emacs = pkgs.emacs-nox; };
  runtimeDeps = [
    pkgs.bats
    pkgs.bash
  ] ++ (pkgs.lib.attrValues spc.runtimePackages);

  bats-lib = pkgs.writeTextFile {
    name = "bats-lib.bash";
    text = ''
      source ${inputs.bats-support}/load.bash
      source ${inputs.bats-assert}/load.bash
    '';
  };

in
pkgs.stdenvNoCC.mkDerivation {
  name = "bats-test";
  phases = [ "check" ];
  check = ''
    export PATH=${pkgs.lib.makeBinPath runtimeDeps}
    export BATS_LIB=${bats-lib}
    export LANG=en_US.UTF-8
    bats ${../test}
    touch $out
  '';
}
