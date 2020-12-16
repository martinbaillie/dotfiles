# Parasite - $WORK NixOS VM.
{ config, pkgs, lib, ... }: {
  imports = [
    ../../.

    <modules/desktop>

    <modules/dev>
    <modules/dev/go.nix>

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
    kernelParams = [ "mitigations=off" "transparent_hugepage=never" ];
  };

  # Replace ntpd by timesyncd for more accurate virtualisation alignment.
  services.timesyncd.enable = true;

  # HiDPI (Retina) fixes in early boot.
  hardware.video.hidpi.enable = true;

  my = {
    username = config.my.secrets.work_username;
    email = config.my.secrets.work_email;

    home.xsession = {
      # pointerCursor = {
      #   name = "Vanilla-DMZ";
      #   package = pkgs.vanilla-dmz;
      #   size = 32 * scale;
      # };
    };
  };

  # NOTE: To allow parasite to be used as a router from the host.
  # host $ route add 0.0.0.0/1 172.16.16.16
  # host $ route add 128.0.0.0/1 172.16.16.16
  networking.wg-quick.interfaces = {
    wg0 = {
      address = [ "10.0.1.2/24" ];
      dns = [ "10.0.1.1" ];
      privateKey = "${config.my.secrets.zuul_client_private_key}";
      peers = [{
        publicKey = "${config.my.secrets.zuul_server_public_key}";
        allowedIPs = [ "0.0.0.0/0" ];
        # TODO: Document change on fly.
        # endpoint = "115.70.50.240:31339";
        endpoint =
          "${config.my.secrets.zuul_server_host}:${config.my.secrets.zuul_server_port}";
        persistentKeepalive = 25;
      }];
    };
  };
}
