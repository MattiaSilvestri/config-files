;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "Mattia Silvestri"
      user-mail-address "mattiasilvestri27@gmail.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-unicode-font' -- for unicode glyphs
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;; (setq doom-font (font-spec :family "Fira Code" :size 14)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 15))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)
;; (setq catppuccin-flavor 'mocha) ;; or 'latte, 'macchiato, or 'mocha
;; (catppuccin-reload)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package!'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;; -----------------------------------------------------------------------------
;; Personal config

;; Fonts
(set-face-attribute 'default nil :font "monospace" :height 110)
(set-fontset-font "fontset-default" '(#x5d0 . #x5ff) "all-the-icons")

;; Globals ------------------------------------------------------------------
;;Break lines
(add-hook 'text-mode-hook #'auto-fill-mode)
(setq-default fill-column 80)

(add-hook 'conf-mode-hook #'display-line-numbers-mode)
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(add-hook 'text-mode-hook #'display-line-numbers-mode)
;; (add-hook 'evil-local-mode-hook 'turn-on-undo-tree-mode)
(setq-default
 display-line-numbers-current-absolute t
 display-line-numbers-type 'visual
 display-line-numbers-width 0)

(setq-default truncate-lines t)
(global-page-break-lines-mode t)

(global-hl-line-mode 1)
(set-face-background 'hl-line "#232336")

(setq company-dabbrev-downcase 0)
(setq company-idle-delay 0)

(global-fancy-dabbrev-mode 1)

;; LaTex
;; (setq-default TeX-engine 'xelatex)
;; (setq latex-run-command "xelatex")
(setq pdf-latex-command "xelatex")

;; LSP
;; (setq lsp-idle-delay 0)
(setq read-process-output-max (* 1024 1024)) ;; 1mb

;; Functions ------------------------------------------------------------------
 (defun nf-compile-current-c/c++-file ()
    "Compiles a C/C++ file on the fly."
    (interactive)
    (let* ((clang-choices '(("c" . "clang") ("cpp" . "clang++")))
	   (filename (file-name-nondirectory buffer-file-name))
	   (file-ext (file-name-extension buffer-file-name))
	   (compile-choice (cdr (assoc file-ext clang-choices))))
      (compile (concat compile-choice " -Wall " filename " -o " (file-name-sans-extension filename)))))

(defun nf-run-exec-file ()
    "Runs an executable file named after the buffer if it exists."
    (interactive)
    (if (file-executable-p (file-name-sans-extension buffer-file-name))
	(async-shell-command
	 (concat "./" (file-name-nondirectory (file-name-sans-extension buffer-file-name))))))

(global-set-key (kbd "C-c C-m") 'nf-compile-current-c/c++-file)
;; fancy-dabbrev
(global-set-key (kbd "TAB") 'fancy-dabbrev-expand-or-indent)
(global-set-key (kbd "<backtab>") 'fancy-dabbrev-backward)

;; ------------------------------------------------------------------------------
;; Packages
(use-package! ivy
  :demand t
  :defer t
  :diminish ;;Diminish avoid the mode to be showed in the status bar.
  :bind (("C-s" . swiper)
         :map ivy-minibuffer-map
         ("TAB" . ivy-alt-done)
         ("C-l" . ivy-alt-done)
         ("C-j" . ivy-next-line)
         ("C-k" . ivy-previous-line)
         :map ivy-switch-buffer-map
         ("C-k" . ivy-previous-line)
         ("C-l" . ivy-done)
         ("C-d" . ivy-switch-buffer-kill)
         :map ivy-reverse-i-search-map
         ("C-k" . ivy-previous-line)
         ("C-d" . ivy-reverse-i-search-kill))
  :init
  (ivy-mode 1)
  :config
  (setq ivy-use-virtual-buffers t)
  (setq ivy-wrap t)
  (setq ivy-count-format "(%d/%d) ")
  (setq enable-recursive-minibuffers t)
  ;; Use different regex strategies per completion command
  (push '(completion-at-point . ivy--regex-fuzzy) ivy-re-builders-alist) ;; This doesn't seem to work...
  (push '(swiper . ivy--regex-ignore-order) ivy-re-builders-alist)
  (push '(counsel-M-x . ivy--regex-ignore-order) ivy-re-builders-alist)
  (push '(org-roam-node-find . ivy--regex-ignore-order) ivy-re-builders-alist)
  ;; Set minibuffer height for different commands
  (setf (alist-get 'swiper ivy-height-alist) 15)
  (setf (alist-get 'org-roam-node-find ivy-height-alist) 10))

(use-package! ivy-rich
  :defer t
  :init
  (ivy-rich-mode 1))
(setcdr (assq t ivy-format-functions-alist) #'ivy-format-function-line)

(use-package! all-the-icons-ivy-rich
  :defer t
  :ensure t
  :init (all-the-icons-ivy-rich-mode 1)
	:config
  ;; Whether display the icons
	(setq all-the-icons-ivy-rich-icon t)
	;; Whether display the colorful icons.
	;; It respects `all-the-icons-color-icons'.
	(setq all-the-icons-ivy-rich-color-icon t))

(use-package! counsel
  :defer t
  :demand t
  :bind (("C-x b" . counsel-switch-buffer)
         ("C-c b" . counsel-ibuffer)
         ("C-x C-f" . counsel-find-file)
         ;; ("C-M-j" . counsel-switch-buffer)
         ("C-M-l" . counsel-imenu)
				 ("C-`" . counsel-bookmark)
         :map minibuffer-local-map
         ("C-r" . 'counsel-minibuffer-history))
  :custom
  (counsel-linux-app-format-function #'counsel-linux-app-format-function-name-only)
  :config
  (setq ivy-initial-inputs-alist nil)) ;; Don't start searches with ^

(use-package! lsp-mode
  :init
  ;; (setq lsp-headerline-breadcrumb-enable t)
  (setq lsp-headerline-breadcrumb-segments '(project file symbols))
  (setq lsp-headerline-breadcrumb-icons-enable t)
  (setq lsp-enable-symbol-highlighting nil)
  (setq lsp-flycheck-live-reporting nil)

  :defer t
  :hook
  ((lsp-mode) . (lambda()
                        (auto-fill-mode 1)
                        ;; (auto-complete-mode 1)
                        (emmet-mode 1)
                        (fancy-dabbrev-mode 1)
                        (display-fill-column-indicator-mode 1))) ; Display vertical line (guides) at 80th position.
)

(use-package! org-roam
      :ensure t
      :defer t
      :custom
      (org-roam-directory (file-truename "/mnt/Data/MEGA/Notes/Roam"))
      :bind (("C-c n l" . org-roam-buffer-toggle)
             ("C-c n f" . org-roam-node-find)
             ("C-c n g" . org-roam-graph)
             ("C-c n i" . org-roam-node-insert)
             ("C-c n c" . org-roam-capture)
             ;; Dailies
             ("C-c n j" . org-roam-dailies-capture-today))
			:config
			;; If you're using a vertical completion framework, you might want a more informative completion interface
			(setq org-roam-node-display-template (concat "${title:*} " (propertize "${tags:10}" 'face 'org-tag)))
			(org-roam-db-autosync-mode)
			;; If using org-roam-protocol
			(require 'org-roam-utils))

;; Turn on indentation and auto-fill mode for Org files
(defun dw/org-mode-setup ()
  ;; (org-indent-mode)
  (mixed-pitch-mode 1)
  (auto-fill-mode 1)
  (visual-line-mode 0)
	(flyspell-mode t)
	(svg-tag-mode t)
  (setq evil-auto-indent t)
  )

(use-package! org
  :defer t
  :hook (org-mode . dw/org-mode-setup)
  :config
  (setq org-ellipsis " ▾"
        org-hide-emphasis-markers t
        org-src-fontify-natively t
        org-fontify-quote-and-verse-blocks t
        org-src-tab-acts-natively t
        org-edit-src-content-indentation 2
        org-hide-block-startup nil
        org-src-preserve-indentation nil
        org-startup-folded 'showeverything
        org-cycle-separator-lines 2
        org-capture-bookmark nil)

(use-package! org-superstar
  :after org
  :hook (org-mode . org-superstar-mode)
  :custom
  (org-superstar-remove-leading-stars t)
  (org-superstar-headline-bullets-list '("◉" "○" "●" "○" "●" "○" "●")))

;; Increase the size of various headings
(set-face-attribute 'org-document-title nil :font "Iosevka Aile" :weight 'bold :height 1.3)
(dolist (face '((org-level-1 . 1.2)
                (org-level-2 . 1.1)
                (org-level-3 . 1.05)
                (org-level-4 . 1.0)
                (org-level-5 . 1.1)
                (org-level-6 . 1.1)
                (org-level-7 . 1.1)
                (org-level-8 . 1.1)))
  (set-face-attribute (car face) nil :font "Iosevka Aile" :weight 'medium :height (cdr face)))

;; Make sure org-indent face is available
(require 'org-indent)

;; Ensure that anything that should be fixed-pitch in Org files appears that way
;; (set-face-attribute 'org-block nil :foreground nil :inherit 'fixed-pitch)
;; (set-face-attribute 'org-table nil  :inherit 'fixed-pitch)
(set-face-attribute 'org-formula nil  :inherit 'fixed-pitch)
;; (set-face-attribute 'org-code nil   :inherit '(shadow fixed-pitch))
(set-face-attribute 'org-indent nil :inherit '(org-hide fixed-pitch))
;; (set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch))
;; (set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
;; (set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
(set-face-attribute 'org-checkbox nil :inherit 'fixed-pitch)

;; Get rid of the background on column views
(set-face-attribute 'org-column nil :background nil)
(set-face-attribute 'org-column-title nil :background nil)

(custom-theme-set-faces
'user
'(org-block ((t (:inherit fixed-pitch))))
'(org-code ((t (:inherit (shadow fixed-pitch)))))
'(org-document-info ((t (:foreground "dark orange"))))
'(org-document-info-keyword ((t (:inherit (shadow fixed-pitch)))))
'(org-indent ((t (:inherit (org-hide fixed-pitch)))))
'(org-link ((t (:inherit mixed-pitch :foreground "SkyBlue2" :underline t :bold nil :weigth regular :height 0.9))))
'(org-meta-line ((t (:inherit (font-lock-comment-face fixed-pitch)))))
'(org-property-value ((t (:inherit fixed-pitch))) t)
'(org-special-keyword ((t (:inherit (font-lock-comment-face fixed-pitch)))))
'(org-table ((t (:inherit fixed-pitch :foreground "#83a598"))))
'(org-tag ((t (:inherit (shadow fixed-pitch) :weight bold :height 0.8))))
'(org-verbatim ((t (:inherit (shadow fixed-pitch))))))
)

(require 'org-download)
(eval-after-load 'org
   (setq org-startup-indented t)) ; Enable `org-indent-mode' by default

;; Unicode fonts
(defun dw/replace-unicode-font-mapping (block-name old-font new-font)
  (let* ((block-idx (cl-position-if
                         (lambda (i) (string-equal (car i) block-name))
                         unicode-fonts-block-font-mapping))
         (block-fonts (cadr (nth block-idx unicode-fonts-block-font-mapping)))
         (updated-block (cl-substitute new-font old-font block-fonts :test 'string-equal)))
    (setf (cdr (nth block-idx unicode-fonts-block-font-mapping))
          `(,updated-block))))

(use-package! unicode-fonts
  :disabled
  :defer t
  :if (not dw/is-termux)
  :custom
  (unicode-fonts-skip-font-groups '(low-quality-glyphs))
  :config
  ;; Fix the font mappings to use the right emoji font
  (mapcar
    (lambda (block-name)
      (dw/replace-unicode-font-mapping block-name "Apple Color Emoji" "Noto Color Emoji"))
    '("Dingbats"
      "Emoticons"
      "Miscellaneous Symbols and Pictographs"
      "Transport and Map Symbols"))
  (unicode-fonts-setup))

(use-package! dirvish
  :init
  (dirvish-override-dired-mode)
  :defer t
  :custom
  (dirvish-quick-access-entries
   '(("h" "~/"                          "Home")
     ("d" "~/Downloads/"                "Downloads")
     ("m" "/mnt/"                       "Drives")
     ("t" "~/.local/share/Trash/files/" "TrashCan")))
  :config
  ;; (dirvish-peek-mode) ; Preview files in minibuffer
  ;; (setq dirvish-hide-details nil) ; show details at startup like `dired'
  (setq dirvish-mode-line-format
        '(:left (sort file-time " " file-size symlink) :right (omit yank index)))
  (setq dirvish-attributes
        '(all-the-icons file-size collapse subtree-state vc-state git-msg))
  (setq delete-by-moving-to-trash t)
  (setq dired-listing-switches
        "-l --almost-all --human-readable --time-style=long-iso --group-directories-first --no-group")
	(setq dirvish-preview-dispatchers
				(cl-substitute 'pdf-preface 'pdf dirvish-preview-dispatchers))
  :bind ; Bind `dirvish|dirvish-side|dirvish-dwim' as you see fit
  (("C-c f" . dirvish-fd)
	 ("C-c q" . dirvish-quit)
   :map dirvish-mode-map ; Dirvish inherits `dired-mode-map'
   ("a"   . dirvish-quick-access)
   ("f"   . dirvish-file-info-menu)
   ("y"   . dirvish-yank-menu)
   ("N"   . dirvish-narrow)
   ("^"   . dirvish-history-last)
	 ("h"   . dirvish-up-directory-ad)
	 ("l"   . dirvish-find-entry-ad)
   ("s"   . dirvish-quicksort)    ; remapped `dired-sort-toggle-or-edit'
   ("v"   . dirvish-vc-menu)      ; remapped `dired-view-file'
   ("TAB" . dirvish-subtree-toggle)
   ("M-f" . dirvish-history-go-forward)
   ("M-b" . dirvish-history-go-backward)
   ("M-l" . dirvish-ls-switches-menu)
   ("M-m" . dirvish-mark-menu)
   ("M-t" . dirvish-layout-toggle)
   ("M-s" . dirvish-setup-menu)
   ("M-e" . dirvish-emerge-menu)
   ("M-j" . dirvish-fd-jump)))

;; SVG-tags
(require 'svg-tag-mode)

(defconst date-re "[0-9]\\{4\\}-[0-9]\\{2\\}-[0-9]\\{2\\}")
(defconst time-re "[0-9]\\{2\\}:[0-9]\\{2\\}")
(defconst day-re "[A-Za-z]\\{3\\}")

(defun svg-progress-percent (value)
  (svg-image (svg-lib-concat
              (svg-lib-progress-bar (/ (string-to-number value) 100.0)
                                nil :margin 0 :stroke 2 :radius 3 :padding 2 :width 11)
              (svg-lib-tag (concat value "%")
                           nil :stroke 0 :margin 0)) :ascent 'center))

(defun svg-progress-count (value)
  (let* ((seq (mapcar #'string-to-number (split-string value "/")))
         (count (float (car seq)))
         (total (float (cadr seq))))
  (svg-image (svg-lib-concat
              (svg-lib-progress-bar (/ count total) nil
                                    :margin 0 :stroke 2 :radius 3 :padding 2 :width 11)
              (svg-lib-tag value nil
                           :stroke 0 :margin 0)) :ascent 'center)))

(setq svg-tag-tags
      `(
        ;; Org tags
        (":\\([A-Za-z0-9]+\\)" . ((lambda (tag) (svg-tag-make tag))))
        (":\\([A-Za-z0-9]+[ \-]\\)" . ((lambda (tag) tag)))

        ;; Task priority
        ("\\[#[A-Z]\\]" . ( (lambda (tag)
                              (svg-tag-make tag :face 'org-priority
                                            :beg 2 :end -1 :margin 0))))

        ;; Progress
        ("\\(\\[[0-9]\\{1,3\\}%\\]\\)" . ((lambda (tag)
                                            (svg-progress-percent (substring tag 1 -2)))))
        ("\\(\\[[0-9]+/[0-9]+\\]\\)" . ((lambda (tag)
                                          (svg-progress-count (substring tag 1 -1)))))

        ;; TODO / DONE
        ("TODO" . ((lambda (tag) (svg-tag-make "TODO" :face 'org-todo :inverse t :margin 0))))
        ("DONE" . ((lambda (tag) (svg-tag-make "DONE" :face 'org-done :margin 0))))

        ;; Citation of the form [cite:@Knuth:1984]
        ("\\(\\[cite:@[A-Za-z]+:\\)" . ((lambda (tag)
                                          (svg-tag-make tag
                                                        :inverse t
                                                        :beg 7 :end -1
                                                        :crop-right t))))
        ("\\[cite:@[A-Za-z]+:\\([0-9]+\\]\\)" . ((lambda (tag)
                                                (svg-tag-make tag
                                                              :end -1
                                                              :crop-left t))))
        ;; Active date (without day name, with or without time)
        (,(format "\\(<%s>\\)" date-re) .
         ((lambda (tag)
            (svg-tag-make tag :beg 1 :end -1 :margin 0))))
        (,(format "\\(<%s *\\)%s>" date-re time-re) .
         ((lambda (tag)
            (svg-tag-make tag :beg 1 :inverse nil :crop-right t :margin 0))))
        (,(format "<%s *\\(%s>\\)" date-re time-re) .
         ((lambda (tag)
            (svg-tag-make tag :end -1 :inverse t :crop-left t :margin 0))))

        ;; Inactive date  (without day name, with or without time)
         (,(format "\\(\\[%s\\]\\)" date-re) .
          ((lambda (tag)
             (svg-tag-make tag :beg 1 :end -1 :margin 0 :face 'org-date))))
         (,(format "\\(\\[%s *\\)%s\\]" date-re time-re) .
          ((lambda (tag)
             (svg-tag-make tag :beg 1 :inverse nil :crop-right t :margin 0 :face 'org-date))))
         (,(format "\\[%s *\\(%s\\]\\)" date-re time-re) .
          ((lambda (tag)
             (svg-tag-make tag :end -1 :inverse t :crop-left t :margin 0 :face 'org-date))))))

(svg-tag-mode t)

(use-package eaf
  :load-path "~/.config/emacs/site-lisp/emacs-application-framework"
  :custom
  ; See https://github.com/emacs-eaf/emacs-application-framework/wiki/Customization
  (eaf-browser-continue-where-left-off t)
  (eaf-browser-enable-adblocker t)
  (browse-url-browser-function 'eaf-open-browser)
  :config
  (defalias 'browse-web #'eaf-open-browser))

;; (require 'eaf-browser)
;; (require 'eaf-pdf-viewer)

(use-package org-logseq
    :custom (org-logseq-dir "/mnt/Data/MEGA/Notes"))
