{
  config,
  lib,
  pkgs,
  ...
}:

let
  version = "0.0.25-1";

  llmsterBootstrap = pkgs.stdenvNoCC.mkDerivation {
    pname = "llmster-bootstrap";
    inherit version;

    src = pkgs.fetchurl {
      url = "https://llmster.lmstudio.ai/download/${version}-darwin-arm64.full.tar.gz";
      hash = "sha256-/O1G7pi0Ic+l3302gjgX5nJHKl7ZKdAxyMNbfVqinLg=";
    };

    sourceRoot = ".";

    installPhase = ''
      runHook preInstall

      mkdir -p "$out/libexec/llmster"
      cp -R .bundle llmster llmster.zip "$out/libexec/llmster/"

      runHook postInstall
    '';

    dontFixup = true;
  };

  versionFile = pkgs.writeText "llmster-version" version;
  marker = "${config.home.homeDirectory}/.lmstudio/.nix-llmster-version";
in
{
  home.sessionPath = [
    "${config.home.homeDirectory}/.lmstudio/bin"
  ];

  home.activation.installLlmster = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [[ ! -f "${marker}" ]] || [[ "$(<"${marker}")" != "${version}" ]]; then
      run env LMS_NO_MODIFY_PATH=1 \
        ${llmsterBootstrap}/libexec/llmster/llmster bootstrap
      run ${pkgs.coreutils}/bin/install -Dm644 ${versionFile} "${marker}"
    fi
  '';
}
