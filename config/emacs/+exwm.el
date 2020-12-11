;;; +exwm.el -*- lexical-binding: t; -*-

;; Runs after EXWM initialises.
(defun mb/exwm-init ()
  ;; Start at workspace 1.
  ;; (exwm-workspace-switch-create 1)
  )

;; External monitor handling
(defun mb/screen-switch ()
  (let ((xrandr-output-regexp "\n\\([^ ]+\\) connected primary \\([[:digit:]]*x[[:digit:]]*\\)")
        default-output)
    (with-temp-buffer
      (call-process "xrandr" nil t nil)
      (goto-char (point-min))
      (re-search-forward xrandr-output-regexp nil 'noerror)
      (setq default-output (match-string 1))
      (setq resolution (match-string 2))
      (forward-line)
      (call-process
       "xrandr" nil nil nil
       "--output" default-output
       "--auto")
      (if (string= resolution "2880x1800") ;; MacBook Retina.
          (write-region "Xft.dpi: 192\n" nil "~/.Xresources")
        (delete-file "~/.Xresources"))
      (setq exwm-randr-workspace-monitor-plist
            (list 0 (match-string 1))))))

(defun mb/setup-window-by-class ()
  (interactive)
  (pcase exwm-class-name
    ;; Disabled as trialing a single workspace.
    ;; ("Firefox" (exwm-workspace-move-window 2))
    ;; ("Slack" (exwm-workspace-move-window 3))
    ))

;; Ensure `exwm' windows can be restored when switching workspaces.
(defun mb/exwm-update-utf8-title (oldfun id &optional force)
  "Only update the window title when the buffer is visible."
  (when (get-buffer-window (exwm--id->buffer id))
    (funcall oldfun id force)))

;; Buffer popping functions.
(defun mb/switch-to-last-buffer ()
  "Switch to last open buffer in current window."
  (interactive)
  (switch-to-buffer (other-buffer (current-buffer) 1)))

(defun mb/buffer-with-suffix (suffix)
  "Locates the buffer matching the suffix"
  (cl-find-if (lambda (buffer)
                (string-suffix-p suffix (buffer-name buffer))) (buffer-list)))

(defun mb/split-with-browser ()
  "Raises the browser side-by-side with current window"
  (interactive)
  (delete-other-windows)
  (set-window-buffer (split-window-horizontally) (mb/buffer-with-suffix "Firefox")))

(defun mb/raise-or-run (suffix &optional cmd)
  "Raises the buffer with SUFFIX otherwise runs the CMD (if provided) or SUFFIX"
  (let ((existing-buffer
         (mb/buffer-with-suffix suffix)))
    (if existing-buffer
        (if (string= (buffer-name (current-buffer)) (buffer-name existing-buffer))
            (bury-buffer)
          (if (get-buffer-window existing-buffer)
              (pop-to-buffer existing-buffer)
            (exwm-workspace-switch-to-buffer existing-buffer)))
      (start-process-shell-command suffix nil cmd))))

;; Configure `exwm' the X window manager for Emacs.
(use-package! exwm
  :init
  (setq
   ;; Follow the mouse.
   focus-follows-mouse t
   ;; Move the focus to the followed window.
   mouse-autoselect-window t
   ;; Warp the cursor automatically after workspace switches.
   exwm-workspace-warp-cursor t
   ;; Start with a single workspace.
   exwm-workspace-number 1
   ;; But show buffers on other workspaces.
   exwm-workspace-show-all-buffers t
   ;; And allow switching to buffers on other workspaces.
   exwm-layout-show-all-buffers t)
  :config
  ;; Hooks.
  ;;
  ;; Do some extra configuration after EXWM starts.
  (add-hook 'exwm-init-hook #'mb/exwm-init)

  ;; Fix buffer names.
  (add-hook 'exwm-update-class-hook
            (lambda ()
              (exwm-workspace-rename-buffer exwm-class-name)))

  ;; Use the page title in the case of Firefox.
  (add-hook 'exwm-update-title-hook
            (lambda ()
              (pcase exwm-class-name
                ("Firefox" (exwm-workspace-rename-buffer
                            (format "%s" exwm-title))))))

  ;; Manipulate windows as they're created
  (add-hook 'exwm-manage-finish-hook
            (lambda ()
              ;; Send the window where it belongs.
              (mb/setup-window-by-class)

              ;; Hide the modeline on all X windows.
              ;; (exwm-layout-hide-mode-line)))

              ;; (setq-local hide-mode-line-format '("> %b"))
              ;; (hide-mode-line-mode)
              ;;               ;; No nyaning in X org.
              ;; (setq-local nyan-mode nil))
              ))

  ;; Hide the modeline just on floating X windows.
  (add-hook 'exwm-floating-setup-hook #'exwm-layout-hide-mode-line)
  (add-hook 'exwm-floating-exit-hook #'exwm-layout-show-mode-line)

  ;; Show `exwm' buffers in buffer switching prompts.
  (add-hook 'exwm-mode-hook #'doom-mark-buffer-as-real-h)

  ;; Make C-u evil again.
  (add-hook 'exwm-mode-hook
            (lambda ()
              (evil-local-set-key 'motion (kbd "C-u") nil)))

  ;; Restore window configurations involving EXWM buffers by only changing names
  ;; of visible buffers. This fixes Pesp+EXWM.
  (advice-add #'exwm--update-utf8-title :around #'mb/exwm-update-utf8-title)

  ;;
  ;; Keys.
  ;;
  ;; These keys should always pass through to Emacs when in line mode.
  (setq exwm-input-prefix-keys
        '(?\C-x
          ?\C-u
          ?\C-h
          ?\C-w
          ?\C-\;
          ?\M-x
          ?\M-`
          ?\M-&
          ?\M-:
          ?\s-,
          ?\s-.
          ?\s-;
          ?\s-x
          ?\C-\ ))  ;; Ctrl-space

  ;; Ctrl+Q will enable the next key to be sent directly.
  (define-key exwm-mode-map [?\C-q] 'exwm-input-send-next-key)

  ;; Configure global key bindings.
  (setq exwm-input-global-keys
        `(([?\s-i] . exwm-input-toggle-keyboard)
          ([?\s-F] . exwm-layout-toggle-fullscreen)
          ([?\s-$] . (lambda (command)
                       (interactive (list (read-shell-command "$ ")))
                       (start-process-shell-command command nil command)))
          ;; ([?\s-`] . (lambda () (interactive) (exwm-workspace-switch-create 0)))
          ;; ([?\s-/] . exwm-workspace-switch)
          ;; ,@(mapcar (lambda (i)
          ;;             `(,(kbd (format "s-%d" i)) .
          ;;               (lambda ()
          ;;                 (interactive)
          ;;                 (exwm-workspace-switch-create ,i))))
          ;;           (number-sequence 0 9))
          ))

  ;; Configure line-mode simulation key bindings.
  (setq exwm-input-simulation-keys
        `( ;; Add some macOSisms for compatability when in a macOS hosted VM.
          (,(kbd "s-c") . ,(kbd "C-c"))
          (,(kbd "s-f") . ,(kbd "C-f"))
          (,(kbd "s-k") . ,(kbd "C-k"))
          (,(kbd "s-l") . ,(kbd "C-l"))
          (,(kbd "s-P") . ,(kbd "C-P"))
          (,(kbd "s-t") . ,(kbd "C-t"))
          (,(kbd "s-T") . ,(kbd "C-T"))
          (,(kbd "s-w") . ,(kbd "C-w"))
          (,(kbd "s-v") . ,(kbd "C-v"))
          (,(kbd "C-x") . ,(kbd "C-x"))
          (,(kbd "s-<backspace>") . ,(kbd "C-<backspace>"))
          (,(kbd "M-<left>") . ,(kbd "C-<left>"))
          (,(kbd "M-<right>") . ,(kbd "C-<right>"))
          (,(kbd "s-<left>") . ,(kbd "C-<left>"))
          (,(kbd "s-<right>") . ,(kbd "C-<right>"))
          ;; TODO: Below not working:
          (,(kbd "<s-mouse-1>") . ,(kbd "<C-mouse-1>"))))

  ;; Set local simulation keys for Firefox.
  (add-hook 'exwm-manage-finish-hook
            (lambda ()
              (when (and exwm-class-name
                         (string= exwm-class-name "Firefox"))
                (exwm-input-set-local-simulation-keys
                 `(,@exwm-input-simulation-keys
                   ;; Allow double Emacs double C-c|w chord to send a C-c|w.
                   ([?\C-c ?\C-c] . ?\C-c)
                   ([?\C-w ?\C-w] . ?\C-w))))))

  ;; Make Doom's leader work.
  (exwm-input-set-key (kbd doom-leader-alt-key) doom-leader-map)

  ;; Rofi-styled launcher.
  (setq counsel-linux-app-format-function ;; Make the launcher list pretty.
        #'counsel-linux-app-format-function-name-pretty)
  (exwm-input-set-key (kbd "s-SPC") #'counsel-linux-app)

  ;; Familiar macOS close behaviour.
  (exwm-input-set-key (kbd "s-q") #'kill-current-buffer)

  ;; Familiar macOS tabbing behaviour.
  (exwm-input-set-key (kbd "s-<tab>") #'mb/switch-to-last-buffer)

  ;; Change orientation of frames.
  (exwm-input-set-key (kbd "S-s-SPC") #'transpose-frame)

  ;; Pop to Firefox.
  (exwm-input-set-key (kbd "s-<return>")
                      (lambda () (interactive) (mb/raise-or-run "Firefox" "firefox")))
  (exwm-input-set-key (kbd "S-s-<return>")
                      (lambda () (interactive) (mb/split-with-browser)))

  ;; TODO: WIP vital stats function.
  (exwm-input-set-key (kbd "s-?")
                      (lambda () (interactive)
                        (message "%s %s"
                                 (concat (format-time-string "%Y-%m-%d %T (%a w%W)"))
                                 (battery-format "| %L: %p%% (%t)"
                                                 (funcall battery-status-function)))))

  ;; Allow resizing with mouse, of non-floating windows.
  (setq window-divider-default-bottom-width 2
        window-divider-default-right-width 2)
  (window-divider-mode)

  ;; Configure a rudimentary status bar at least for now.
  (setq display-time-default-load-average nil)
  (display-time-mode +1)
  (display-battery-mode +1)

  ;; TODO: Emacs desktop management for non-VM based NixOS.
  ;; TODO: Emacs notification mode? https://github.com/sinic/ednc

  ;; Use EXWM randr for setting external monitors correctly.
  (require 'exwm-randr)
  (add-hook 'exwm-randr-screen-change-hook #'mb/screen-switch)
  (exwm-randr-enable)

  ;; Enable the window manager.
  (exwm-enable))

;; Use the `ido' configuration for a few configuration fixes that alter
;; 'C-x b' worksplace switching behaviour. This also affects the functionality
;; of 'SPC .' file searching in doom regardless of the users `ido' configuration.
(use-package! exwm-config
  :after (exwm)
  :config
  (exwm-config--fix/ido-buffer-window-other-frame))

;; Configure `exwm-edit' to allow editing Firefox/Slack/etc. input fields in
;; Emacs buffers.
(use-package! exwm-edit
  :after (exwm)
  :init
  ;; Seems to fix things for my slow macOS-hosted NixOS VM.
  (setq exwm-edit-clean-kill-ring-delay 0.5)
  ;; Pop the edit buffer below.
  (set-popup-rule! "^\\*exwm-edit"
    :side 'bottom :size 0.2
    :select t :quit nil :ttl t)
  :config
  (defalias 'exwm-edit--display-buffer 'pop-to-buffer)
  ;; Use GFM mode in the buffers
  (add-hook 'exwm-edit-compose-hook (lambda () (funcall 'gfm-mode))))

;; And give EXWM buffers an icon.
(use-package! all-the-icons
  :ensure t
  :config
  (add-to-list 'all-the-icons-mode-icon-alist
               '(exwm-mode all-the-icons-faicon "desktop"
                           :height 1.0 :face all-the-icons-purple)))
