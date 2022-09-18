{ config, options, pkgs, lib, ... }:
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
            ZDOTDIR = "$XDG_CONFIG_HOME/zsh";
            ZSH_CACHE = "$XDG_CACHE_HOME/zsh";
            ZGEN_DIR = "$XDG_DATA_HOME/zsh";
            ZGEN_SRC = builtins.fetchGit {
              url = "https://github.com/jandamm/zgenom.git";
              rev = "6ff785d403dd3f0d3b739c9c2d3508f49003441f";
              ref = "main"; # zgenom@<2021-05-15 Sat>
            };

            # Try very hard to have things favour XDG convention.
            PATH = [ "$XDG_BIN_HOME" ];
            HISTFILE = "$XDG_DATA_HOME/zsh/history";
            INPUTRC = "$XDG_CONFIG_HOME/readline/inputrc";
            LESSHISTFILE = "$XDG_CACHE_HOME/lesshst";
            WGETRC = "$XDG_CONFIG_HOME/wgetrc";
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
