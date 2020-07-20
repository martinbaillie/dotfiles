{ config, pkgs, ... }: {
  my = {
    packages = with pkgs; [ git gitAndTools.hub gitAndTools.diff-so-fancy ];

    home.xdg.configFile = {
      "git/ignore".source = <config/git/ignore>;
      "git/config".text = builtins.readFile <config/git/config> + ''
        [url "git@${config.my.secrets.work_vcs_host}:${config.my.secrets.work_vcs_path}"]
            insteadOf = https://${config.my.secrets.work_vcs_host}/${config.my.secrets.work_vcs_path}
      '';
    };

    home.home.file."Code/work/.gitconfig".text = ''
      [user]
          email = ${config.my.secrets.work_email}
    '';

  };
}
