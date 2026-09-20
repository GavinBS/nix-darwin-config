{ config, ... }:

{
  xdg.configFile."ghostty/config" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/nix/home/ghostty/config.ghostty";
    force = true;
  };
}
