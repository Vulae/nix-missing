
# [nix-missing](https://github.com/vulae/nix-missing)

A bunch of applications/games not in nixpkgs.

Feel free to contribute by updating outdated programs, or adding new programs.

## [Usage](#usage)

> [!IMPORTANT]
> Only x86_64-linux at the moment.

To run a program, you can just use `nix run`!

`nix run github:vulae/nix-missing#pvz-fusion` / `nix run .#pvz-fusion`


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

## [Table](#table)

None of these applications are built from source.

| Application | Version | Support |
|-|-|-|
| [Plants Vs. Zombies: Fusion (Translated)](https://github.com/Teyliu/PVZF-Translation) | 4.0.5.2_alpha | ✅ |
| [Source2Viewer](https://github.com/ValveResourceFormat/ValveResourceFormat) | 20.1 | ✅ GUI |
| [Blender](https://www.blender.org/) | 5.2.3 | ✅ CUDA |


## [License](#license)

`MIT-0` / `MIT No Attribution` i.e. Literally do anything you want with it lol

