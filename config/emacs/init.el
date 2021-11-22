(when (and noninteractive IS-LINUX)
  (add-to-list 'doom-env-blacklist "^SWAYSOCK$"))
(when (and noninteractive IS-MAC)
  (add-to-list 'doom-env-whitelist "^SSH_"))

(doom! :input
       :completion
       (company +tng)    ; the ultimate code completion backend
       (vertico +icons)  ; the search engine of the future

       :ui
       doom              ; what makes DOOM look the way it does
       ;; doom-dashboard    ; a nifty splash screen for Emacs
       doom-quit         ; DOOM quit-message prompts when you quit Emacs
       fill-column       ; a `fill-column' indicator
       hl-todo           ; highlight TODO/FIXME/NOTE/DEPRECATED/HACK/REVIEW
       minimap           ; show a map of the code on the side
       modeline          ; snazzy, Atom-inspired modeline, plus API
       nav-flash         ; blink cursor line after big motions
       ophints           ; highlight the region an operation acts on
       (popup +all
              +defaults) ; tame sudden yet inevitable temporary windows
       (ligatures +extra); ligatures or substitute text with pretty symbols
       treemacs          ; a project drawer, like neotree but cooler
       vc-gutter         ; vcs diff in the fringe
       vi-tilde-fringe   ; fringe tildes to mark beyond EOB
       window-select     ; visually switch windows
       workspaces        ; tab emulation, persistence & separate workspaces
       zen               ; distraction-free coding or writing

       :editor
       (evil +everywhere); come to the dark side, we have cookies
       file-templates    ; auto-snippets for empty files
       fold              ; (nigh) universal code folding
       (format +onsave)  ; automated prettiness
       ;; lispy             ; sexpsy
       multiple-cursors  ; editing in many places at once
       rotate-text       ; cycle region at point between text candidates
       snippets          ; my elves. They type so I don't have to
       word-wrap         ; soft wrapping with language-aware indent

       :emacs
       (dired +icons)    ; making dired pretty [functional]
       electric          ; smarter, keyword-based electric-indent
       undo              ; persistent, smarter undo for your inevitable mistakes
       vc                ; version-control and Emacs, sitting in a tree

       :os
       (:if IS-MAC macos); improve compatibility with macOS

       :term
       vterm             ; the best terminal emulation in Emacs

       :checkers
       syntax            ; tasing you for every semicolon you forget
       spell             ; tasing you for misspelling mispelling
       grammar           ; tasing grammar mistake every you make

       :tools
       ansible
       direnv
       docker
       editorconfig      ; let someone else argue about tabs vs spaces
       (eval +overlay)   ; run code, run (also, repls)
       lookup            ; navigate your code and its documentation
       (lsp +peek)
       (magit +forge)    ; a git porcelain for Emacs
       make              ; run make tasks from Emacs
       ;; pdf               ; pdf enhancements
       rgb               ; creating color strings
       terraform         ; infrastructure as code

       :lang
       data              ; config/data formats
       emacs-lisp        ; drown in parentheses
       (go +lsp)         ; the hipster dialect
       (json +lsp)       ; At least it ain't XML
       (javascript +lsp) ; all(hope(abandon(ye(who(enter(here))))))
       markdown          ; writing docs for people to ignore
       nix               ; I hereby declare "nix geht mehr!"
       (org              ; organize your plain life in plain text
        +dragndrop
        +gnuplot
        +hugo
        +noter
        +pandoc
        +pomodoro
        +present
        +pretty
        +roam2)
       (python +lsp)     ; beautiful is better than ugly
       (rust +lsp)       ; Fe2O3.unwrap().unwrap().unwrap().unwrap()
       (sh +lsp)         ; she sells {ba,z,fi}sh shells on the C xor
       (yaml +lsp)       ; JSON, but readable
       ;; (racket +xp)      ; always be scheming
       (web +css
            +html)

       :app
       everywhere

       :config
       literate
       (default +bindings +smartparens))

;; FIXME: move by visual line
;; https://github.com/hlissner/doom-emacs/issues/401
(setq evil-respect-visual-line-mode t)
