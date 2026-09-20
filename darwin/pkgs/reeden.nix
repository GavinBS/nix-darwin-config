{
  lib,
  stdenvNoCC,
  fetchurl,
  undmg,
}:

stdenvNoCC.mkDerivation rec {
  pname = "reeden";
  version = "1.34.1";

  src = fetchurl {
    url = "https://github.com/reeden-org/reeden-app/releases/download/v${version}/Reeden-macos.dmg";
    hash = "sha256-GWYLR/pxQfgSUYbj2sYyTkbfMwh8MwQmyHWYxuPEwl8=";
  };

  nativeBuildInputs = [ undmg ];

  sourceRoot = ".";

  installPhase = ''
        runHook preInstall

        mkdir -p "$out/Applications"

        app="$(find . -maxdepth 3 -name '*.app' -type d -print -quit)"

        if [ -z "$app" ]; then
          echo "No .app found in dmg"
          exit 1
        fi

        cp -R "$app" "$out/Applications/Reeden.app"

        mkdir -p "$out/bin"
        cat > "$out/bin/reeden" <<EOF
    #!/bin/sh
    exec open "$out/Applications/Reeden.app" --args "\$@"
    EOF
        chmod +x "$out/bin/reeden"

        runHook postInstall
  '';

  # macOS .app 不要 strip / patch，避免破坏签名
  dontFixup = true;

  meta = {
    description = "Reeden ebook reader";
    homepage = "https://reeden.app";
    license = lib.licenses.unfree;
    platforms = lib.platforms.darwin;
    mainProgram = "reeden";
  };
}
