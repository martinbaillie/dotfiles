{ pkgs, ... }: {
  my = {
    packages = with pkgs; [ kubectl kubectx kubernetes-helm kustomize ];
    home.xdg.configFile."zsh/rc.d/aliases.kubernetes.zsh".source =
      <config/kubernetes/aliases.zsh>;
  };
}
