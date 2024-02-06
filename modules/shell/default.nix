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
        eza
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
        unstable.hwatch
        ijq
        inetutils
        jq
        (pkgs.writeShellScriptBin "jqMaybe"
          ''while IFS= read -r line
            do
            echo "$line" | jq -S '.' 2>/dev/null || echo "$line"
            done'')
        killall
        lsof
        unstable.mcfly
        unstable.mcfly-fzf
        ncdu
        nmap
        parallel
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
        xsv
        yq-go
        zip
        zstd

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
      eza = "eza -h --group-directories-first --git";
      fgrep = "fgrep --color=auto";
      grep = "grep --color=auto";
      l = "eza -1a";
      ll = "eza -la";
      ls = "eza";
      lt = "eza -lm -s modified";
      mkdir = "mkdir -p";
      rg = "rg --hidden";
      tree = "tree -a -I '.git'";
      wget = "wget -c";
      watch = "hwatch";
      tailf = "tail -f"; # util-linux habits.
    };

    # Shell fuzzer configuration.
    home.configFile = {
      "zsh/rc.d/rc.fzy.zsh".source = "${config.dotfiles.configDir}/fzy/rc.zsh";
      "zsh/rc.d/rc.fzf.zsh".source = "${config.dotfiles.configDir}/fzf/rc.zsh";
    };

    modules.shell.zsh.rc = ''
      eval "$(mcfly init zsh)"
      eval "$(mcfly-fzf init zsh)"
    '';
  };
}
