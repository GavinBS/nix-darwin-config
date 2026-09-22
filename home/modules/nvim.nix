{ config, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    sideloadInitLua = true;

    plugins = [
      pkgs.vimPlugins.mini-nvim
      (pkgs.vimPlugins.nvim-treesitter.withPlugins (parsers: [
        parsers.latex
        parsers.markdown
        parsers.markdown_inline
      ]))
      pkgs.vimPlugins.nvim-tree-lua
      pkgs.vimPlugins.nvim-web-devicons
      pkgs.vimPlugins.render-markdown-nvim
    ];

    extraPackages = with pkgs; [
      bash-language-server
      fd
      lua-language-server
      nixd
      pyright
      python3Packages.pylatexenc
      ripgrep
      typescript
      typescript-language-server
    ];
  };

  xdg.configFile."nvim" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/nix/home/nvim";
    force = true;
  };
}
