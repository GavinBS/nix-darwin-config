{ pkgs, personal, ... }:

{
  imports = [
    ./modules/packages.nix
    ./modules/git.nix
    ./modules/zsh.nix
    ./modules/starship.nix
    ./modules/fzf.nix
    ./modules/zoxide.nix
    ./modules/nvim.nix
    ./modules/syncthing.nix
    ./modules/yt-dlp.nix
    ./modules/ghostty.nix
    ./modules/llmster.nix
  ];

  home.stateVersion = "26.05";

  home.username = personal.username;

  home.homeDirectory = "/Users/${personal.username}";

  home.packages = with pkgs; [
    ffmpeg
    uv
    wget
    tree
    unrar
    cmake
    powershell
    _7zz
  ];

  home.sessionPath = [
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
    "/opt/homebrew/opt/libpq/bin"
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  programs.home-manager.enable = true;
}
