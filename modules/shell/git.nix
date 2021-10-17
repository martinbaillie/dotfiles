{ config, options, lib, pkgs, ... }:
with lib;
let
  cfg = config.modules.shell.git;
  configDir = "${config.dotfiles.configDir}/git";
in {
  options.modules.shell.git = { enable = my.mkBoolOpt false; };

  config = mkIf cfg.enable {
    user.packages = with pkgs; [
      gitFull
      gh
      diff-so-fancy

      (mkIf config.modules.shell.gnupg.enable git-crypt)
    ];

    modules.shell.zsh.rc = "cdr() { cd $(git rev-parse --show-toplevel) }";

    home = {
      configFile = {
        "git/config".text = builtins.readFile "${configDir}/config" + ''
          # NOTE: This needs to be in the user config rather than work config
          # because $GOPATH is outside of the work dir.
          [url "git@${config.secrets.work_vcs_host}:${config.secrets.work_vcs_path}"]
              insteadOf = https://${config.secrets.work_vcs_host}/${config.secrets.work_vcs_path}
          [url "git@${config.secrets.work_vcs_host}:${config.secrets.work_vcs_path}/"]
              insteadOf = ${config.secrets.work_vcs_path}:
        '';
        "git/ignore".source = "${configDir}/ignore";
        "git/attributes".source = "${configDir}/attributes";
      };

      # Current $WORK specific helpers and directory-local user configuration.
      file."Code/work/.gitconfig".text = ''
        [user]
            email = ${config.secrets.work_email}
        [init]
            defaultBranch = master
      '';
    };
  };
}
