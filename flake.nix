{
    description = "A bunch of random programs";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        flake-parts.url = "github:hercules-ci/flake-parts";
    };

    outputs = inputs @ { self, nixpkgs, flake-parts }:
        flake-parts.lib.mkFlake { inherit inputs; } {
            systems = [ "x86_64-linux" ];
            imports = [
                ./pkgs/pvz-fusion.nix
                ./pkgs/source2-viewer.nix
            ];
        };
}
