{ config, options, pkgs, lib, inputs, ... }:
with lib;
let
  cfg = config.modules.shell.zsh;
  configDir = "${config.dotfiles.configDir}/zsh";
in
{
  options.modules.shell.zsh = with my;
    with types; {
      enable = mkBoolOpt false;

      # User-local aliases/rc/env.
      aliases = mkOpt (attrsOf types.str) { };
      env = mkOpt (attrsOf types.str) { };
      rc = mkOpt' types.lines "" "";
    };

  config = with pkgs;
    mkIf cfg.enable (mkMerge [
      {
        environment = {
          # Add zsh to the list of permissable login shells.
          shells = [ zsh ];
          # Ensure completion for system packages.
          pathsToLink = [ "/share/zsh" ];
        };

        # Handy completions for Nix.
        user.packages = [ nix-zsh-completions ];

        programs.zsh = {
          enable = true;
          enableCompletion = true;
          promptInit = "";
        };

        env =
          {
            # Global zsh releated environment values.
            ZDOTDIR = "${config.my.xdg.configHome}/zsh";
            ZSH_CACHE = "${config.my.xdg.cacheHome}/zsh";
            ZGEN_DIR = "${config.my.xdg.dataHome}/zsh";
            ZGEN_SRC = inputs.zgenom;

            # Try very hard to have things favour XDG convention.
            PATH = [ "${config.my.home.homeDirectory}/.local/bin" ];
            HISTFILE = "${config.my.xdg.dataHome}/zsh/history";
            INPUTRC = "${config.my.xdg.configHome}/readline/inputrc";
            LESSHISTFILE = "${config.my.xdg.cacheHome}/lesshst";
            WGETRC = "${config.my.xdg.configHome}/wgetrc";
          };

        home = {
          programs.nix-index = {
            # FIXME: Use unstable until aarch64-darwin makes it mainline.
            # enable = true;
            # package = pkgs.unstable.nix-index;
          };

          configFile = {
            # Link all externally declared zsh config recursively.
            "zsh" = {
              source = "${configDir}";
              recursive = true;
            };

            # Merge Nix aliases, rc and env attribute sets to be read by zsh.
            "zsh/rc.d/rc.zsh".text =
              let
                aliasLines =
                  mapAttrsToList (n: v: ''alias ${n}="${v}"'') cfg.aliases;
              in
              ''
                ${concatStringsSep "\n" aliasLines}
                ${cfg.rc}
              '';

            "zsh/rc.d/env.zsh".text =
              let
                envLines = mapAttrsToList (n: v: ''export ${n}="${v}"'') cfg.env;
              in
              ''
                ${concatStringsSep "\n" envLines}
              '';
          };
        };
      }
      (if stdenv.targetPlatform.isLinux then {
        # Linux specific.
        users.defaultUserShell = zsh;
        programs.zsh.enableGlobalCompInit = false;

        system.userActivationScripts.cleanupZWC = ''
          ${findutils}/bin/find \
            $ZDOTDIR -type f -name '*.zwc' -exec rm -f {} \;'';
      } else
        {
          # Darwin specific.
        })
    ]);
}
