{
  inputs = {
    opam-nix.url = "github:tweag/opam-nix";
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.follows = "opam-nix/nixpkgs";
  };
  outputs =
    {
      self,
      flake-utils,
      opam-nix,
      nixpkgs,
    }@inputs:
    # Don't forget to put the package name instead of `throw':
    let
      package = "ml";
    in
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        on = opam-nix.lib.${system};
        scope = on.buildOpamProject { } package ./. {
          ocaml-base-compiler = "*";
        };
        overlay = final: prev: {
          # Your overrides go here
        };
      in
      {
        legacyPackages = scope.overrideScope overlay;
        devShell = pkgs.mkShell {
          packages = with pkgs; [
            opam
            ocaml
            ocamlPackages.merlin
            ocamlPackages.opam-core
            ocamlPackages.utop
          ];
        };

        packages.default = self.legacyPackages.${system}.${package};
      }
    );
}
