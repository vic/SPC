let
  flake = builtins.getFlake (builtins.toPath ./.);
  system = builtins.currentSystem;
in flake.devShell.${system}
