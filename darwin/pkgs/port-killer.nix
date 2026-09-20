{
  lib,
  stdenvNoCC,
  fetchurl,
  _7zz,
}:

stdenvNoCC.mkDerivation rec {
  pname = "port-killer";
  version = "3.3.3";

  src = fetchurl {
    url = "https://github.com/productdevbook/port-killer/releases/download/v${version}/PortKiller-v${version}-macos.dmg";

    hash = "sha256-8Y0PGX80Aeu9LcgYgXk/QXS3cklOQ1f0pjMOKQLMtNg=";
  };

  nativeBuildInputs = [
    _7zz
  ];

  # 不走默认 unpackPhase，否则 Nix 会尝试用 undmg 解包
  dontUnpack = true;

  installPhase = ''
        runHook preInstall

        extractDir="$TMPDIR/port-killer-dmg"
        mkdir -p "$extractDir"
        mkdir -p "$out/Applications"
        mkdir -p "$out/bin"

        7zz x "$src" -o"$extractDir" -y

        app="$(find "$extractDir" -maxdepth 6 -name '*.app' -type d -print -quit)"

        if [ -z "$app" ]; then
          echo "No .app found after extracting dmg"
          echo "Extracted files:"
          find "$extractDir" -maxdepth 5 -print
          exit 1
        fi

        cp -R "$app" "$out/Applications/PortKiller.app"

        # 避免 macOS 隔离属性导致“应用已损坏”
        /usr/bin/xattr -cr "$out/Applications/PortKiller.app" || true

        cat > "$out/bin/port-killer" <<EOF
    #!/bin/sh
    exec open "$out/Applications/PortKiller.app" --args "\$@"
    EOF

        chmod +x "$out/bin/port-killer"

        runHook postInstall
  '';

  # 避免 Nix 修改 App 内部 Mach-O，减少签名/启动问题
  dontFixup = true;

  meta = {
    description = "Cross-platform port management tool for developers";
    homepage = "https://github.com/productdevbook/port-killer";
    license = lib.licenses.mit;
    platforms = [ "aarch64-darwin" ];
    mainProgram = "port-killer";
  };
}
