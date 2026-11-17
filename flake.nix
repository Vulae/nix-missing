{
    description = "A bunch of random programs";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        flake-parts.url = "github:hercules-ci/flake-parts";
    };

    outputs = inputs @ { self, nixpkgs, flake-parts }:
        flake-parts.lib.mkFlake { inherit inputs; } {
            systems = [ "x86_64-linux" ];
            perSystem = { system, ... }: {
                _module.args.pkgs = import nixpkgs {
                    inherit system;
                    config.allowUnfree = true;
                };
            };
            imports = [
                ./pkgs/pvz-fusion.nix
                ./pkgs/source2-viewer.nix
                ./pkgs/blender-cuda.nix
                ./pkgs/deadlock-mod-manager.nix
            ];
        };
}
