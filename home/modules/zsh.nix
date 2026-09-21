{
  programs.zsh = {
    enable = true;
    history = {
      size = 10000;
      save = 10000;
      path = "$HOME/.zsh_history";
      ignoreSpace = true;
      ignoreDups = true;
      expireDuplicatesFirst = true;
      extended = true;
      share = true;
    };
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    initContent = ''
      ${builtins.readFile ../zsh/functions.zsh}
      ${builtins.readFile ../pm/pm.zsh}
    '';
  };
}
