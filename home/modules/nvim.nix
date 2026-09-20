{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    plugins = [
      pkgs.vimPlugins.mini-nvim
      pkgs.vimPlugins.nvim-tree-lua
    ];

    extraPackages = with pkgs; [
      bash-language-server
      fd
      lua-language-server
      nixd
      pyright
      ripgrep
      typescript
      typescript-language-server
    ];
  };

  xdg.configFile."nvim" = {
    source = ../nvim;
    force = true;
  };
}
