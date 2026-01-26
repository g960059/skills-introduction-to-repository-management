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
              "mongodb-bin"
            ];
          };
        };
        python = pkgs.python3.withPackages (ps: with ps; [
          fastapi
          uvicorn
          pymongo
          argon2-cffi
        ]);

        mongoVersion = "7.0.14";
        mongoDist = if pkgs.stdenv.isDarwin && pkgs.stdenv.isAarch64 then {
          url = "https://fastdl.mongodb.org/osx/mongodb-macos-arm64-${mongoVersion}.tgz";
          sha256 = "sha256-iAX4szgBzQe5ARjCXlB7DeIcatQms3X75J6Jb/xXXQ4=";
        } else if pkgs.stdenv.isDarwin then {
          url = "https://fastdl.mongodb.org/osx/mongodb-macos-x86_64-${mongoVersion}.tgz";
          sha256 = lib.fakeSha256;
        } else
          throw "Unsupported platform for mongodb binary (only macOS is configured).";

        mongodbBin = pkgs.stdenvNoCC.mkDerivation {
          pname = "mongodb-bin";
          version = mongoVersion;
          src = pkgs.fetchurl {
            inherit (mongoDist) url sha256;
          };
          dontBuild = true;
          installPhase = ''
            mkdir -p $out
            tar -xzf $src --strip-components=1 -C $out
          '';
          meta = {
            license = lib.licenses.sspl;
            platforms = lib.platforms.darwin;
          };
        };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [
            python
            mongodbBin
          ];
        };
      });
}
