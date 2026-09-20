{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
  makeWrapper,
}:

stdenvNoCC.mkDerivation rec {
  pname = "parabolic";
  version = "2026.5.0";

  src = fetchurl {
    url = "https://github.com/NickvisionApps/Parabolic/releases/download/${version}/Parabolic-macOS-arm64.zip";
    hash = "sha256-4Vk6xlBZ9/mWIc1L9XDLrsa4s16rFubw8qsOhNBIcz0=";
  };

  nativeBuildInputs = [
    unzip
    makeWrapper
  ];

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    extractDir="$TMPDIR/parabolic"
    mkdir -p "$extractDir" "$out/Applications" "$out/bin"
    unzip -q "$src" -d "$extractDir"

    app="$(find "$extractDir" -maxdepth 3 -name 'Parabolic.app' -type d -print -quit)"

    if [ -z "$app" ]; then
      echo "Parabolic.app not found in zip"
      exit 1
    fi

    cp -R "$app" "$out/Applications/Parabolic.app"

    makeWrapper /usr/bin/open "$out/bin/parabolic" \
      --add-flags "$out/Applications/Parabolic.app" \
      --add-flags --args

    runHook postInstall
  '';

  # 保留上游应用及其内置依赖，避免 Nix 修改 Mach-O 文件。
  dontFixup = true;

  meta = {
    description = "Powerful yt-dlp frontend for downloading video and audio";
    homepage = "https://github.com/NickvisionApps/Parabolic";
    license = lib.licenses.gpl3Only;
    platforms = [ "aarch64-darwin" ];
    mainProgram = "parabolic";
  };
}
