{ personal, ... }:

{
  programs.git = {
    enable = true;
    lfs.enable = true;
    settings.user = {
      name = personal.gitName;
      email = personal.gitEmail;
    };
  };
}
