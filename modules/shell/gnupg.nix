{ config, options, lib, pkgs, ... }:
with lib;
let cfg = config.modules.shell.gnupg;
in {
  options.modules.shell.gnupg = with types; {
    enable = my.mkBoolOpt false;
    cacheTTL = my.mkOpt int 86400;
  };

  config = mkIf cfg.enable (mkMerge [
    {
      programs.gnupg.agent = {
        enable = true;
        enableSSHSupport = config.modules.shell.ssh.enable;
      };

      home.configFile = {
        "gnupg/gpg.asc".text = config.secrets.gpg;
        "gnupg/gpg-agent.conf".text = ''
          default-cache-ttl ${toString cfg.cacheTTL}
          default-cache-ttl ${toString cfg.cacheTTL}
          default-cache-ttl-ssh ${toString cfg.cacheTTL}
          max-cache-ttl ${toString cfg.cacheTTL}
          max-cache-ttl-ssh ${toString cfg.cacheTTL}
          allow-emacs-pinentry
          allow-loopback-pinentry
        '' + (if config.modules.shell.ssh.enable then ''
          enable-ssh-support
                    '' else
          "");
      };

      user.packages = with pkgs;
        [
          gnupg
          # TODO: Broken on aarch64
          # pinentry
        ];

      env.GNUPGHOME = "$XDG_CONFIG_HOME/gnupg";
    }

    (mkIf config.currentSystem.isLinux {
      home = {
        services.gpg-agent = {
          enable = true;
          enableSshSupport = true;
        };
      };

      # NOTE: Fresh installs currently require the following imperative one-offs:
      # gpg --import ~/.config/gnupg/gpg.asc
      # gpg --edit-key <id> RET trust RET 5
      # chown -R $(whoami) ~/.config/gnupg
      # find ~/.config/gnupg -type f -exec chmod 600 {} \;
      # chmod 700 ~/.config/gnupg
      # find ~/.config/gnupg -type d -exec chmod 700 {} \;
      #
      # ssh-add $HOME/.ssh/id_rsa
      # ssh-add $HOME/.ssh/id_ed25519
      #
      # NOTE: Broken, hence above.
      # systemd.user.services.gpg-key-import = {
      #   description = "GnuPG key auto-import";
      #   wantedBy = [ "gpg-agent.service" ];
      #   after = [ "gpg-agent.service" ];
      #   serviceConfig = {
      #     Type = "oneshot";
      #     RemainAfterExit = true;
      #     ExecStart = "${pkgs.gnupg}/bin/gpg --import %h/.gnupg/gpg.asc";
      #   };
      # };
    })
  ]);
}
