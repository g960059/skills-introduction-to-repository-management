{
  description = "Dev shell for the Mergington High School Activities API";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        lib = nixpkgs.lib;
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
              "mongodb"
            ];
          };
        };
        python = pkgs.python3.withPackages (ps: with ps; [
          fastapi
          uvicorn
          pymongo
          argon2-cffi
        ]);
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [
            python
            pkgs.mongodb
          ];
        };
      });
}
