# Yoinked from: https://github.com/edolstra/nix-warez/blob/master/blender/flake.nix
{
    pkgs,
    ...
}: {
    perSystem = { pkgs, ... }:
        let
            programVersion = "5.2.3";
            programUrl = "https://download.blender.org/release/Blender5.2/blender-5.2.3-linux-x64.tar.xz";
            programHash = "sha256-eEhsAYtEQ+/l51q1TCkO2MFauv0km4YsLJziUwqRjuw=";

            libs = (with pkgs; [
                wayland
                libx11 libxi libxxf86vm libxfixes libxrender libsm libice libxkbcommon
                libGLU libglvnd numactl libdrm ocl-icd vulkan-loader
                openal alsa-lib pulseaudio
                stdenv.cc.cc.lib
                zlib
            ]);

            app = pkgs.stdenv.mkDerivation {
                pname = "blender";
                version = programVersion;
                src = pkgs.fetchurl {
                    url = programUrl;
                    hash = programHash;
                };
                preUnpack = ''
                    mkdir -p $out/libexec
                    cd $out/libexec
                '';
                buildInputs = [ pkgs.makeWrapper ];
                installPhase = ''
                    mv $out/libexec/blender-* $out/libexec/blender

                    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
                        $out/libexec/blender/blender

                    # e.g.: ./blender/5.2/python/bin/python3.13
                    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
                        $out/libexec/blender/*/python/bin/python3*

                    mkdir $out/bin
                    makeWrapper $out/libexec/blender/blender $out/bin/blender \
                        --prefix LD_LIBRARY_PATH : /run/opengl-driver/lib:${pkgs.lib.makeLibraryPath libs}

                    mkdir -p $out/share/applications
                    mkdir -p $out/share/icons/hicolor/scalable/apps
                    cp $out/libexec/blender/blender.desktop $out/share/applications/blender.desktop
                    cp $out/libexec/blender/blender.svg $out/share/icons/hicolor/scalable/apps/blender.svg
                '';
                meta.mainProgram = "blender";
            };
        in
        {
            packages.blender-cuda = app;
        };
}
