{
  description = "Flake for ulibs Development";

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
            stdenv.cc.cc.lib
            nodejs
          ];

          shellHook = ''
            export PATH="$PWD/node_modules/.bin/:$PATH"
            export NPM_PACKAGES="$PWD/.npm-packages"
          '';
        };
      packages."${system}".default =
        let
          pkgs = import nixpkgs { inherit system; };
        in
        pkgs.runCommand "vm"
          {
            buildInputs = with pkgs; [
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
