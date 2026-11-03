{
    pkgs,
    ...
}: {
    perSystem = { pkgs, ... }:
        let
            app = pkgs.stdenv.mkDerivation (finalAttrs: {
                programVersion = "2.3.0";
                programUrl = "https://github.com/deadlock-mod-manager/deadlock-mod-manager/releases/download/v2.3.0/Deadlock.Mod.Manager_2.3.0_amd64.deb";
                programHash = "sha256-LP5Apu9X67MGp450WNrWx9ICHOd1NjH42JhehpFZH5Q=";

                pname = "deadlock-mod-manager";
                version = finalAttrs.programVersion;

                src = pkgs.fetchurl {
                    url = finalAttrs.programUrl;
                    hash = finalAttrs.programHash;
                };

                libs = (with pkgs; [
                    gccNGPackages_15.libstdcxx
                    webkitgtk_4_1
                    gtk3
                    cairo
                    gdk-pixbuf
                    glib
                    dbus
                    openssl
                    libsoup_3
                    gst_all_1.gstreamer
                    gst_all_1.gst-plugins-base
                    gst_all_1.gst-plugins-good
                    gst_all_1.gst-plugins-bad
                    glib-networking
                ]);

                buildInputs = (with pkgs; [
                    dpkg makeWrapper
                ]);

                unpackPhase = ''
                    dpkg -x $src $out
                '';

                installPhase = ''
                    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
                        $out/usr/bin/deadlock-mod-manager

                    makeWrapper $out/usr/bin/deadlock-mod-manager $out/bin/deadlock-mod-manager \
                        --prefix LD_LIBRARY_PATH : ${pkgs.lib.makeLibraryPath finalAttrs.libs}

                    mkdir -p $out/share/
                    cp -r $out/usr/share/ $out/share/
                '';

                meta = {
                    name = "deadlock-mod-manager";
                    description = "Mod manager for Deadlock";
                    version = finalAttrs.programVersion;
                    homepage = "https://deadlockmods.app/";
                    license = pkgs.lib.licenses.gpl3;
                };
            });
        in
        {
            packages.deadlock-mod-manager = app;
        };
}
