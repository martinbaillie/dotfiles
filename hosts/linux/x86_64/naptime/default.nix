{ pkgs, lib, inputs, ... }: {
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
