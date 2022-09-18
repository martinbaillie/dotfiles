{ pkgs, lib, inputs, ... }: {
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

  boot.loader.grub = {
    enable = true;
    version = 2;
    device = "/dev/sda";
  };

  networking = {
    hostName = "naptime";
    networkmanager.enable = true;
  };
}
