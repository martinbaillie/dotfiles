;;; +exwm.el -*- lexical-binding: t; -*-

(defun mb/set-wallpaper ()
  (interactive)
  (start-process-shell-command
   "feh" nil  "feh --bg-fill ~/.config/wallpaper"))

(setq mb/panel-process nil)

(defun mb/kill-panel ()
  (interactive)
  (when mb/panel-process
    (ignore-errors
      (kill-process mb/panel-process)))
  (setq mb/panel-process nil))

(defun mb/start-panel ()
  (interactive)
  (mb/kill-panel)
  (setq mb/panel-process
        (start-process-shell-command "polybar" nil "polybar top")))

;; Runs after EXWM initialises.
(defun mb/exwm-init ()
  ;; Start at workspace 1.
  ;; (exwm-workspace-switch-create 1)

  ;; Start the panel.
  (mb/start-panel)

  ;; Set a wallpaper.
  (run-at-time "1 sec" nil (lambda () (mb/set-wallpaper))))

;; External monitor handling.
(defun mb/screen-switch ()
  (interactive)
  (when-let ;; Persist a system DPI if configured.
      (dpi (alist-get 'desktop/dpi mb/system-settings))
    (write-region (format "Xft.dpi: %s\n" dpi) nil "~/.Xresources"))
  (let ((xrandr-output-regexp "\n\\([^ ]+\\) connected ")
        (xrandr-resolution-regexp "\n*connected.* \\([[:digit:]]+x[[:digit:]]+\\)")
        default-output
        default-resolution)
    (with-temp-buffer
      (call-process "xrandr" nil t nil)
      (goto-char (point-min))
      (re-search-forward xrandr-resolution-regexp nil 'noerror)
      (setq default-resolution (match-string 1))
      (goto-char (point-min))
      (re-search-forward xrandr-output-regexp nil 'noerror)
      (setq default-output (match-string 1))
      (forward-line)
      (if (not (re-search-forward xrandr-output-regexp nil 'noerror))
          ;; We have just a primary display. First check for a special case of a
          ;; HiDPI screen like my Macbook's retina, and double the DPI if so.
          (progn (when (and (alist-get 'desktop/hidpi mb/system-settings)
                            (string= default-resolution "2880x1800")) ;; Retina.
                   (write-region "Xft.dpi: 192\n" nil "~/.Xresources"))
                 ;; Finally setup the display.
                 (call-process "xrandr" nil nil nil "--auto"))
        ;; There's a secondary display. Use it as primary and turn off the
        ;; default output (making the presumption that it is a laptop display).
        (call-process "xrandr" nil nil nil
                      "--output" (match-string 1) "--primary" "--auto"
                      "--output" default-output "--off")
        (setq exwm-randr-workspace-monitor-plist
              (list 0 (match-string 1)))))))

(defun mb/setup-window-by-class ()
  (interactive))
;; (pcase exwm-class-name
;;   ("ROOT" (exwm-floating-toggle-floating))))
;; Disabled as trialing a single workspace.
;; ("Firefox"(exwm-workspace-move-window 2))
;; ("Slack" (exwm-workspace-move-window 3))

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
  "Locates the buffer matching the suffix."
  (cl-find-if (lambda (buffer)
                (string-suffix-p suffix (buffer-name buffer))) (buffer-list)))

(defun mb/split-with-browser ()
  "Raises the browser side-by-side with current window."
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



;; Configure EXWM.
(use-package! exwm
  :init
  (setq
   ;; Use the primary clipboard.
   select-enable-primary t
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
                ("firefox" (progn
                             (exwm-workspace-rename-buffer (format "%s" exwm-title))
                             (mb/update-polybar-exwm))))))

  ;; Manipulate windows as they're created.
  (add-hook 'exwm-manage-finish-hook
            (lambda ()
              ;; Configure per-class.
              (mb/setup-window-by-class)

              ;; Switch to the EXWM modeline format.
              ;; (setq-local hide-mode-line-format (doom-modeline-format--exwm))
              (exwm-layout-hide-mode-line)))

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
        `,@(mapcar (lambda (vector) (aref vector 0))
                   `(,@(mapcar (lambda (i) (kbd (format "s-%s" i)))
                               (number-sequence 0 9)) ;; Pass s-[0-9] through.
                     ,(kbd "C-h")
                     ,(kbd "C-w")
                     ,(kbd "C-g")
                     ,(kbd "C-SPC")
                     ,(kbd "M-x")
                     ,(kbd "M-`")
                     ,(kbd "M-&")
                     ,(kbd "M-:")
                     ,(kbd "s-,")
                     ,(kbd "s-$")
                     ,(kbd "s-.")
                     ,(kbd "s-;")
                     ,(kbd "s-/")
                     ,(kbd "s-g"))))

  ;; Ctrl+Q will enable the next key to be sent directly.
  (define-key exwm-mode-map [?\C-q] 'exwm-input-send-next-key)

  ;; Configure global key bindings.
  (setq exwm-input-global-keys
        `(([?\s-i] . exwm-input-toggle-keyboard)
          ([?\s-F] . exwm-layout-toggle-fullscreen)
          ([?\s-$] . (lambda (command)
                       (interactive (list (read-shell-command "$ ")))
                       (start-process-shell-command command nil command)))))
  ;; ([?\s-`] . (lambda () (interactive) (exwm-workspace-switch-create 0)))
  ;; ([?\s-/] . exwm-workspace-switch)

  ;; Configure line-mode simulation key bindings.
  (setq exwm-input-simulation-keys
        `(;; Add some macOSisms for compatability when in a macOS hosted VM.
          (,(kbd "s-a") . ,(kbd "C-a"))
          (,(kbd "s-c") . ,(kbd "C-c"))
          (,(kbd "s-f") . ,(kbd "C-f"))
          (,(kbd "s-k") . ,(kbd "C-k"))
          (,(kbd "s-l") . ,(kbd "C-l"))
          (,(kbd "s-P") . ,(kbd "C-P"))
          (,(kbd "s-t") . ,(kbd "C-t"))
          (,(kbd "s-T") . ,(kbd "C-T"))
          (,(kbd "s-v") . ,(kbd "C-v"))
          (,(kbd "s-w") . ,(kbd "C-w"))
          (,(kbd "s-x") . ,(kbd "C-x"))
          (,(kbd "s-N") . ,(kbd "C-N"))
          (,(kbd "s-P") . ,(kbd "C-P"))
          (,(kbd "s-<backspace>") . ,(kbd "C-<backspace>"))
          (,(kbd "M-<left>") . ,(kbd "C-<left>"))
          (,(kbd "M-<right>") . ,(kbd "C-<right>"))
          (,(kbd "s-<left>") . ,(kbd "C-<left>"))
          (,(kbd "s-<right>") . ,(kbd "C-<right>"))))

  ;; Set local simulation keys for Firefox.
  (add-hook 'exwm-manage-finish-hook
            (lambda ()
              (when (and exwm-class-name
                         (string= exwm-class-name "firefox"))
                (exwm-input-set-local-simulation-keys
                 `(,@exwm-input-simulation-keys
                   ;; Allow Emacs double C-c|w chord to send a C-c|w in Firefox.
                   ([?\C-c ?\C-c] . ?\C-c)
                   ([?\C-w ?\C-w] . ?\C-w))))))

  ;; Make Doom's leader work.
  (exwm-input-set-key (kbd doom-leader-alt-key) doom-leader-map)

  ;; Bind a default XRandr toggle for jigging displays.
  (exwm-input-set-key (kbd "<XF86Display>")
                      (lambda () (interactive) (start-process-shell-command
                                                "xrandr" nil  "xrandr --auto")))

  ;; Rofi-styled launcher.
  ;; (setq counsel-linux-app-format-function ;; Make the launcher list pretty.
  ;;       #'counsel-linux-app-format-function-name-pretty)
  ;; (exwm-input-set-key (kbd "s-SPC") #'counsel-linux-app)
  (exwm-input-set-key (kbd "s-SPC") #'app-launcher-run-app)

  ;; Try to fix C-click.
  ;; (exwm-input-set-key (kbd "<s-mouse-1>") #'fake-C-down-mouse-1)

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

  ;; Allow resizing with mouse, of non-floating windows.
  (setq window-divider-default-bottom-width 2
        window-divider-default-right-width 2)
  (window-divider-mode)

  ;; Emacs desktop management for non-VM based NixOS.
  (require 'desktop-environment)
  (desktop-environment-mode)
  (setq desktop-environment-brightness-set-command "light %s")
  (setq desktop-environment-brightness-normal-decrement "-U 10")
  (setq desktop-environment-brightness-small-decrement "-U 5")
  (setq desktop-environment-brightness-normal-increment "-A 10")
  (setq desktop-environment-brightness-small-increment "-A 5")
  (setq desktop-environment-brightness-get-command "light")
  (setq desktop-environment-brightness-get-regexp "\\([0-9]+\\)\\.[0-9]+")
  (setq desktop-environment-screenlock-command "loginctl lock-session")
  (setq desktop-environment-screenshot-command "flameshot gui")

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
  ;; Use GFM mode in the edit buffers.
  (add-hook 'exwm-edit-compose-hook (lambda () (funcall 'gfm-mode))))

;; Give EXWM buffers an icon.
(use-package! all-the-icons
  :config
  (add-to-list 'all-the-icons-mode-icon-alist
               '(exwm-mode all-the-icons-faicon "desktop"
                           :height 1.0 :face all-the-icons-purple)))
;; TODO: How to set an icon for an EXWM window?
;; '(exwm-mode all-the-icons-faicon "firefox"
;;             :v-adjust -0.1 :height 1.0 :face
;;             '(:foreground "#E66000"))

(defun my-dpi ()
  (let* ((attrs (car (display-monitor-attributes-list)))
         (size (assoc 'mm-size attrs))
         (sizex (cadr size))
         (res (cdr (assoc 'geometry attrs)))
         (resx (- (caddr res) (car res))))
    (catch 'exit
      ;; in terminal
      (unless sizex
        (throw 'exit 10))
      ;; on big screen
      (when (> sizex 1000)
        (throw 'exit 10))
      ;; DPI
      (* (/ (float resx) sizex) 25.4))))

(defun my-preferred-font-size ()
  (let ( (dpi (my-dpi)) )
    (cond
     ((< dpi 110) 10)
     ((< dpi 130) 11)
     ((< dpi 160) 12)
     (t 12))))

;;; Polybar
(defun mb/send-polybar-hook (name number)
  (start-process-shell-command "polybar-msg" nil
                               (format "polybar-msg hook %s %s" name number)))

(defun mb/update-polybar-exwm (&rest _)
  (mb/send-polybar-hook "exwm" 1)
  (mb/send-polybar-hook "exwm-title" 1))

(defun mb/polybar-exwm-workspace ()
  (let ((names (+workspace-list-names))
        (current-name (+workspace-current-name)))
    (car (cl-loop for name in names
                  for i to (length names)
                  when (equal name current-name) collect
                  (format "[%d] %s" (1+ i) name)))))

(defun mb/exwm-buffer-list ()
  (cl-remove-if-not
   (lambda (buffer)
     (eq (buffer-local-value 'major-mode buffer) 'exwm-mode))
     (buffer-list)))

;; (pcase exwm-workspace-current-index
;;   (0 "(╯°□°)╯︵ ┻━┻")
;;   (1 "┬─┬﻿ノ(゜-゜ノ)")
;;   (2 "(._.) ~ ︵ ┻━┻")
;;   (3 "(ﾉಥ益ಥ）ﾉ﻿ ┻━┻")))

(defun mb/polybar-exwm-title ()
  (with-selected-frame (selected-frame)
    (with-current-buffer (window-buffer (selected-window))
      (format "%s %s"
              (substring-no-properties (all-the-icons-icon-for-buffer))
              (buffer-name)))))

;; Ensure polybar gets the latest information from buffer and frame movements.
(add-hook! 'exwm-workspace-switch-hook #'mb/update-polybar-exwm)
(add-hook! 'exwm-update-class-hook #'mb/update-polybar-exwm)
(add-hook! 'doom-switch-buffer-hook #'mb/update-polybar-exwm)
(add-hook! 'doom-switch-window-hook #'mb/update-polybar-exwm)
(add-hook! 'persp-activated-functions  #'mb/update-polybar-exwm)
(advice-add #'rename-buffer :after #'mb/update-polybar-exwm)
