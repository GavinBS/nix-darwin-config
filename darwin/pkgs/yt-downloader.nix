{
  lib,
  stdenvNoCC,
  fetchurl,
  undmg,
  makeWrapper,
  ffmpeg,
  yt-dlp,
}:

stdenvNoCC.mkDerivation rec {
  pname = "yt-downloader";
  version = "3.22.0";

  src = fetchurl {
    url = "https://github.com/aandrew-me/ytDownloader/releases/download/v${version}/YTDownloader_Mac_arm64.dmg";
    hash = "sha256-AIR/lG/IImA3KbuTJwoyat82Nz8IiKzsNBe0eVcqFhQ=";
  };

  nativeBuildInputs = [
    undmg
    makeWrapper
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/Applications" "$out/bin"

    app="$(find . -maxdepth 3 -name 'YTDownloader.app' -type d -print -quit)"

    if [ -z "$app" ]; then
      echo "YTDownloader.app not found in dmg"
      exit 1
    fi

    cp -R "$app" "$out/Applications/YTDownloader.app"

    wrapProgram "$out/Applications/YTDownloader.app/Contents/MacOS/YTDownloader" \
      --set YTDOWNLOADER_AUTO_UPDATES 0 \
      --set YTDOWNLOADER_FFMPEG_PATH "${lib.getExe ffmpeg}" \
      --set YTDOWNLOADER_YTDLP_PATH "${lib.getExe yt-dlp}"

    makeWrapper /usr/bin/open "$out/bin/yt-downloader" \
      --add-flags "$out/Applications/YTDownloader.app" \
      --add-flags --args

    runHook postInstall
  '';

  # 保留上游 Electron 应用内的 Mach-O 文件，避免 Nix 自动修改。
  dontFixup = true;

  meta = {
    description = "GUI video and audio downloader powered by yt-dlp";
    homepage = "https://github.com/aandrew-me/ytDownloader";
    license = lib.licenses.gpl3Only;
    platforms = [ "aarch64-darwin" ];
    mainProgram = "yt-downloader";
  };
}
