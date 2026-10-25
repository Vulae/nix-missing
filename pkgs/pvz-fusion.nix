{
    pkgs,
    ...
}: {
    perSystem = { pkgs, ... }:
        let
            gameVersion = "4.0.5.2_alpha";
            gameUrl = "https://github.com/Teyliu/PVZF-Translation/releases/download/4.0.5_alpha/PvZ.Fusion.Multi-lang.4.0.5.2.Alpha.by.Blooms.zip";
            gameHash = "sha256-YgivCU3yROX4fkOchQEnUyuGzgxSK1R3aFFgAFm8Vek=";

            # We don't use pkgs.fetchzip, because it uses `unzip` to unzip the contents which is pretty strict with
            # how it handles file paths, not handling the paths with alternate encodings.
            winAppZip = pkgs.fetchurl {
                url = gameUrl;
                sha256 = gameHash;
            };
            winAppDir = "Game Files";
            winAppExe = "Game Files/PlantsVsZombiesRH.exe";

            pname = "PlantsVsZombiesFusion";

            app = pkgs.writeShellApplication {
                name = "pvz-fusion";
                runtimeInputs = with pkgs; [
                    p7zip
                    wineWow64Packages.stable
                    coreutils
                    gnugrep
                ];
                text = ''
                    GAME_DIR="$HOME/.local/share/pvz-fusion"
                    WINE_PREFIX_DIR="$GAME_DIR/wine"
                    INSTALL_DIR="$GAME_DIR/game"
                    VERSION_FILE="$GAME_DIR/version"
                    NEW_VERSION="${gameVersion}"

                    mkdir -p "$GAME_DIR"

                    if [ ! -f "$VERSION_FILE" ] || [ "$(cat "$VERSION_FILE")" != "$NEW_VERSION" ]; then
                        echo "pvz-fusion version updated or missing, extracting game."

                        rm -rf "$INSTALL_DIR"
                        mkdir -p "$INSTALL_DIR"

                        7z x -y -o"$INSTALL_DIR" "${winAppZip}"
                        chmod -R +w "$INSTALL_DIR"

                        echo "$NEW_VERSION" > "$VERSION_FILE"
                    else
                        echo "pvz-fusion is up to date."
                    fi

                    mkdir -p "$WINE_PREFIX_DIR"

                    export WINEPREFIX="$WINE_PREFIX_DIR"
                    export WINEDEBUG="fixme-all"
                    export WINEDLLOVERRIDES="version=n,b"

                    cd "$INSTALL_DIR/${winAppDir}"
                    exec wine "$INSTALL_DIR/${winAppExe}"
                '';
                meta = {
                    name = "Plats Vs. Zombies: Fusion (Translated)";
                    version = gameVersion;
                    homepage = "https://github.com/Teyliu/PVZF-Translation";
                    # PVZF-Translated is CC-BY-NC-4.0, & the original game I could not find one.
                    license = (with pkgs.lib.licenses; [ cc-by-nc-40 unfree ]);
                };
            };

            desk = pkgs.makeDesktopItem {
                name = "pvz-fusion";
                desktopName = "Plants Vs. Zombies: Fusion (Translated)";
                exec = app;
                icon = ./pvz-fusion.png;
                categories = [ "Game" ];
                terminal = true;
            };
        in
        {
            packages.pvz-fusion = pkgs.symlinkJoin {
                name = "pvz-fusion";
                paths = [ app desk ];
            };
        };
}
