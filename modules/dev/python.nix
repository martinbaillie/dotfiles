{ pkgs, lib, ... }:
let
  inherit (lib) mkIf;
  inherit (lib.systems.elaborate { system = builtins.currentSystem; }) isLinux;
in {
  my = {
    packages = with pkgs; [
      # (jupyter.override {
      #   definitions = {
      #     python3 = let
      #       env = (pkgs.python37.withPackages
      #         (ps: with ps; [ ipykernel ipython matplotlib pandas numpy ]));
      #     in {
      #       displayName = "Python 3";
      #       argv = [
      #         "${env.interpreter}"
      #         "-m"
      #         "ipykernel_launcher"
      #         "-f"
      #         "{connection_file}"
      #       ];
      #       language = "python";
      #       logo32 = "${env.sitePackages}/ipykernel/resources/logo-32x32.png";
      #       logo64 = "${env.sitePackages}/ipykernel/resources/logo-64x64.png";
      #     };
      #   };
      # })
      (python37.withPackages (ps: with ps; [ black pip pylint setuptools ]))
      (mkIf isLinux (unstable.python-language-server))
      # REVIEW: Language server is currently bust on Darwin.
      # (if isDarwin then
      #   # python37Packages.python-language-server
      # else
      #   unstable.python-language-server)
    ];

    env.IPYTHONDIR = "$XDG_CONFIG_HOME/ipython";
    env.PIP_CONFIG_FILE = "$XDG_CONFIG_HOME/pip/pip.conf";
    env.PIP_LOG_FILE = "$XDG_DATA_HOME/pip/log";
    env.PYLINTHOME = "$XDG_DATA_HOME/pylint";
    env.PYLINTRC = "$XDG_CONFIG_HOME/pylint/pylintrc";
    env.PYTHONSTARTUP = "$XDG_CONFIG_HOME/python/pythonrc";
    env.PYTHON_EGG_CACHE = "$XDG_CACHE_HOME/python-eggs";
    env.JUPYTER_CONFIG_DIR = "$XDG_CONFIG_HOME/jupyter";
  };
}
