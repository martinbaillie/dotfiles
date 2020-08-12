{ pkgs, ... }: {
  my = {
    packages = with pkgs; [
      kubectl
      stable.kubectx
      # kubernetes-helm
      kustomize
    ];
    home.xdg.configFile."zsh/rc.d/rc.kubernetes.zsh".source =
      <config/kubernetes/rc.zsh>;
  };
}
