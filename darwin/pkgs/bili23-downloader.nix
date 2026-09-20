{
  lib,
  stdenvNoCC,
  fetchurl,
  undmg,
}:

stdenvNoCC.mkDerivation rec {
  pname = "bili23-downloader";
  version = "2.15.0";

  src = fetchurl {
    url = "https://github.com/ScottSloan/Bili23-Downloader/releases/download/v${version}/Bili23-Downloader_${version}_macos_aarch64.dmg";
    hash = "sha256-mDmSNGtzBWW+qX5caBRzpVnXVQNZG13Bn5M7RTU6hG0=";
  };

  nativeBuildInputs = [ undmg ];

  sourceRoot = ".";

  installPhase = ''
        runHook preInstall

        mkdir -p "$out/Applications"

        app="$(find . -maxdepth 3 -name '*.app' -type d -print -quit)"

        if [ -z "$app" ]; then
          echo "No .app bundle found in dmg"
          exit 1
        fi

        appName="$(basename "$app")"

        # 保留上游原始 App 名称
        cp -R "$app" "$out/Applications/$appName"

        mkdir -p "$out/bin"
        cat > "$out/bin/bili23-downloader" <<EOF
    #!/bin/sh
    exec open "$out/Applications/$appName" --args "\$@"
    EOF

        chmod +x "$out/bin/bili23-downloader"

        runHook postInstall
  '';

  # 不修改 Mach-O 文件，避免破坏上游 macOS 签名
  dontFixup = true;

  meta = {
    description = "Cross-platform Bilibili video downloader";
    homepage = "https://github.com/ScottSloan/Bili23-Downloader";
    license = lib.licenses.gpl3Only;
    platforms = [ "aarch64-darwin" ];
    mainProgram = "bili23-downloader";
  };
}
