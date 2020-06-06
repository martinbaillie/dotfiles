;; -*- no-byte-compile: t; -*-
;;; ~/.doom.d/packages.el

(package! dap-mode)
(package! nyan-mode)
;; (package! emojify)

(package! org-fancy-priorities)
(package! org-trello)
;; (package! fence-edit)
(package! edit-indirect)

(package! pinentry)
(package! deadgrep)
(package! ripgrep)

(package! move-text)
(package! buffer-move)
(package! buffer-expose)
(package! exec-path-from-shell)
(package! flycheck-golangci-lint)

(unpin! vterm)

(unpin! evil-easymotion)
(package! evil-easymotion :pin nil :recipe
  (:host github :repo "martinbaillie/evil-easymotion"))

(package! kubectx-mode :pin nil :recipe
  (:host github :repo "martinbaillie/emacs-kubectx-mode"))
