;; Startup behaviour (setq inhibit-startup-message t) ;; Inhibit startup messagge.
;(tooltip-mode -1) ; Disable tooltip.
(tool-bar-mode -1) ; Disable tooltip.
(toggle-scroll-bar -1) ; Disable vertical scrollbar

;; Font size
(set-face-attribute 'default nil :font "DejaVu Sans Mono" :height 130)
(set-fontset-font "fontset-default" '(#x5d0 . #x5ff) "all-the-icons") 
;; Set the font face based on platform
;; (set-face-attribute 'fixed-pitch nil :font "Fira Code Retina" :height 130)
;; (set-face-attribute 'variable-pitch nil :font "Cantarell" :height 140 :weight 'regular)

;; Global Theme
(load-theme 'doom-nord t)
;;Treemacs Theme
;; (treemacs-load-theme "Default")

;; Number column
(column-number-mode)

;;Break lines
(add-hook 'text-mode-hook #'auto-fill-mode)
(setq-default fill-column 80)

;; 1)
;; (setq-default display-line-numbers-type 'visual)
;; (global-display-line-numbers-mode)

;; 2)
(add-hook 'conf-mode-hook #'display-line-numbers-mode)
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(add-hook 'text-mode-hook #'display-line-numbers-mode)
(setq-default
 display-line-numbers-current-absolute t
 display-line-numbers-type 'visual
 display-line-numbers-width 0)

;;3)
;; (global-display-line-numbers-mode)

;; (defvar my-linum-current-line-number 0)

;; (setq linum-format 'my-linum-relative-line-numbers)

;; (defun my-linum-relative-line-numbers (line-number)
;;   (let ((test2 (- line-number my-linum-current-line-number)))
;;     (propertize
;;      (number-to-string (cond ((<= test2 0) (* -1 test2))
;;                              ((> test2 0) test2)))
;;      'face 'linum)))

;; (defadvice linum-update (around my-linum-update)

;;   (let ((my-linum-current-line-number (line-number-at-pos)))
;;     ad-do-it))

;; (ad-activate 'linum-update)

;; (global-linum-mode t)
;; ;;----------------------------------------------------------------------

;; (dolist (mode '(text-mode-hook
;;                 term-mode-hook
;;                 eshell-mode-hook))
;;   (add-hook mode (lambda () (display-line-numbers-mode 0)))) ;;Disable normal numbers

;; (dolist (mode '(text-mode-hook
;;                 term-mode-hook
;;                 eshell-mode-hook))
;;   (add-hook mode (lambda () (linum-mode 0)))) ;;Disable linum numbers
;(set-face-background 'linum "#000000")
(set-face-background 'line-number "#373f4d")

;;Raibow delimeters
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;(add-hook 'hack-local-variables-hook (lambda () (setq truncate-lines t))) 
(setq-default truncate-lines t)

;; Globals ------------------------------------------------------------------
(latex-preview-pane-enable)
(global-undo-tree-mode 1)
(autopair-global-mode 1)
;(global-auto-complete-mode t)
(global-hl-line-mode 1)
(global-display-line-numbers-mode)
(show-paren-mode 1)
(rainbow-delimiters-mode 1)
(setq show-paren-delay 0)
(setq process-connection-type 'nil)

(require 'workgroups)
(workgroups-mode 1)

(require 'multiple-cursors)
(global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines)
(global-set-key (kbd "C->") 'mc/mark-next-like-this)
(global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
(global-set-key (kbd "C-c C-<") 'mc/mark-all-like-this)

(setq make-backup-files nil) ; stop creating ~ files

(setq bibtex-completion-bibliography
    '("/mnt/08542B6A542B59A8/MEGA/UNIVERSITA(M)/Thesis/library.bib"))
(setq ivy-bibtex-default-action 'ivy-bibtex-insert-key)

;; LSP mode tweaks
(setq gc-cons-threshold 100000000)
(setq read-process-output-max (* 1024 1024))
(setq lsp-idle-delay 0.500)

;; Org-mode
(setq org-src-preserve-indentation t)
(setq org-startup-folded t)

;; Org-Roam
;; (setq org-roam-graph-executable "dot")
(setq org-roam-v2-ack t)

;; Tables
 (setq table-cell-horizontal-chars "\u2501")
 (setq table-cell-vertical-char ?\u2503)
 (setq table-cell-intersection-char ?\u254B)

;; Frame transparency
(set-frame-parameter (selected-frame) 'alpha '(80 . 80))
(add-to-list 'default-frame-alist '(alpha . (80 . 80)))

;; Tab bar mode
(tab-bar-mode 1)

;; Tab width
(setq-default tab-width 2)

;; Ruler at 80th characters
;; (global-display-fill-column-indicator-mode 1)

;; Line at page break
(global-page-break-lines-mode t)

;; Doc-view continuous scrolling
(setq doc-view-continuous nil)

;; Default ispell dictionary
(setq ispell-dictionary "en_GB")

;; Start emacs server
(server-start)

;; Tweaks
(when (featurep 'project)
	(when-let ((project (project-current)))
		(with-no-warnings
			(if (fboundp 'project-roots)
					(car (project-roots project))
				(project-root project)))))

   ;; (if (get 'project-roots 'byte-obsolete-info)
   ;;     'project-root
   ;;   (lambda()
	 ;; 		 (setq ess-gen-proc-buffer-name-function 'ess-gen-proc-buffer-name:directory)
   ;;     (setq ess-use-flymake nil)))

;; (setq package-native-compile t)
;; (when (and (fboundp 'native-comp-available-p)
;;            (native-comp-available-p))
;;   (progn
;;     (setq native-comp-async-report-warnings-errors nil)
;;     (setq comp-deferred-compilation t)
;;     (add-to-list 'native-comp-eln-load-path (expand-file-name "eln-cache/" user-emacs-directory))
;;     (setq package-native-compile t)
;;     ))
;; --------------------------------------------------------------------

;; ;; Functions -------------------------------------------------------
(defun my/evil-shift-right ()
  (interactive)
  (evil-shift-right evil-visual-beginning evil-visual-end)
  (evil-normal-state)
  (evil-visual-restore))

(defun my/evil-shift-left ()
  (interactive)
  (evil-shift-left evil-visual-beginning evil-visual-end)
  (evil-normal-state)
  (evil-visual-restore))

(defconst clangd-p
  (or (executable-find "clangd")  ;; usually
      (executable-find "/usr/local/opt/llvm/bin/clangd"))  ;; macOS
  "Do we have clangd?")

(defun revert-buffer-no-confirm ()
  "Revert buffer without confirmation."
  (interactive) (revert-buffer t t))

(defun as/open-in-deft (filter)
  (deft)
  (deft-filter filter t))

(defun as/collect-filetags ()
  (interactive)
  (let* ((command (concat "grep -h '^#+filetags:' " org-roam-directory "/*.org"))
         (output (shell-command-to-string command))
         (lines (split-string output "[ \n]+" t "#\\+filetags:"))
         (tags (sort (-flatten (mapcar (lambda (l) (split-string l ":" t)) lines)) #'string<))
         (counts (-reduce-from (lambda (plist tag)
                                 (if (string-match "^##" tag)
                                     plist
                                   (let* ((tagname (substring tag 1))
                                          (nb (lax-plist-get plist tagname)))
                                     (lax-plist-put plist tagname (if nb (+ nb 1) 1)))))
                               nil tags)))
    (let ((file (concat org-roam-directory "/taglist.org")))
    (write-region "#+TITLE: Tag List\n\n" nil file nil)
    (while counts
      (let ((tag (car counts))
            (nb  (cadr counts)))
        (write-region
         ;; The next line is a dirty hack to avoid the tag being explicitely in
         ;; the tag list, hence in deft search results
         (format "- [[elisp:(as/open-in-deft (concat \"#\" \"%s\"))][%s]] :: %d\n" tag tag nb)
         nil file t)
        (setq counts (cddr counts)))))))

(setq auto-save-default nil)
(setq-default evil-kill-on-visual-paste nil)

;; Matlab-mode
;; (setq matlab-server-executable "/home/mattia/MATLAB/R2020a/bin/matlab")
;; (add-to-list 'load-path "/home/mattia/.config/emacs/matlab-mode")
;; (require 'matlab-mode)
;; (matlab-mode-common-setup)
 ;; (autoload 'matlab-mode "matlab" "Matlab Editing Mode" t)
 ;; (add-to-list
 ;;  'auto-mode-alist
 ;;  '("\\.m$" . matlab-mode))
 ;; (setq matlab-indent-function t)
 ;; (setq matlab-shell-command "matlab")

;; Keybingings -----------------------------------------------------
;Set super as meta key
;; (setq  x-meta-keysym 'super
;;        x-super-keysym 'meta)

; Set alt as meta key
(setq x-alt-keysym 'meta)

;; Global keybindings ------------------------------------
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)
(global-set-key (kbd "C-x b") 'counsel-switch-buffer)
(global-set-key (kbd "C-c l t") 'counsel-load-theme)
(global-set-key (kbd "C-M-r") 'revert-buffer-no-confirm)
(global-set-key (kbd "C-x C-c") 'ivy-bibtex)
(global-set-key (kbd "C-x C-p") 'latex-preview-pane-mode)
(global-set-key (kbd "M-n d") 'deft)
(global-set-key (kbd "C-` d") 'bookmark-delete)
(global-set-key (kbd "C-c p k") 'package-install)
;(define-key emacs-lisp-mode-map (kbd "C-x M-t") 'counsel-load-theme') ;Example to set keys for specific modes

;; Packages ---------------------------------------------------------

;; Initialize package sources
(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("gnu" . "https://elpa.gnu.org/packages/")
                         ("nongnu" . "https://elpa.nongnu.org/nongnu/")
												 ;; ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))
;; Initialize use-package on non-Linux platforms (unless (package-installed-p 'use-package) (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)
;(setq use-package-always-demand t) ;If you have this, you don't need to have :demand t in every package.

;;Which key
(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 0))

(use-package ivy
  :demand t
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
  :config
  (ivy-mode 1)
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

(use-package ivy-rich
  :init
  (ivy-rich-mode 1))


;; ivy posframe
;; (defun ivy-posframe-get-size ()
;;   "The default functon used by `ivy-posframe-size-function'."
;;   (list
;;    :height ivy-posframe-height
;;    :width ivy-posframe-width
;;    :min-height (or ivy-posframe-min-height (+ ivy-height 1))
;;    :min-width (or ivy-posframe-min-width (round (* (frame-width) 0.62)))))

(use-package ivy-posframe
	:config
	;; Different command can use different display function.
	(setq ivy-posframe-display-functions-alist
			'((swiper          . ivy-display-function-fallback)
					(complete-symbol . ivy-posframe-display-at-point)
					(counsel-M-x     . ivy-posframe-display-at-frame-bottom-left)
					(t               . ivy-posframe-display-at-frame-bottom-left)))
  (setq
   ;; ivy-posframe-width (frame-width)
   ivy-posframe-border-width 3
   ivy-posframe-parameters
   '((left-fringe . 8)
     (right-fringe . 8)))
	(ivy-posframe-mode 1))

(use-package counsel
  :demand t
  :bind (("C-:" . counsel-M-x)
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

;Doom-modeline --------------------------------
(use-package minions
  :hook (doom-modeline-mode . minions-mode))
(require 'doom-modeline)
(doom-modeline-mode 1)
(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1)
  (setq doom-modeline-icon (display-graphic-p))
  (setq doom-modeline-major-mode-icon t)  
  (setq doom-modeline-major-mode-color-icon t)
  (setq doom-modeline-buffer-modification-icon t)
  (setq doom-modeline-checker-simple-format t)  
  (setq doom-modeline-lsp t)
  (setq doom-modeline-minor-modes t)
  :custom
  (doom-modeline-height 30))

;(use-package general)
  ;:config  
  ;(general-evil-setup t)
 
;;Evil mode  
(defun dw/evil-hook ()
  (dolist (mode '(custom-mode
                  eshell-mode
                  git-rebase-mode
                  erc-mode
                  circe-server-mode
                  circe-chat-mode
                  circe-query-mode
                  sauron-mode
                  term-mode))
  (add-to-list 'evil-emacs-state-modes mode)))

(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-i-jump nil)
  (setq evil-respect-visual-line-mode t)
  (setq evil-undo-system 'undo-tree)
  (setq evil-shift-width 2)
  :config
  (add-hook 'evil-mode-hook 'dw/evil-hook)
  (evil-mode 1)
  (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
  (define-key evil-insert-state-map (kbd "C-h") 'evil-delete-backward-char-and-join)
  (evil-define-key 'insert global-map (kbd "C-j") 'evil-next-line)
  (evil-define-key 'insert global-map (kbd "C-k") 'evil-previous-line)
  (evil-define-key 'insert global-map (kbd "C-l") 'evil-forward-char)
  (evil-define-key 'insert global-map (kbd "C-h") 'evil-backward-char)  
  (evil-define-key 'normal global-map (kbd "U") 'evil-redo)
  ;; (evil-define-key 'normal global-map (kbd "g t") 'centaur-tabs-forward)
  ;; (evil-define-key 'normal global-map (kbd "g T") 'centaur-tabs-backward)
	(evil-define-key 'visual global-map (kbd ">") 'my/evil-shift-right)
  (evil-define-key 'visual global-map (kbd "<") 'my/evil-shift-left))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(use-package lsp-mode
  :init
  (setq lsp-headerline-breadcrumb-enable t)
  (setq lsp-headerline-breadcrumb-segments '(project file symbols))
  (setq lsp-headerline-breadcrumb-icons-enable t)
  :defer t
  :commands lsp
  :custom
  (lsp-auto-guess-root nil)
  (lsp-prefer-flymake nil) ; Use flycheck instead of flymake
  (lsp-file-watch-threshold 2000)
  (read-process-output-max (* 1024 1024))
  (lsp-eldoc-hook nil)
  :custom-face
  (lsp-face-highlight-read ((t (:background "dark slate grey"))))
  (lsp-face-highlight-write ((t (:background "dark slate grey"))))
  (lsp-face-highlight-textual ((t (:background "dark slate grey"))))
  ;; :config
  ;; (setq lsp-diagnostics-provider :none)
  :bind (:map lsp-mode-map 
	      ("C-c C-f" . lsp-format-buffer)
	      ("C-l f" . lsp-find-references)
				("C-c t s" . lsp-treemacs-symbols)
	      ("C-l r" . lsp-rename))
  :hook
	((LaTex-mode latex-mode java-mode python-mode go-mode js-mode js2-mode typescript-mode web-mode
          c-mode c++-mode objc-mode ess-r-mode) . lsp)
  (lsp-mode . (lambda()
								(auto-fill-mode 1)
								(display-fill-column-indicator-mode 1)))) ; Display vertical line at 80th position.

  ;:config
    ;(setq lsp-auto-configure t)
    ;(lsp-register-client
     ;(make-lsp-client :new-connection (lsp-stdio-connection "/home/mattia/Shell-scripts/matlab-langserver.sh")
                      ;:major-modes '(matlab-mode)
                      ;:server-id 'matlab-langserver))

;; (use-package lsp-jedi
;;   :ensure t
;;   :config
;;   (with-eval-after-load "lsp-mode"
;;     (add-to-list 'lsp-disabled-clients 'pyls)
;;     (add-to-list 'lsp-enabled-clients 'jedi)))

(use-package lsp-ui
  :after lsp-mode
  :diminish
  :commands lsp-ui-mode
  :custom-face
  (lsp-ui-doc-background ((t (:background nil))))
  (lsp-ui-doc-header ((t (:inherit (font-lock-string-face italic)))))
  :bind
  (:map lsp-ui-mode-map
        ([remap xref-find-definitions] . lsp-ui-peek-find-definitions)
        ([remap xref-find-references] . lsp-ui-peek-find-references)
        ("C-c u" . lsp-ui-imenu)
        ("C-c d" . lsp-ui-doc-mode)
        ("M-i" . lsp-ui-doc-focus-frame))
  (:map lsp-mode-map
        ("M-n" . forward-paragraph)
        ("M-o" . backward-paragraph))
  :custom
  (lsp-ui-doc-header t)
  (lsp-ui-doc-include-signature t)
  (lsp-ui-doc-border (face-foreground 'default))
  (lsp-ui-doc-enable nil)
  (lsp-ui-sideline-enable nil)
  (lsp-ui-sideline-ignore-duplicate t)
  (lsp-ui-sideline-show-code-actions nil)
  :config
  ;; Use lsp-ui-doc-webkit only in GUI
  (if (display-graphic-p)
      (setq lsp-ui-doc-use-webkit t))
  ;; WORKAROUND Hide mode-line of the lsp-ui-imenu buffer
  ;; https://github.com/emacs-lsp/lsp-ui/issues/243
  (defadvice lsp-ui-imenu (after hide-lsp-ui-imenu-mode-line activate)
    (setq mode-line-format nil)))

(use-package company
  :diminish company-mode
  :hook ((prog-mode LaTeX-mode latex-mode ess-r-mode python-mode org-roam-mode) . company-mode)
  :bind
  (:map company-active-map
        ([tab] . smarter-tab-to-complete)
        ("TAB" . smarter-tab-to-complete)
	("<tab>" . company-complete-selection))
  :custom
  (company-minimum-prefix-length 1)
  (company-tooltip-align-annotations t)
  (company-require-match 'never)
  ;; Don't use company in the following modes
  (company-global-modes '(not shell-mode eaf-mode))
  ;; Trigger completion immediately.
  (company-idle-delay 0.0)
  ;; Number the candidates (use M-1, M-2 etc to select completions).
  (company-show-numbers t)
  :config
  (unless clangd-p (delete 'company-clang company-backends))
  (global-company-mode 1)
  (defun smarter-tab-to-complete ()
    "Try to `org-cycle', `yas-expand', and `yas-next-field' at current cursor position.

If all failed, try to complete the common part with `company-complete-common'"
    (interactive)
    (if yas-minor-mode
        (let ((old-point (point))
              (old-tick (buffer-chars-modified-tick))
              (func-list '(org-cycle yas-expand yas-next-field)))
          (catch 'func-suceed
            (dolist (func func-list)
              (ignore-errors (call-interactively func))
              (unless (and (eq old-point (point))
                           (eq old-tick (buffer-chars-modified-tick)))
                (throw 'func-suceed t)))
            (company-complete-common))))))
; bind company-select-next to tab
(eval-after-load 'company
  '(progn
     (define-key company-active-map (kbd "TAB") 'company-complete-common-or-cycle)
     (define-key company-active-map [tab] 'company-complete-common-or-cycle)))


(use-package company-quickhelp
  :ensure t
  :after company
  :config
  (company-quickhelp-mode 1))


(use-package company-lua
  :ensure t
  :after company
  :config
  (company-lua 1))

(use-package company-box
  :hook (company-mode . company-box-mode))

;;ESS mode
(use-package ess
  :defer t
  :commands R
  :config
  (load "ess-autoloads"))

(use-package lua-mode)

(use-package python-mode
  :ensure nil
  :after flycheck
  :mode "\\.py\\'"
  :hook
	(python-mode . lsp-deferred)
	:config
	(require 'dap-python)
	(setq python-shell-completion-native-enable nil)
	:bind
	("C-c s r" . python-shell-send-region)
	("C-c r p" . run-python)
  :custom
  (python-indent-offset 4)
  (flycheck-python-pycompile-executable "python3")
	(dap-python-executable "python3")
	(dap-python-debugger 'dabugpy)
  (python-shell-interpreter "python3"))

(use-package lsp-pyright
  :hook (python-mode . (lambda () (require 'lsp-pyright)))
  :init (when (executable-find "python3")
          (setq lsp-pyright-python-executable-cmd "python3")))

;;Matlab mode
;; (use-package matlab-mode
;;   :ensure t
;;   :defer t
;;   :init (column-number-mode t)
;;   :config (setq matlab-indent-function-body t)
;;   (add-hook 'column-number-mode)
;;   :commands (matlab-shell)
;;  )
;(use-package matlab
  ;:demand t
  ;:ensure t
  ;:config
  ;(matlab-cedet-setup)
  ;(ac-config-default)
  ;(add-hook 'matlab-mode-hook 'auto-complete-mode)
  ;(add-hook 'matlab-mode-hook (lambda () (mlint-minor-mode 1)))
  ;(add-to-list
   ;'auto-mode-alist
   ;'("\\.m\\'" . matlab-mode))
  ;(setq matlab-indent-function t)
  ;(setq matlab-shell-command "matlab")
  ;(setq mlint-programs (quote ("/home/mattia/MATLAB/R2020a/bin/glnxa64/mlint")))
  ;(setq matlab-show-mlint-warnings t)
  ;(setq matlab-highlight-cross-function-variables t))
;(autoload 'matlab-mode "matlab" "Matlab Editing Mode" t)
;(add-to-list
 ;'auto-mode-alist
 ;'("\\.m$" . matlab-mode))
;(setq matlab-indent-function t)
;(setq matlab-shell-command "matlab")
;(add-hook 'matlab-mode-hook 'auto-complete-mode)
;(setq mlint-programs (quote ("/home/mattia/MATLAB/R2020a/bin/glnxa64/mlint")))
;(add-hook 'matlab-mode-hook (lambda () (mlint-minor-mode 1)))
;(setq matlab-show-mlint-warnings t)
;(setq matlab-highlight-cross-function-variables t)
;(setq matlab-complete t)
;(matlab-cedet-setup)
;(ac-config-default)
(use-package matlab-mode
  :ensure t
  :defer t
  :config (setq matlab-indent-function-body t)
  :commands (matlab-shell)
 )

(use-package all-the-icons)

;; Turn on indentation and auto-fill mode for Org files
(defun dw/org-mode-setup ()
  ;; (org-indent-mode)
  (mixed-pitch-mode 1)
  (auto-fill-mode 1)
  (visual-line-mode 0)
	(flyspell-mode t)
  (setq evil-auto-indent t)
  )

(use-package org
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
        org-startup-folded 'content
        org-cycle-separator-lines 2
        org-capture-bookmark nil)

;;   (setq org-modules
;;     '(org-crypt
;;         org-habit
;;         org-bookmark
;;         org-eshell))

;;   (setq org-refile-targets '((nil :maxlevel . 1)
;;                              (org-agenda-files :maxlevel . 1)))

;;   (setq org-outline-path-complete-in-steps nil)
;;   (setq org-refile-use-outline-path t)

;;   (evil-define-key '(normal insert visual) org-mode-map (kbd "C-j") 'org-next-visible-heading)
;;   (evil-define-key '(normal insert visual) org-mode-map (kbd "C-k") 'org-previous-visible-heading)

;;   (evil-define-key '(normal insert visual) org-mode-map (kbd "M-j") 'org-metadown)
;;   (evil-define-key '(normal insert visual) org-mode-map (kbd "M-k") 'org-metaup)

;;   (org-babel-do-load-languages
;;     'org-babel-load-languages
;;     '((emacs-lisp . t)
;;       (ledger . t)))

;;   (push '("conf-unix" . conf-unix) org-src-lang-modes)

(use-package org-superstar
  :after org
  :hook (org-mode . org-superstar-mode)
  :custom
  (org-superstar-remove-leading-stars t)
  (org-superstar-headline-bullets-list '("◉" "○" "●" "○" "●" "○" "●")))

;; Replace list hyphen with dot
;; (font-lock-add-keywords 'org-mode
;;                         '(("^ *\\([-]\\) "
;;                             (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))

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
;; '(org-indent ((t (:inherit (org-hide fixed-pitch)))))
'(org-link ((t (:inherit fixed-pitch :foreground "SkyBlue2" :underline t :bold nil))))
'(org-meta-line ((t (:inherit (font-lock-comment-face fixed-pitch)))))
'(org-property-value ((t (:inherit fixed-pitch))) t)
'(org-special-keyword ((t (:inherit (font-lock-comment-face fixed-pitch)))))
'(org-table ((t (:inherit fixed-pitch :foreground "#83a598"))))
'(org-tag ((t (:inherit (shadow fixed-pitch) :weight bold :height 0.8))))
'(org-verbatim ((t (:inherit (shadow fixed-pitch))))))
)
;; Old org mode config ------------------------------------------------
;; (use-package org
;; 	:hook (org-mode . dw/org-mode-setup)
;;   :config
;;   (setq org-ellipsis "..."
;;         org-hide-emphasis-markers t)
;;   (add-hook 'org-mode-hook
;;  	(lambda ()
;;  	(flyspell-mode t)))
;;   (add-to-list 'org-emphasis-alist
;;         '("=" (:foreground "indian red")
;;          ))

(eval-after-load 'org
   (setq org-startup-indented t)) ; Enable `org-indent-mode' by default

   
;; (use-package org-superstar
;;   :after org
;;   :hook (org-mode . org-superstar-mode)
;;   :custom
;;   ;; (org-superstar-remove-leading-stars t)
;;   (org-superstar-headline-bullets-list '("◉" "○" "●" "○" "●" "○" "●")))

;; ;; Replace list hyphen with dot
;; (font-lock-add-keywords 'org-mode
;;                         '(("^ *\\([-]\\) "
;;                             (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))

;; ;; Emacs from scractch config
;; (set-face-attribute 'org-document-title nil :font "Fira Mono" :weight 'bold :height 1.3)
;; (dolist (face '((org-level-1 . 1.2)
;;                 (org-level-2 . 1.1)
;;                 (org-level-3 . 1.05)
;;                 (org-level-4 . 1.0)
;;                 (org-level-5 . 1.1)
;;                 (org-level-6 . 1.1)
;;                 (org-level-7 . 1.1)
;;                 (org-level-8 . 1.1)))
;;   (set-face-attribute (car face) nil :font "Fira Mono" :weight 'medium :height (cdr face)))
;; )
;; ;; Alternative config
;; (let* ((variable-tuple
;; 				(cond ((x-list-fonts "ETBembo")         '(:font "ETBembo"))
;; 						((x-list-fonts "Source Sans Pro") '(:font "Source Sans Pro"))
;; 						((x-list-fonts "Lucida Grande")   '(:font "Lucida Grande"))
;; 						((x-list-fonts "Verdana")         '(:font "Verdana"))
;; 						((x-family-fonts "Sans Serif")    '(:family "Sans Serif"))
;; 						(nil (warn "Cannot find a Sans Serif Font.  Install Source Sans Pro."))))
;; 				(base-font-color     (face-foreground 'default nil 'default))
;; 				(headline           `(:inherit default :weight bold :foreground ,base-font-color)))

;; (custom-theme-set-faces
;; 		'user
;; 		`(org-level-8 ((t (,@headline ,@variable-tuple))))
;; 		`(org-level-7 ((t (,@headline ,@variable-tuple))))
;; 		`(org-level-6 ((t (,@headline ,@variable-tuple))))
;; 		`(org-level-5 ((t (,@headline ,@variable-tuple))))
;; 		`(org-level-4 ((t (,@headline ,@variable-tuple :height 1.1))))
;; 		`(org-level-3 ((t (,@headline ,@variable-tuple :height 1.1))))
;; 		`(org-level-2 ((t (,@headline ,@variable-tuple :height 1.2))))
;; 		`(org-level-1 ((t (,@headline ,@variable-tuple :height 1.3))))
;; 		`(org-document-title ((t (,@headline ,@variable-tuple :height 1.6 :underline nil))))))

;; Use this package if you want the text at the centre of the page.:
;; (defun dw/org-mode-visual-fill ()
;;   (setq visual-fill-column-width 110
;;         visual-fill-column-center-text t)
;;   (visual-fill-column-mode 1))

;; (use-package visual-fill-column
;;   :defer t
;;   :hook (org-mode . dw/org-mode-visual-fill))
;; ---------------------------------------------------------------------------------------

(use-package highlight-indentation)

(use-package highlight-indent-guides)
(add-hook 'prog-mode-hook 'highlight-indent-guides-mode)
(setq highlight-indent-guides-method 'character)

;; Unicode fonts
(defun dw/replace-unicode-font-mapping (block-name old-font new-font)
  (let* ((block-idx (cl-position-if
                         (lambda (i) (string-equal (car i) block-name))
                         unicode-fonts-block-font-mapping))
         (block-fonts (cadr (nth block-idx unicode-fonts-block-font-mapping)))
         (updated-block (cl-substitute new-font old-font block-fonts :test 'string-equal)))
    (setf (cdr (nth block-idx unicode-fonts-block-font-mapping))
          `(,updated-block))))

(use-package unicode-fonts
  :disabled
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

;; (use-package centaur-tabs
;;   :demand
;;   :ensure t
;;   :config
;;   (centaur-tabs-mode t)
;;   (setq centaur-tabs-style "box")
;;   (setq centaur-tabs-set-bar 'left)
;;   (setq centaur-tabs-set-modified-marker t)
;;   (setq centaur-tabs-height 32)
;;   (setq centaur-tabs-set-icons t)
;;   (setq centaur-tabs-gray-out-icons 'buffer)
;;   (setq centaur-tabs-set-bar 'over)
;;   (setq centaur-tabs-cycle-scope 'tabs)
;;   :bind
;;   ("C-c C-h" . centaur-tabs-backward)
;;   ("C-c C-l" . centaur-tabs-forward)
;;   (:map evil-normal-state-map
;; 	     ("K" . centaur-tabs-forward)
;; 	     ("J" . centaur-tabs-backward)))

(use-package helpful
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind
  ([remap describe-function] . helpful-function)
  ([remap describe-symbol] . helpful-symbol)
  ([remap describe-variable] . helpful-variable)
  ([remap describe-command] . helpful-command)
  ([remap describe-key] . helpful-key))

(use-package treemacs
  :ensure t
  :defer t
	:hook
	(treemacs-mode . (lambda() (display-line-numbers-mode -1))) ;Disable line numbers in treemacs.
  :config
  (progn
    (setq treemacs-width 25))
  :bind
  (:map global-map
        ("C-x t t"   . treemacs)
        ("C-x t C-t" . treemacs-find-file)
        ("C-x h" . treemacs-toggle-show-dotfiles)))

(use-package flycheck
  :ensure t
  :custom
  (flycheck-indication-mode 'left-fringe)
)

(use-package pdf-tools
  :ensure t
	:hook
	(pdf-view-mode . (lambda()
										 (display-line-numbers-mode 0)))
  :config
  (pdf-tools-install)
  (setq-default pdf-view-display-size 'fit-page)
  (setq pdf-annot-activate-created-annotations nil)
  (define-key pdf-view-mode-map (kbd "C-s") 'isearch-forward)
  (define-key pdf-view-mode-map (kbd "C-r") 'isearch-backward)
  ;; (add-hook 'pdf-view-mode-hook (lambda ()
  ;; 				  (bms/pdf-midnite-amber))) ; automatically turns on midnight-mode for pdfs
  )

(use-package auctex-latexmk
  :ensure t
  :config
  (auctex-latexmk-setup)
  (setq auctex-latexmk-inherit-TeX-PDF-mode t))

(use-package reftex
  :ensure t
  :defer t
  :config
  (setq reftex-cite-prompt-optional-args t)) ;; Prompt for empty optional arguments in cite

;; (use-package auto-dictionary
;;   :ensure t
;;   :init(add-hook 'flyspell-mode-hook (lambda () (auto-dictionary-mode 1))))

(use-package company-auctex
  :ensure t
  :init (company-auctex-init))

(use-package tex
  :ensure auctex
  :mode ("\\.tex\\'" . latex-mode)
  :config (progn
	    (setq TeX-source-correlate-mode t)
	    (setq TeX-source-correlate-method 'synctex)
	    (setq TeX-auto-save t)
	    (setq TeX-parse-self t)
	    (setq-default TeX-master "Master Thesis.tex")
	    (setq-default TeX-command-Show "LaTex")
	    (setq reftex-plug-into-AUCTeX t)
	    (pdf-tools-install)
	    (setq TeX-view-program-selection '((output-pdf "PDF Tools"))
		  TeX-source-correlate-start-server t)
	    ;; Update PDF buffers after successful LaTeX runs
	    (add-hook 'TeX-after-compilation-finished-functions
		      #'TeX-revert-document-buffer)
	    (add-hook 'LaTeX-mode-hook
		      (lambda ()
			(reftex-mode t)
			(flyspell-mode t)))
	    ))

;; Org-tree-slides ------------------------------------------------
(defun dw/org-start-presentation ()
  (interactive)
  (org-tree-slide-mode 1)
  (setq text-scale-mode-amount 3)
  (text-scale-mode 1))

(defun dw/org-end-presentation ()
  (interactive)
  (text-scale-mode 0)
  (org-tree-slide-mode 0))

(use-package org-tree-slide
  :defer t
  :after org
  :commands org-tree-slide-mode
  :config
  (evil-define-key 'normal org-tree-slide-mode-map
    (kbd "q") 'dw/org-end-presentation
    (kbd "C-j") 'org-tree-slide-move-next-tree
    (kbd "C-k") 'org-tree-slide-move-previous-tree)
  (setq org-tree-slide-slide-in-effect nil
        org-tree-slide-activate-message "Presentation started."
        org-tree-slide-deactivate-message "Presentation ended."
        org-tree-slide-header t))

(use-package deft
  :commands (deft)
  :config (setq deft-directory "/mnt/Data/MEGA/Notes"
                deft-recursive t
		deft-use-filename-as-title t
                deft-extensions '("md" "org" "txt")))

;; (use-package org-roam
;;   :hook
;;   (after-init . org-roam-mode)
;;   :custom
;;   (org-roam-directory "/mnt/08542B6A542B59A8/MEGA/Notes/Roam")
;;   (org-roam-completion-everywhere t)
;;   (org-roam-completion-system 'default)
;;   :bind (:map org-roam-mode-map
;;           (("C-c n r"   . org-roam)
;;            ("C-c n f"   . org-roam-node-find)
;;            ("C-c n l"   . org-roam-buffer-toggle)
;;            ("C-c n d"   . org-roam-dailies-find-date)
;;            ("C-c n c"   . org-roam-dailies-capture-today)
;;            ("C-c n C r" . org-roam-dailies-capture-tomorrow)
;;            ("C-c n t"   . org-roam-dailies-find-today)
;;            ("C-c n y"   . org-roam-dailies-find-yesterday)
;;            ("C-c n r"   . org-roam-dailies-find-tomorrow)
;;            ("C-c n g"   . org-roam-graph))
;;          :map org-mode-map
;;          (("C-c n i" . org-roam-node-insert))
;;          (("C-c n I" . org-roam-insert-immediate))))
(use-package org-roam
      :ensure t
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

;; Dashboard
;; (require 'dashboard)
;; (dashboard-setup-startup-hook)
;; (leaf page-break-lines
;;   :hook (dashboard-mode-hook . page-break-lines-mode))
;; ;; Or if you use use-package
(use-package dashboard
  :ensure t
  :config
  (dashboard-setup-startup-hook)
  ;; Set the title
  (setq dashboard-banner-logo-title "And now for something completely different")
  ;; Set the banner
  (setq dashboard-startup-banner 'logo)
  ;; Value can be
  ;; 'official which displays the official emacs logo
  ;; 'logo which displays an alternative emacs logo
  ;; 1, 2 or 3 which displays one of the text banners
  ;; "path/to/your/image.gif", "path/to/your/image.png" or "path/to/your/text.txt" which displays whatever gif/image/text you would prefer
  
  ;; Content is not centered by default. To center, set
  (setq dashboard-center-content t)
	(setq dashboard-page-separator "\n\f\n")
  (setq dashboard-set-heading-icons t)
  (setq dashboard-set-file-icons t)
  (setq dashboard-items '((recents  . 7)
                          (bookmarks . 10)
                          (agenda . 5)
                          ))
  (setq dashboard-set-navigator t))
  ;; To disable shortcut "jump" indicators for each section, set
  ;; (setq dashboard-show-shortcuts nil))

;; Sr-Speedbar
(require 'sr-speedbar)
(use-package sr-speedbar
  :ensure t
	:bind
	(("C-M-s" . sr-speedbar-toggle))
	:config
	(setq sr-speedbar-width 20)
  ;; Start Sr-Speedbar in buffer mode by default
  (add-hook 'speedbar-mode-hook
            (lambda ()
              (speedbar-change-initial-expansion-list "quick buffers")))
	)

;; (use-package eaf
;;   :load-path "/home/mattia/.config/emacs/site-lisp/emacs-application-framework/" ; Set to "/usr/share/emacs/site-lisp/eaf" if installed from AUR
;;   :custom
;;   ; See https://github.com/emacs-eaf/emacs-application-framework/wiki/Customization
;;   (eaf-browser-continue-where-left-off t)
;;   (eaf-browser-enable-adblocker t)
;;   (browse-url-browser-function 'eaf-open-browser)
;; 	:bind
;;   (("C-c h" . eaf-py-proxy-add_annot_highlight))	
;;   :config
;; 	(setq eaf-pdf-dark-mode nil))

;; (require 'eaf-browser)
;; (require 'eaf-pdf-viewer)
;; (require 'eaf-music-player)
;; (require 'eaf-file-manager)

(quelpa '(pdf-continuous-scroll-mode :fetcher github :repo "dalanicolai/pdf-continuous-scroll-mode.el"))

(use-package ranger
	:ensure t
	:hook
	(ranger-mode . (lambda()
									 (ranger-override-dired-mode t)
									 (display-line-numbers-mode 0)))
	:config
	(setq ranger-parent-depth 1)
	(setq ranger-preview-file t)
	(setq ranger-width-preview 0.55)
	)
;; ;; EXWM Configuration -----------------------------
(defun efs/exwm-update-class ()
  (exwm-workspace-rename-buffer exwm-class-name))

(defun efs/run-in-background (command)
	(let ((command-parts (split-string command "[ ]+")))
			(apply #'call-process `(,(car command-parts) nil 0 nil ,@(cdr command-parts)))))

(defun dw/exwm-init-hook ()
;; Make workspace 1 be the one where we land at startup
	; (exwm-workspace-switch-create 1)

	;; Launch apps that will run in the background
	(efs/run-in-background "nm-applet"))

;; Set wallpaper
(defun efs/set-wallpaper ()
  (interactive)
  (start-process-shell-command
   "feh" nil  "feh --bg-scale /mnt/08542B6A542B59A8/Mattia/IMMAGINI/Pictures/Sfondi/00000nord.jpg"))

;; (use-package exwm
;;   :config
;;   ;; Set the default number of workspaces
;;   (setq exwm-workspace-number 9)

;;   ;; When window "class" updates, use it to set the buffer name
;;   (add-hook 'exwm-update-class-hook #'efs/exwm-update-class)
;;   ;; When EXWM starts up, do some extra confifuration
;;   ;;(add-hook 'exwm-init-hook #'efs/exwm-init-hook)
;;   ;; Rebind CapsLock to Ctrl
;;   (start-process-shell-command "/usr/bin/setxkbmap" nil "setxkbmap -option caps:swapescape")

;;   ;; Set the screen resolution (update this to be the correct resolution for your screen!)
;;   (require 'exwm-randr)
;;   (exwm-randr-enable)
;;   (start-process-shell-command "xrandr" nil "xrandr --output eDP-1 --primary --mode 1920x1080 --pos 0x0 --rotate normal --output HDMI-1 --off")
;; 	;; Call set wallpaper function
;; 	(efs/set-wallpaper)

;;   ;; Load the system tray before exwm-init
;;   (require 'exwm-systemtray)
;;   (exwm-systemtray-enable
;; )

;;   ;; These keys should always pass through to Emacs and not to the selected window
;;   (setq exwm-input-prefix-keys
;;     '(?\C-x
;;       ?\C-h
;;       ?\M-`
;;       ?\M-&
;;       ?\C-:
;;       ?\C-c b  ;; ibuffer
;; 			?\C-x b
;;       ?\C-\ ))  ;; Ctrl+Space

;;   ;; Ctrl+Q will enable the next key to be sent directly
;;   (define-key exwm-mode-map [?\C-q] 'exwm-input-send-next-key)

;;   ;; Set up global key bindings.  These always work, no matter the input state!
;;   ;; Keep in mind that changing this list after EXWM initializes has no effect.
;;   (setq exwm-input-global-keys
;;         `(
;;           ;; Reset to line-mode (C-c C-k switches to char-mode via exwm-input-release-keyboard)
;;           ([?\s-r] . exwm-reset)

;;           ;; Move between windows
;;           ([?\s-h] . windmove-left)
;;           ([?\s-l] . windmove-right)
;;           ([?\s-k] . windmove-up)
;;           ([?\s-j] . windmove-down)

;;           ;; Launch applications via shell command
;;           ([?\s-&] . (lambda (command)
;;                        (interactive (list (read-shell-command "$ ")))
;;                        (start-process-shell-command command nil command)))

;;           ;; Switch workspace
;;           ([?\s-w] . exwm-workspace-switch)
;;           ([?\s-`] . (lambda () (interactive) (exwm-workspace-switch-create 0)))

;;           ;; 's-N': Switch to certain workspace with Super (Win) plus a number key (0 - 9)
;;           ,@(mapcar (lambda (i)
;;                       `(,(kbd (format "s-%d" i)) .
;;                         (lambda ()
;;                           (interactive)
;;                           (exwm-workspace-switch-create ,i))))
;;                     (number-sequence 0 9))))

;;   (exwm-enable))
;; ;; -----------------------------------------------------------------------------------------------
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(company-box-icons-alist 'company-box-icons-images)
 '(company-show-quick-access t nil nil "Customized with use-package company")
 '(custom-safe-themes
	 '("f94110b35f558e4c015b2c680f150bf8a19799d775f8352c957d9d1054b0a210" "fce3524887a0994f8b9b047aef9cc4cc017c5a93a5fb1f84d300391fba313743" default))
 '(inhibit-startup-screen t)
 '(mlint-programs
	 '("/home/mattia/.config/emacs/elpa/matlab-mode-20210410.1340/mlint.el" "glnxa64/mlint"))
 '(package-selected-packages
	 '(sql-indent emacsql-mysql emacsql-psql sqlite3 emacsql-libsqlite3 org-roam-ui pdf-tools pdf-continuous-scroll-mode quelpa project-root magithub treemacs-magit magit treemacs-projectile dap-mode ivy-posframe mini-frame ipython-shell-send mixed-pitch setup atom-one-dark-theme ujelly-theme sr-speedbar dashboard projectile page-break-lines helm buffer-move exwm yasnippet-classic-snippets zones graphviz-dot-mode rainbow-mode org-roam deft org-tree-slide ranger company-box ivy-bibtex company-bibtex auto-dictionary auctex-latexmk company-auctex auctex latex-math-preview latex-preview-pane lsp-latex latex-unicode-math-mode textx-mode lsp-treemacs flycheck multiple-cursors treemacs-evil treemacs helpful lsp-pyright python-mode centaur-tabs workgroups persp-mode tabbar visual-fill-column visual-fill org-superstar org-bullets unicode-fonts highlight-indent-guides highlight-indentation company-lua luarocks lua-mode lsp-jedi company-quickhelp lsp-ui ess auto-complete matlab-mode evil-collection autopair undo-tree evil general which-key rainbow-delimiters nlinum-relative all-the-icons doom-modeline counsel use-package ivy)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(lsp-face-highlight-read ((t (:background "dark slate grey"))))
 '(lsp-face-highlight-textual ((t (:background "dark slate grey"))))
 '(lsp-face-highlight-write ((t (:background "dark slate grey"))))
 '(lsp-ui-doc-background ((t (:background nil))))
 '(lsp-ui-doc-header ((t (:inherit (font-lock-string-face italic)))))
 '(org-block ((t (:inherit fixed-pitch))))
 '(org-code ((t (:inherit (shadow fixed-pitch)))))
 '(org-document-info ((t (:foreground "dark orange"))))
 '(org-document-info-keyword ((t (:inherit (shadow fixed-pitch)))))
 '(org-link ((t (:inherit fixed-pitch :foreground "SkyBlue2" :underline t :bold nil))))
 '(org-meta-line ((t (:inherit (font-lock-comment-face fixed-pitch)))))
 '(org-property-value ((t (:inherit fixed-pitch))) t)
 '(org-special-keyword ((t (:inherit (font-lock-comment-face fixed-pitch)))))
 '(org-table ((t (:inherit fixed-pitch :foreground "#83a598"))))
 '(org-tag ((t (:inherit (shadow fixed-pitch) :weight bold :height 0.8))))
 '(org-verbatim ((t (:inherit (shadow fixed-pitch))))))