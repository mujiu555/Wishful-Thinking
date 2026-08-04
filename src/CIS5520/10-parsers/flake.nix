{
  description = "Flake for ulibs Development";

  inputs = {
    nixpkgs.url = "git+https://mirrors.nju.edu.cn/git/nixpkgs.git?ref=nixos-26.05&shallow=1";
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
            haskellPackages.stack
          ];

        };
      packages."${system}".default =
        let
          pkgs = import nixpkgs { inherit system; };
        in
        pkgs.runCommand "vm" {
          buildInputs = with pkgs; [
          ];
          nativeBuildInputs = with pkgs; [
            makeWrapper
          ];
        } "";
    };
}
