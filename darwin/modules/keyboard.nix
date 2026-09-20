# modules/screenshot-hotkeys.nix
{
  system.defaults.CustomUserPreferences = {
    "com.apple.symbolichotkeys" = {
      AppleSymbolicHotKeys = {

        # 保存整个屏幕  ^⌥2
        "28" = {
          enabled = true;
          value = {
            parameters = [
              50
              19
              786432
            ];
            type = "standard";
          };
        };

        # 保存选区  ^⌥1
        "29" = {
          enabled = true;
          value = {
            parameters = [
              50
              19
              1572864
            ];
            type = "standard";
          };
        };

        # 截图工具栏  ⌥⌘3
        "30" = {
          enabled = true;
          value = {
            parameters = [
              49
              18
              786432
            ];
            type = "standard";
          };
        };

        # 保存窗口
        "31" = {
          enabled = true;
          value = {
            parameters = [
              49
              18
              1572864
            ];
            type = "standard";
          };
        };

        # 复制整个屏幕 ⌥⌘2
        "184" = {
          enabled = true;
          value = {
            parameters = [
              51
              20
              1572864
            ];
            type = "standard";
          };
        };
      };
    };
  };
}
