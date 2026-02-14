{
  description = "Flake for TaPL OCaml implemention for typechackers";

  inputs = {
    nixpkgs.url = "git+https://mirrors.nju.edu.cn/git/nixpkgs.git?ref=nixos-25.11&shallow=1";
  };

  outputs =
    { self, nixpkgs, ... }:
    let
      # system should match the system you are running on
      system = "x86_64-linux";
    in
    {
      devShells."${system}".default =
        let
          pkgs = import nixpkgs { inherit system; };
        in
        pkgs.mkShell {
          packages = with pkgs; [
            llvmPackages.clang-tools
            stdenv
            gcc
            gnumake
            llvm
            clang
            cunit
            xmake
            llvmPackages.libcxxClang
          ];

          shellHook = ''
            export SHELL="/run/current-system/sw/bin/bash" ;
            export shell="/run/current-system/sw/bin/bash" ;
          '';
        };
      packages."${system}".default =
        let
          pkgs = import nixpkgs { inherit system; };
        in
        pkgs.runCommand "vm"
          {
            buildInputs = with pkgs; [
              cunit
              xmake
            ];
            nativeBuildInputs = with pkgs; [
              makeWrapper
            ];
          }
          ''
            xmake
          '';
    };
}
