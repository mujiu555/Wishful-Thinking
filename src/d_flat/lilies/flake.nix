{
  inputs = {
    naersk.url = "github:nix-community/naersk/master";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      utils,
      naersk,
    }:
    utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        naersk-lib = pkgs.callPackage naersk { };
      in
      {
        defaultPackage = naersk-lib.buildPackage ./.;
        devShell =
          with pkgs;
          mkShell {
            buildInputs = [
              cargo
              rustc
              rustfmt
              rust-analyzer
              pre-commit
              rustPackages.clippy
              nodejs
            ];
            RUST_SRC_PATH = rustPlatform.rustLibSrc;

            shellHook = ''
              export PATH="$PWD/node_modules/.bin/:$PATH"
              export NPM_PACKAGES="$PWD/.npm-packages"
            '';
          };
      }
    );
}
