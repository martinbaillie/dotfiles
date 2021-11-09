{ pkgs, lib, inputs, ... }: {
  imports = [ inputs.nixos-hardware.nixosModules.pcengines-apu ];

  ##############################################################
  # TEMP:
  users.users.root.password = lib.mkForce "nixos";
  services.openssh = {
    permitRootLogin = lib.mkForce "yes";
    passwordAuthentication = lib.mkForce true;
  };
  services.getty.autologinUser = lib.mkForce "root";
  ##############################################################

  modules = {
    editors = {
      vim.enable = true;

      default = "vim";
    };

    services = { ssh.enable = true; };

    shell = {
      enable = true;

      git.enable = true;
      gnupg.enable = true;
      ssh.enable = true;
      zsh.enable = true;
    };
  };

  boot = {
    loader.grub = {
      enable = true;
      version = 2;
      device = "/dev/sda";
    };

    kernel.sysctl = {
      # IP forwarding.
      "net.ipv6.conf.all.forwarding" = 1;
      "net.ipv4.conf.all.forwarding" = 1;
      "net.ipv4.ip_forward" = 1;

      # Disable netfilter for bridges.
      # NOTE: means bridge-routed frames do not go through iptables
      # https://bugzilla.redhat.com/show_bug.cgi?id=512206#c0
      "net.bridge.bridge-nf-call-ip6tables" = 0;
      "net.bridge.bridge-nf-call-iptables" = 0;
      "net.bridge.bridge-nf-call-arptables" = 0;
    };
  };

  networking = {
    # The global useDHCP flag is deprecated, therefore explicitly set to false
    # here. Per-interface useDHCP will be mandatory in the future, so this
    # generated config replicates the default behaviour.
    useDHCP = false;
    interfaces = {
      enp1s0.useDHCP = true;
      enp2s0.useDHCP = true;
      enp3s0.useDHCP = true;
    };
  };

}
