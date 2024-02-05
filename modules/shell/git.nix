{ config, options, lib, pkgs, ... }:
with lib;
let
  cfg = config.modules.shell.git;
  configDir = "${config.dotfiles.configDir}/git";
  rs-git-fsmonitor =
    if config.targetSystem.isDarwin then
      pkgs.rs-git-fsmonitor.overrideAttrs
        (_: {
          # Take control of TMPDIR to prevent annoying macOS launchd popups.
          fixupPhase = ''
            wrapProgram $out/bin/rs-git-fsmonitor \
            --set TMPDIR "/tmp" \
            --prefix PATH ":" "${lib.makeBinPath [ pkgs.watchman ]}" ;
          '';
        }) else pkgs.rs-git-fsmonitor;
in
{
  options.modules.shell.git = {
    enable = my.mkBoolOpt false;
    monorepo = my.mkBoolOpt true; # Optimise for large monorepos.
  };

  config = mkIf cfg.enable
    (mkMerge [
      (if (builtins.hasAttr "homebrew" options) then {
        user.packages = [ pkgs.unstable.gitFull ];
      } else {
        user.packages = [ pkgs.gitFull ];
      })
      {
        user.packages = with pkgs; [
          diff-so-fancy
          gh
          (mkIf config.modules.shell.gnupg.enable git-crypt)
        ] ++ optionals cfg.monorepo [
          git-lfs
          unstable.rs-git-fsmonitor
          watchman
        ];

        env.WATCHMAN_CONFIG_FILE = optional cfg.monorepo
          "${config.my.xdg.configHome}/watchman/watchman.json";

        modules.shell.zsh.rc = ''
          cdr() { cd $(git rev-parse --show-toplevel) }
          cdpr() { cd $PRJ_ROOT }
          gdbr() {
            git for-each-ref --format '%(refname:short)' refs/heads \
              | grep -v "master\|main" \
              | xargs git branch -D
          }
          gfu() {
            git fetch origin $1
            git branch $1 FETCH_HEAD
            git checkout $1
          }
          alias gcu=gfu
        '';

        home = {

          configFile = {
            "git/config".text = builtins.readFile "${configDir}/config" + ''
              # NOTE: This needs to be in the user config rather than work config
              # because $GOPATH is outside of the work dir.
              [url "git@${config.private.work_vcs_host}:${config.private.work_vcs_path}"]
                  insteadOf = https://${config.private.work_vcs_host}/${config.private.work_vcs_path}
              [url "git@${config.private.work_vcs_host}:${config.private.work_vcs_path}/"]
                  insteadOf = ${config.private.work_vcs_path}:
            '' + optionalString cfg.monorepo ''
              # Speed up git operations for large monorepos.
              # NOTE: Confirm with `watchman watch-list`.
              [core]
                  fsmonitor = ${rs-git-fsmonitor}/bin/rs-git-fsmonitor;
                  # Causes corruption:
                  # splitIndex = true
              [status]
                  aheadBehind = false
              [sparse]
                  expectFilesOutsideOfPatterns = true
              [feature]
                  manyFiles = true
            '';
            "git/ignore".source = "${configDir}/ignore";
            "git/attributes".source = "${configDir}/attributes";

          } // optionalAttrs cfg.monorepo {
            "watchman/watchman.json".text = builtins.toJSON ({
              root_restrict_files = [ ".git" ];
            });
          };

          # Current $WORK specific helpers and directory-local user configuration.
          file."work/.gitconfig".text = ''
            [user]
                email = ${config.private.work_email}
            [init]
                defaultBranch = master
          '' + optionalString cfg.monorepo ''
            [pack]
                # NOTE: run `git repack -ad`
                writeReverseIndex = true
          '';
        };
      }
    ]);
}
