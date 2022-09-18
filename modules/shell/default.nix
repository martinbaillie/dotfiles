{ config, options, lib, pkgs, ... }:
with lib;
let cfg = config.modules.shell;
in
{
  options.modules.shell = { enable = my.mkBoolOpt false; };

  config = mkIf cfg.enable {
    # Miscellaneous userspace utilities I always want available on any platform.
    user.packages = with pkgs;
      [
        age
        bat
        bc
        bfs
        binutils
        coreutils
        curl
        diffutils
        dnsutils
        entr
        exa
        fd
        file
        findutils
        fzf
        fzy
        gawk
        gettext
        gnugrep
        gnumake
        gnuplot
        gnused
        graphviz
        gron
        htop
        ijq
        inetutils
        jq
        killall
        lsof
        ncdu
        nmap
        perl
        ripgrep
        screen
        sqlite
        stunnel
        tcpdump
        tmux
        tree
        unzip
        wget
        xar
        yq-go
        zip

        # unstable.wireshark

        (aspellWithDicts (d: with d; [ en en-computers en-science ]))
      ] ++ (if config.targetSystem.isLinux then
      # Exclusive to Linux.
        [
          psmisc
          kitty
        ] else
      # Exclusive to Darwin.
        [
          pstree
          unixtools.watch
        ]);

    # Miscellaneous aliases.
    modules.shell.zsh.aliases = {
      bc = "bc -lq";
      egrep = "egrep --color=auto";
      exa = "exa -h --group-directories-first --git";
      fgrep = "fgrep --color=auto";
      grep = "grep --color=auto";
      l = "exa -1a";
      ll = "exa -la";
      ls = "exa";
      lt = "exa -lm -s modified";
      mkdir = "mkdir -p";
      rg = "rg --hidden";
      tree = "tree -a -I '.git'";
      wget = "wget -c";
      tailf = "tail -f"; # util-linux habits.
    };

    # Shell fuzzer configuration.
    home.configFile = {
      "zsh/rc.d/rc.fzy.zsh".source = "${config.dotfiles.configDir}/fzy/rc.zsh";
      "zsh/rc.d/rc.fzf.zsh".source = "${config.dotfiles.configDir}/fzf/rc.zsh";
    };
  };
}
