{ pkgs, ... }: {
  my = {
    packages = with pkgs; [
      kubectl
      kubectx
      # kubernetes-helm
      kustomize
    ];
    home.xdg.configFile."zsh/rc.d/rc.kubernetes.zsh".source =
      <config/kubernetes/rc.zsh>;
  };
}
