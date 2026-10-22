{
    pkgs,
    ...
}: {
    perSystem = { pkgs, ... }:
        let
            programUrl = "https://github.com/ValveResourceFormat/ValveResourceFormat/releases/download/20.1/Source2Viewer.exe";
            programHash = "sha256-tBsoxuo9kmD3ErmE8DgiWabVfx4N/3xcj7GxdUMvO8s=";

            programExe = pkgs.fetchurl {
                url = programUrl;
                sha256 = programHash;
            };

            app = pkgs.writeShellApplication {
                name = "source2viewer-gui";
                runtimeInputs = with pkgs; [
                    wineWow64Packages.stable
                    coreutils
                ];
                text = ''
                    PROGRAM_DIR="$HOME/.local/share/source2viewer"
                    mkdir -p "$PROGRAM_DIR"

                    WINEPREFIX="$PROGRAM_DIR/wine"
                    export WINEPREFIX="$WINEPREFIX"

                    # Initialize wine prefix
                    if [ ! -d "$WINEPREFIX" ]; then
                        echo "Wine prefix doesn't exist, creating it at $WINEPREFIX"
                        wineboot --init
                    fi

                    # Create new drive for steam games
                    STEAM_PATH="$HOME/.steam/steam/steamapps"
                    STEAM_DRIVE_LETTER="y"
                    STEAM_SYMLINK="$WINEPREFIX/dosdevices/$STEAM_DRIVE_LETTER:"
                    if [ -d "$STEAM_PATH" ]; then
                        if [ ! -d "$STEAM_SYMLINK" ]; then
                            echo "Drive $STEAM_DRIVE_LETTER: for steam games was created."
                            ln -s "$STEAM_PATH" "$STEAM_SYMLINK"
                        fi
                    fi

                    # Suppress annoying warnings
                    export WINEDEBUG="fixme-all"

                    # Hide decorations
                    # FIXME: Commented because wine will add its own anyways for some reason
                    # wine reg add "HKEY_CURRENT_USER\Software\Wine\X11 Driver" /v Decorated /t REG_SZ /d N /f

                    cd "$PROGRAM_DIR"
                    exec wine ${programExe}
                '';
            };
        in
        {
            packages.source2-viewer = app;
        };
}
