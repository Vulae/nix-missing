
# [nix-missing](https://github.com/vulae/nix-missing)

A bunch of applications/games not in nixpkgs.

Feel free to contribute by updating outdated programs, or adding new programs.

## [Usage](#usage)

> [!IMPORTANT]
> Only x86_64-linux at the moment.

To run a program, you can just use `nix run`!

`nix run github:vulae/nix-missing#pvz-fusion` / `nix run .#pvz-fusion`

> [!NOTE]
> Some packages are unfree, use `NIXPKGS_ALLOW_UNFREE=1` as an environment variable, while also passing `--impure` as an argument.
> `NIXPKGS_ALLOW_UNFREE=1 nix run --impure github:vulae/nix-missing#pvz-fusion`

To install a program, include nix-missing in your flake!

```nix
inputs = {
    # ...
    nix-missing.url = "github:vulae/nix-missing";
    # ...
};
```

Then install it like any other nix program!

```nix
{
    pkgs,
    nix-missing,
    ...
}: {
    packages = [
        # ...
        nix-missing.packages.${pkgs.stdenv.hostPlatform.system}.pvz-fusion
        # ...
    ];
}
```

> [!NOTE]
> Some packages are unfree, allow all unfree packages with `nixpkgs.config.allowUnfree = true;`, or specific packages with `nixpkgs.config.allowUnfreePredicate`
> ```nix
> nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
>     "pvz-fusion"
> ];
> ```

## [Table](#table)

None of these applications are built from source.

| Application | Version | Support | Note |
|-|-|-|-|
| [Plants Vs. Zombies: Fusion (Translated)](https://github.com/Teyliu/PVZF-Translation) | 4.0.5.2_alpha | ✅ | |
| [Source2Viewer](https://github.com/ValveResourceFormat/ValveResourceFormat) | 20.1 | ✅ GUI | GUI is Windows only, nixpkgs version is CLI only |
| [Blender](https://www.blender.org/) | 5.2.3 | ✅ CUDA | nixpkgs version doesn't have CUDA support |


## [License](#license)

`MIT-0` / `MIT No Attribution` i.e. Literally do anything you want with it lol

