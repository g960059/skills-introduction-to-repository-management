{
  description = "Dev shell for the Mergington High School Activities API";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        python = pkgs.python3.withPackages (ps: with ps; [
          fastapi
          uvicorn
          pymongo
          argon2-cffi
        ]);
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [ python ];
        };
      });
}
