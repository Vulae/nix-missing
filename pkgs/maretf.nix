{
    pkgs,
    ...
}: {
    perSystem = { pkgs, ... }:
        let
            app = pkgs.stdenv.mkDerivation (finalAttrs: {
                programVersion = "0.12.3";
                programUrl = "https://github.com/craftablescience/MareTF/releases/download/v0.12.3/MareTF-Linux-x86_64.tar.zst";
                programHash = "sha256-mF5c5q2MouuBIT0rWmkdCG+RrKhUpyFDOb8MA7T2Md4=";

                pname = "maretf_gui";
                version = finalAttrs.programVersion;

                src = pkgs.fetchurl {
                    url = finalAttrs.programUrl;
                    hash = finalAttrs.programHash;
                };

                nativeBuildInputs = (with pkgs; [
                    zstd
                ]);

                buildInputs = (with pkgs; [
                    makeWrapper
                ]);

                libs = (with pkgs; [
                    gccNGPackages_15.libstdcxx
                    libGLX
                    libkrb5
                    zlib
                    libxkbcommon
                    fontconfig
                    libX11
                    glib
                    freetype
                    dbus
                    qt6.qt3d
                    wayland
                ]);

                installPhase = ''
                    runHook preInstall

                    mkdir -p "$out"
                    cp -r ./* "$out/"

                    for bin in maretf maretf_gui maretf_thumbnailer; do
                        patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
                            "$out/$bin"
                        makeWrapper "$out/$bin" "$out/bin/$bin" \
                            --prefix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath finalAttrs.libs}"
                    done

                    runHook postInstall
                '';

                meta = {
                    name = "MareTF";
                    description = "A utility to create, edit, and display every type of VTF file ever made.";
                    homepage = "https://github.com/craftablescience/MareTF";
                    license = pkgs.lib.licenses.MIT;
                };
            });
        in
        {
            packages.maretf = app;
        };
}
