# Parasite - $WORK NixOS VM.
{ config, pkgs, lib, ... }: {
  imports = [
    ../../.

    <modules/desktop>

    <modules/dev>
    <modules/dev/go.nix>
    <modules/dev/javascript.nix>
    <modules/dev/python.nix>

    <modules/ops>
    <modules/ops/docker.nix>
    <modules/ops/kubernetes.nix>

    <modules/editors/emacs.nix>
    <modules/editors/vim.nix>

    <modules/term>
    <modules/term/direnv.nix>
    <modules/term/git.nix>
    <modules/term/gnupg.nix>
    <modules/term/ssh.nix>
    <modules/term/zsh.nix>

    <modules/web/chrome.nix>
    <modules/web/dropbox.nix>
    <modules/web/firefox.nix>
    <modules/web/slack.nix>
  ];

  # Machine identity.
  networking.hostName = "parasite";

  # Parasite only gets half of what its host has.
  nix = {
    maxJobs = 2;
    buildCores = 2;
  };

  # Enable VMWare's guest additions.
  virtualisation.vmware.guest.enable = true;

  # Virtualisation fixes.
  boot = {
    initrd = {
      # Remove fsck check from startup.
      checkJournalingFS = false;
    };

    # Kernel tuning for virtualisation.
    kernelParams = [ "mitigations=off" ];
  };

  # We'll let the host handle this.
  powerManagement.enable = false;

  # Replace ntpd by timesyncd for more accurate virtualisation alignment.
  services.timesyncd.enable = true;

  # Keyboard.
  services.xserver.xkbOptions = "terminate:ctrl_alt_bksp";

  my = {
    # User.
    username = config.my.secrets.work_username;
    email = config.my.secrets.work_email;

    # Display.
    hidpi = true;

    home.xsession = {
      # pointerCursor = {
      #   name = "Vanilla-DMZ";
      #   package = pkgs.vanilla-dmz;
      #   #   size = 32 * scale;
      # };
    };

    home.services.polybar.config = {
      "bar/top" = {
        # dpi = 170;
        # height = 40;
        # offset-y = 8;
        height = 23;
        offset-y = 5;
      };
      "module/battery" = {
        adapter = "ACAD";
        battery = "BAT1";
      };
    };
  };

  # Shares with the host.
  fileSystems."/shared" = {
    device = ".host:/shared";
    fsType = "fuse./run/current-system/sw/bin/vmhgfs-fuse";
    options = [ "nofail,allow_other" ];
  };

  # NOTE: To allow parasite to be used as a router from the host.
  # host $ route add 0.0.0.0/1 172.16.16.16
  # host $ route add 128.0.0.0/1 172.16.16.16
  # networking.wg-quick.interfaces = {
  #   wg0 = {
  #     address = [ "10.0.1.2/24" ];
  #     dns = [ "10.0.1.1" ];
  #     privateKey = "${config.my.secrets.zuul_client_private_key}";
  #     peers = [{
  #       publicKey = "${config.my.secrets.zuul_server_public_key}";
  #       allowedIPs = [ "0.0.0.0/0" ];
  #       endpoint =
  #         "${config.my.secrets.zuul_server_host}:${config.my.secrets.zuul_server_port}";
  #       persistentKeepalive = 25;
  #     }];
  #   };
  # };
}
