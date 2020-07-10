;; -*- no-byte-compile: t; -*-
;;; ~/.doom.d/packages.el

;; Custom packages.
(package! dap-mode)
(package! nyan-mode)
(package! org-fancy-priorities)
(package! org-trello)
(package! edit-indirect)
(package! pinentry)
(package! deadgrep)
(package! ripgrep)
(package! move-text)
(package! buffer-move)
(package! buffer-expose)
(package! exec-path-from-shell)
(package! flycheck-golangci-lint)

;; My packages.
(package! evil-motion-trainer :recipe
  (:host github :repo "martinbaillie/evil-motion-trainer"))
(package! evil-easymotion :pin "e6051245c06354ccd4a57e054cdff80a34f18376" :recipe
  (:host github :repo "martinbaillie/evil-easymotion"))
(package! kubectx-mode :recipe
  (:host github :repo "martinbaillie/emacs-kubectx-mode"))
