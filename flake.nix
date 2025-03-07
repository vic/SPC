{

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  inputs.blueprint.url = "github:numtide/blueprint";
  inputs.blueprint.inputs.nixpkgs.follows = "nixpkgs";

  inputs.treefmt-nix.url = "github:numtide/treefmt-nix";
  inputs.treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";

  inputs.bats-support.url = "github:ztombol/bats-support";
  inputs.bats-support.flake = false;
  inputs.bats-assert.url = "github:bats-core/bats-assert";
  inputs.bats-assert.flake = false;

  outputs = inputs: inputs.blueprint { inherit inputs; };

}
