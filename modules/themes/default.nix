{ options, config, lib, ... }:
with builtins;
with lib;
with lib.my;
let cfg = config.modules.theme;
in
{
  options.modules.theme = with types; {
    mode = mkOption {
      type = enum [ "light" "dark" ];
      default = "light";
      apply = v:
        # Allow overrides via $THEME_MODE.
        let theme = getEnv "THEME_MODE";
        in if theme != "" then theme else v;
    };
    wallpaper = mkOption { type = nullOr (either str path); };
    icons = mkOption { type = nullOr (either str path); };
    tridactyl = mkStrOpt { };
    colours = {
      bg = mkStrOpt { };
      bgalt = mkStrOpt { };
      base0 = mkStrOpt { };
      base1 = mkStrOpt { };
      base2 = mkStrOpt { };
      base3 = mkStrOpt { };
      base4 = mkStrOpt { };
      base5 = mkStrOpt { };
      base6 = mkStrOpt { };
      base7 = mkStrOpt { };
      base8 = mkStrOpt { };
      fg = mkStrOpt { };
      fgalt = mkStrOpt { };
      grey = mkStrOpt { };
      red = mkStrOpt { };
      orange = mkStrOpt { };
      green = mkStrOpt { };
      teal = mkStrOpt { };
      yellow = mkStrOpt { };
      blue = mkStrOpt { };
      darkblue = mkStrOpt { };
      magenta = mkStrOpt { };
      violet = mkStrOpt { };
      cyan = mkStrOpt { };
      darkcyan = mkStrOpt { };
    };
  };

  config = {
    modules.shell.zsh.env.ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE =
      "fg=${cfg.colours.fg},bg=${cfg.colours.base4}";

    home.configFile."wallpaper".source =
      # Allow local overriding of wallpaper.
      let local = "${(getEnv "XDG_DATA_HOME")}/.wallpaper";
      in if pathExists local then local else cfg.wallpaper;
  };
}
