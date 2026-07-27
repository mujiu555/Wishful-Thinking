{
  description = "STM32 development environment";

  # Flake 的输入，指定 nixpkgs 的来源
  inputs = {
    nixpkgs.url = "git+https://mirrors.nju.edu.cn/git/nixpkgs.git?ref=nixpkgs-unstable&shallow=1";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # Flake 的输出
  outputs =
    {
      self,
      nixpkgs,
      rust-overlay,
      ...
    }:
    let
      system = "x86_64-linux";
      overlays = [ (import rust-overlay) ];
      pkgs = import nixpkgs { inherit system overlays; };
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          gcc-arm-embedded
          (pkgs.rust-bin.stable.latest.default.override {
            extensions = [
              "rust-src"
              "clippy"
            ];
            targets = [
              "thumbv7m-none-eabi"
            ];
          })
          rust-analyzer
          cargo-binutils

          gnumake

          openocd
          gdb
          probe-rs-tools
          stm32flash

          stlink
          stlink-tool

          python3
          dotnet-sdk
        ];

        shellHook = "";
      };
    };
}
