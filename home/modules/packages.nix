{ pkgs, ... }:

{
  home.packages = with pkgs; [
    ripgrep
    fd
    bat
    eza
    fastfetch
    bottom
    btop
    htop
    tmux
    yazi
    socat
    stow
  ];
}
