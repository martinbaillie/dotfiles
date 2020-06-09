;; -*- no-byte-compile: t; -*-
;;; ~/.doom.d/packages.el

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

(package! evil-motion-trainer :recipe
  (:host github :repo "martinbaillie/evil-motion-trainer"))
  ;; :recipe (:local-repo "/home/martin/Code/personal/evil-motion-trainer"
           ;; :files ("*.el")))

;; Use my fork of evil-easymotion.
(package! evil-easymotion :pin nil :recipe
  (:host github :repo "martinbaillie/evil-easymotion"))

;; Use my fork of kubectx-mode.
(package! kubectx-mode :recipe
  (:host github :repo "martinbaillie/emacs-kubectx-mode"))

;; Use bleeding edge vterm
(unpin! vterm)
