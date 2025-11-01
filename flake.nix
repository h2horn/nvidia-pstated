{
  description = "A Nix-native driver for NVIDIA GPUs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nvapi-src = {
      url = "https://download.nvidia.com/XFree86/nvapi-open-source-sdk/R555-OpenSource.tar";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nvapi-src,
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      packages.${system}.default = pkgs.stdenv.mkDerivation {
        pname = "nvidia-pstated";
        version = "0.1.0";

        src = ./.;

        nativeBuildInputs = [
          pkgs.cmake
        ];

        buildInputs = [
          pkgs.cudatoolkit
          pkgs.linuxPackages.nvidia_x11
        ];

        cmakeFlags = [
          "-DFETCHCONTENT_SOURCE_DIR_NVAPI=${nvapi-src}"
        ];

        installPhase = ''
          mkdir -p $out/bin
          cp nvidia-pstated $out/bin/
        '';
      };

      apps.${system}.default = {
        type = "app";
        program = "${self.packages.${system}.default}/bin/nvidia-pstated";
      };
    };
}
