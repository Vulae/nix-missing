# Base from: https://github.com/edolstra/nix-warez/blob/master/blender/flake.nix
{
    pkgs,
    ...
}: {
    perSystem = { pkgs, ... }:
        let
            app = pkgs.stdenv.mkDerivation (finalAttrs: {
                programVersion = "5.2.3";
                programUrl = "https://download.blender.org/release/Blender5.2/blender-5.2.3-linux-x64.tar.xz";
                programHash = "sha256-eEhsAYtEQ+/l51q1TCkO2MFauv0km4YsLJziUwqRjuw=";
                # TODO: Better name for this, IDK what to name it.
                programVersion2 = "5.2";

                # WARNING: ABSOLUTELY BROKEN!!!!!
                # Install addons declaratively
                # ```nix
                # packages.blender-cuda-test = app.overrideAttrs (oldAttrs: {
                #     addons = [
                #        (pkgs.fetchzip {
                #            name = "bone_widget-2.4.0";
                #            url = "https://github.com/waylow/boneWidget/releases/download/v2.4.0/bone_widget-2.4.0.zip";
                #            hash = "sha256-oVBloBMavjgi9cMR9LiYuG6Bsi+WRdyPO6dSnnz9cJk=";
                #            stripRoot = false;
                #        })
                #     ];
                # });
                # ```
                # FIXME: The way blender loads extensions doesn't like it when we just put it in the extensions folder.
                # Blender REQUIRES the extension directory name to be the same name as stated in the manifest (super dumb i know. . .)
                # AND when I try to fix that by changing the name, it still cannot load it because it wasn't initialized in the *Blender* way and it cant just do it itself.
                addons = [];

                libs = (with pkgs; [
                    wayland
                    libx11 libxi libxxf86vm libxfixes libxrender libsm libice libxkbcommon
                    libGLU libglvnd numactl libdrm ocl-icd vulkan-loader
                    openal alsa-lib pulseaudio
                    stdenv.cc.cc.lib
                    zlib
                ]);

                pname = "blender";
                version = finalAttrs.programVersion;
                src = pkgs.fetchurl {
                    url = finalAttrs.programUrl;
                    hash = finalAttrs.programHash;
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
                        $out/libexec/blender/${finalAttrs.programVersion2}/python/bin/python3*

                    mkdir $out/bin
                    makeWrapper $out/libexec/blender/blender $out/bin/blender \
                        --prefix LD_LIBRARY_PATH : /run/opengl-driver/lib:${pkgs.lib.makeLibraryPath finalAttrs.libs}

                    mkdir -p $out/share/applications
                    mkdir -p $out/share/icons/hicolor/scalable/apps
                    cp $out/libexec/blender/blender.desktop $out/share/applications/blender.desktop
                    cp $out/libexec/blender/blender.svg $out/share/icons/hicolor/scalable/apps/blender.svg
                '' + (pkgs.lib.concatLines (pkgs.lib.forEach finalAttrs.addons (addon: ''
                    ln -s "${addon}" "$out/libexec/blender/${finalAttrs.programVersion2}/extensions/system/${pkgs.lib.baseNameOf addon}"
                '')));
                meta = {
                    name = "Blender";
                    description = "Blender with CUDA support";
                    version = finalAttrs.programVersion;
                    homepage = "https://www.blender.org/";
                    license = (with pkgs.lib.licenses; [ gpl2Plus unfree ]);
                };
            });
        in
        {
            packages.blender-cuda = app;
        };
}
