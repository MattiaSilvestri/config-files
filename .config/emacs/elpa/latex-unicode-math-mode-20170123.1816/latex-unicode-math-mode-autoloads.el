;;; latex-unicode-math-mode-autoloads.el --- automatically extracted autoloads
;;
;;; Code:

(add-to-list 'load-path (directory-file-name
                         (or (file-name-directory #$) (car load-path))))


;;;### (autoloads nil "latex-unicode-math-mode" "latex-unicode-math-mode.el"
;;;;;;  (0 0 0 0))
;;; Generated autoloads from latex-unicode-math-mode.el

(autoload 'latex-unicode-math-mode "latex-unicode-math-mode" "\
Dynamically enable the Unicode math input method in LaTeX math mode.

If called interactively, enable Latex-Unicode-Math mode if ARG is
positive, and disable it if ARG is zero or negative.  If called
from Lisp, also enable the mode if ARG is omitted or nil, and
toggle it if ARG is `toggle'; disable the mode otherwise.

\(fn &optional ARG)" t nil)

(autoload 'latex-unicode-mode "latex-unicode-math-mode" "\
Enable the Unicode math input method everywhere in the buffer.

If called interactively, enable Latex-Unicode mode if ARG is
positive, and disable it if ARG is zero or negative.  If called
from Lisp, also enable the mode if ARG is omitted or nil, and
toggle it if ARG is `toggle'; disable the mode otherwise.

\(fn &optional ARG)" t nil)

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "latex-unicode-math-mode" '("latex-unicode-")))

;;;***

;;;### (autoloads nil nil ("latex-unicode-math-mode-pkg.el") (0 0
;;;;;;  0 0))

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; coding: utf-8
;; End:
;;; latex-unicode-math-mode-autoloads.el ends here
