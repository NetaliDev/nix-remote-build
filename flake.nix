{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }: flake-utils.lib.eachDefaultSystem (system: let
    pkgs = nixpkgs.legacyPackages.${system};
    nix-remote-build = pkgs.callPackage ./nix-remote-build.nix { };
  in {
    packages = {
      inherit nix-remote-build;
      default = nix-remote-build;
    };
  });
}
