{ config, options, lib, pkgs, ... }:
with lib;
let
  cfg = config.modules.shell.git;
  configDir = "${config.dotfiles.configDir}/git";
in
{
  options.modules.shell.git = { enable = my.mkBoolOpt false; };

  config = mkIf cfg.enable
    (mkMerge [
      (if (builtins.hasAttr "homebrew" options) then {
        homebrew = {
          taps = [ "microsoft/git" ];
          casks = [
            # Microsoft Git deps are broken.
            "microsoft-git"
          ];
        };
      } else {
        user.packages = [ pkgs.gitFull ];
      })
      {
        user.packages = with pkgs; [
          diff-so-fancy
          gh
          git-lfs
          rs-git-fsmonitor
          watchman

          (mkIf config.modules.shell.gnupg.enable git-crypt)
        ];

        env.WATCHMAN_CONFIG_FILE = "$XDG_CONFIG_HOME/watchman/watchman.json";

        modules.shell.zsh.rc = "cdr() { cd $(git rev-parse --show-toplevel) }";

        home = {
          configFile = {
            "git/config".text = builtins.readFile "${configDir}/config" + ''
              # Speed up git operations for large monorepos.
              # NOTE: Confirm with `watchman watch-list`.
              [core]
                  fsmonitor = ${pkgs.rs-git-fsmonitor}/bin/rs-git-fsmonitor;
              # NOTE: This needs to be in the user config rather than work config
              # because $GOPATH is outside of the work dir.
              [url "git@${config.secrets.work_vcs_host}:${config.secrets.work_vcs_path}"]
                  insteadOf = https://${config.secrets.work_vcs_host}/${config.secrets.work_vcs_path}
              [url "git@${config.secrets.work_vcs_host}:${config.secrets.work_vcs_path}/"]
                  insteadOf = ${config.secrets.work_vcs_path}:
            '';
            "git/ignore".source = "${configDir}/ignore";
            "git/attributes".source = "${configDir}/attributes";

            # Here we tell watchman to only watch directory hierarchies that have a
            # `.watchmanconfig` file at their root.
            "watchman/watchman.json".text = builtins.toJSON ({
              enforce_root_files = true;
              root_files = [ ".watchmanconfig" ];
            });
          };

          # Current $WORK specific helpers and directory-local user configuration.
          file."work/.gitconfig".text = ''
            [user]
                email = ${config.secrets.work_email}
            [init]
                defaultBranch = master
            [pack]
                # NOTE: run `git repack -Ad`
                writeReverseIndex = true
          '';
        };
      }
    ]);
}
