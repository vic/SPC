{
  projectRootFile = "flake.nix";
  programs.nixfmt.enable = true;
  programs.nixfmt.excludes = [ ".direnv" ];
  programs.shellcheck.enable = true;
  programs.shellcheck.includes = [
    "*.bats"
    "bin/SPC"
  ];
  programs.shellcheck.excludes = [ ".envrc" ];
  programs.beautysh.enable = true;
  programs.beautysh.includes = [
    "*.bats"
    "bin/SPC"
  ];
}
