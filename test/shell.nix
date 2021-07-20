let
  flake = builtins.getFlake (builtins.toPath ./.);
  system = if builtins.currentSystem == "aarch64-darwin" then
    "x86_64-darwin"
  else
    builtins.currentSystem;
in flake.devShell.${system}
