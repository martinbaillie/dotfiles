{ options, config, lib, ... }:
with lib; {
  options.theme = {
    wallpaper = mkOption { type = with types; nullOr (either str path); };
    icons = mkOption { type = with types; nullOr (either str path); };
    colours = {
      bg = mkOption { type = types.str; };
      bgalt = mkOption { type = types.str; };
      base0 = mkOption { type = types.str; };
      base1 = mkOption { type = types.str; };
      base2 = mkOption { type = types.str; };
      base3 = mkOption { type = types.str; };
      base4 = mkOption { type = types.str; };
      base5 = mkOption { type = types.str; };
      base6 = mkOption { type = types.str; };
      base7 = mkOption { type = types.str; };
      base8 = mkOption { type = types.str; };
      fg = mkOption { type = types.str; };
      fgalt = mkOption { type = types.str; };
      grey = mkOption { type = types.str; };
      red = mkOption { type = types.str; };
      orange = mkOption { type = types.str; };
      green = mkOption { type = types.str; };
      teal = mkOption { type = types.str; };
      yellow = mkOption { type = types.str; };
      blue = mkOption { type = types.str; };
      darkblue = mkOption { type = types.str; };
      magenta = mkOption { type = types.str; };
      violet = mkOption { type = types.str; };
      cyan = mkOption { type = types.str; };
      darkcyan = mkOption { type = types.str; };
    };
  };

  config = {
    my = {
      env.ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE =
        "fg=${config.theme.colours.fg},bg=${config.theme.colours.base4}";

      home.xdg.configFile."wallpaper".source =
        let local = "${(builtins.getEnv "XDG_DATA_HOME")}/.wallpaper";
        in if builtins.pathExists local then local else config.theme.wallpaper;
    };
  };
}
