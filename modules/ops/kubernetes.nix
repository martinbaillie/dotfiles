{ pkgs, ... }: {
  my = {
    packages = with pkgs; [ kubectl kubernetes-helm kustomize kubectx ];
    home.xdg.configFile."zsh/rc.d/rc.kubernetes.zsh".source =
      <config/kubernetes/rc.zsh>;
  };
}
