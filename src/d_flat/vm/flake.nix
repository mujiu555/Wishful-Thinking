{
  description = "Flake for D_Flat(VM&Assembler) Development";

  inputs = {
    nixpkgs.url = "git+https://mirrors.nju.edu.cn/git/nixpkgs.git?ref=nixos-25.05&shallow=1";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        # Read the file relative to the flake's root
        overrides = (builtins.fromTOML (builtins.readFile (self + "/rust-toolchain.toml")));

        vm = pkgs.rustPlatform.buildRustPackage {
          name = "vm";
          version = "0.1.0";

          buildInputs = with pkgs; [ ];

          src =
            with pkgs.lib;
            cleanSourceWith {
              src = self;
              # a function that returns a bool determining if the path should be included in the cleaned source
              filter =
                path: type:
                let
                  # filename
                  baseName = builtins.baseNameOf (toString path);
                  # path from root directory
                  path' = builtins.replaceStrings [ "${self}/" ] [ "" ] path;
                  # checks if path is in the directory
                  inDirectory = directory: hasPrefix directory path';
                in
                inDirectory "src" || inDirectory "tests" || hasPrefix "Cargo" baseName || baseName == "info.toml";
            };

          cargoLock.lockFile = ./Cargo.lock;
        };
      in
      {

        packages.default =
          let
            pkgs = import nixpkgs { inherit system; };
          in
          pkgs.runCommand "vm" {
            buildInputs = with pkgs; [
              clang
              llvmPackages.bintools
              rustup
            ];
            nativeBuildInputs = with pkgs; [
              makeWrapper
            ];
          } '''';

        devShells.default = pkgs.mkShell rec {
          nativeBuildInputs = [ pkgs.pkg-config ];
          buildInputs = with pkgs; [
            clang
            llvmPackages.bintools
            rustup
          ];

          # RUSTC_VERSION = overrides.toolchain.channel;

          # https://github.com/rust-lang/rust-bindgen#environment-variables
          LIBCLANG_PATH = pkgs.lib.makeLibraryPath [ pkgs.llvmPackages_latest.libclang.lib ];

          shellHook = ''
            export PATH=$PATH:''${CARGO_HOME:-~/.cargo}/bin
            export PATH=$PATH:''${RUSTUP_HOME:-~/.rustup}/toolchains/$RUSTC_VERSION-x86_64-unknown-linux-gnu/bin/
            export SHELL="/run/current-system/sw/bin/bash" ;
            export shell="/run/current-system/sw/bin/bash" ;
          '';

          # Add precompiled library to rustc search path
          RUSTFLAGS = (
            builtins.map (a: ''-L ${a}/lib'') [
              # add libraries here (e.g. pkgs.libvmi)
            ]
          );

          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath (buildInputs ++ nativeBuildInputs);

          # Add glibc, clang, glib, and other headers to bindgen search path
          BINDGEN_EXTRA_CLANG_ARGS =
            # Includes normal include path
            (builtins.map (a: ''-I"${a}/include"'') [
              # add dev libraries here (e.g. pkgs.libvmi.dev)
              pkgs.glibc.dev
            ])
            # Includes with special directory paths
            ++ [
              ''-I"${pkgs.llvmPackages_latest.libclang.lib}/lib/clang/${pkgs.llvmPackages_latest.libclang.version}/include"''
              ''-I"${pkgs.glib.dev}/include/glib-2.0"''
              ''-I${pkgs.glib.out}/lib/glib-2.0/include/''
            ];
        };
      }
    );
}
