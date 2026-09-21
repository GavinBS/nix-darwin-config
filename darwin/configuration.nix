{ pkgs, personal, ... }:

let
  reeden = pkgs.callPackage ./pkgs/reeden.nix { };
  bili23-downloader = pkgs.callPackage ./pkgs/bili23-downloader.nix { };
  port-killer = pkgs.callPackage ./pkgs/port-killer.nix { };
  yt-downloader = pkgs.callPackage ./pkgs/yt-downloader.nix { };
  parabolic = pkgs.callPackage ./pkgs/parabolic.nix { };

in
{
  nix.enable = false;

  system.primaryUser = personal.username;

  imports = [
    ./modules/keyboard.nix
  ];

  homebrew = {
    enable = true;

    onActivation = {
      # Keep upgrades explicit, but remove undeclared Homebrew items on rebuild.
      autoUpdate = false;
      upgrade = false;
      cleanup = "zap";
      extraFlags = [
        "--verbose"
      ];
    };

    brews = [
      "libpq"
      "whisper-cpp"
      "opencode"
      "lazygit"
      "python@3.11"
      "python@3.12"
    ];

    casks = [
      # Apps
      "opencode-desktop"
      "termius"
      "codex"
      "homebrew-app"
      "balenaetcher"
      "squirrel-app"
      "seafile-client"
      "iina"
      "snipaste"
      "free-download-manager"
      "comfy"
      "inkscape"
      "virtualbox"
      "utm"
      "datagrip"
      "google-chrome"
      "microsoft-edge"
      "stash"
      "thunder"
      "tuta-mail"
      "visual-studio-code"
      "fuse-t"
      "veracrypt-fuse-t"
      "sidequest"
      "telegram"
      "bitwarden"
      "tailscale-app"
      "wechat"
      "windows-app"
      "localsend"
      "dingtalk"
      "raindropio"
      "altserver"
      "uu-booster"
      "orbstack"
      "ghostty"
      "chatgpt"

      # Fonts
      "font-jetbrains-mono-nerd-font"
      "font-noto-sans"
      "font-noto-sans-cjk"
      "font-noto-sans-cjk-jp"
      "font-noto-sans-cjk-sc"
      "font-noto-sans-cjk-tc"
      "font-symbols-only-nerd-font"
    ];
  };

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (pkgs.lib.getName pkg) [
      "unrar"
      "reeden"
    ];

  environment.systemPackages = [
    reeden
    bili23-downloader
    port-killer
    yt-downloader
    parabolic
  ];

  fonts.packages = [
    pkgs.sarasa-gothic
  ];

  system.stateVersion = 6;

  nixpkgs.hostPlatform = "aarch64-darwin";
}
