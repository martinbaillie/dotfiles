{ config, lib, pkgs, ... }:
let
  inherit (lib) mkMerge mkIf;
  inherit (lib.systems.elaborate { system = builtins.currentSystem; }) isLinux;
in mkMerge [
  {
    # NOTE: Fresh installs currently require the following imperative one-offs:
    # ssh-add $HOME/.ssh/id_rsa
    # ssh-add $HOME/.ssh/id_ed25519
    # gpg --import ~/.gnupg/gpg.asc
    # gpg --edit-key <id> RET trust RET 5
    # chown -R $(whoami) ~/.gnupg
    # find ~/.gnupg -type f -exec chmod 600 {} \;
    # find ~/.gnupg -type d -exec chmod 700 {} \;

    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    my = {
      packages = [ pkgs.gnupg ];
      home.home.file.".gnupg/gpg.asc".text = config.my.secrets.gpg;
      home.home.file.".gnupg/gpg-agent.conf".text = ''
        enable-ssh-support
        default-cache-ttl 86400
        default-cache-ttl-ssh 86400
        max-cache-ttl 86400
        max-cache-ttl-ssh 86400
        allow-emacs-pinentry
        allow-loopback-pinentry
      '';
    };
  }

  (mkIf isLinux {
    my = {
      packages = [ pkgs.pinentry ];
      home = {
        services.gpg-agent = {
          enable = true;
          sshKeys = config.my.secrets.ssh_keygrips;
          enableSshSupport = true;
        };
      };
    };

    #systemd.user.services.gpg-key-import = {
    #  description = "GnuPG key auto-import";
    #  wantedBy = [ "gpg-agent.service" ];
    #  after = [ "gpg-agent.service" ];
    #  serviceConfig = {
    #    Type = "oneshot";
    #    RemainAfterExit = true;
    #    ExecStart = "${pkgs.gnupg}/bin/gpg --import %h/.gnupg/gpg.asc";
    #  };
    #};
  })
]
