;;; pdf-continuous-scroll-mode-autoloads.el --- automatically extracted autoloads
;;
;;; Code:

(add-to-list 'load-path (directory-file-name
                         (or (file-name-directory #$) (car load-path))))


;;;### (autoloads nil "pdf-continuous-scroll-mode" "pdf-continuous-scroll-mode.el"
;;;;;;  (0 0 0 0))
;;; Generated autoloads from pdf-continuous-scroll-mode.el

(with-eval-after-load 'pdf-view (define-key pdf-view-mode-map "c" #'pdf-continuous-scroll-mode))

(autoload 'pdf-continuous-scroll-mode "pdf-continuous-scroll-mode" "\
Emulate continuous scroll with two synchronized buffers

If called interactively, enable Pdf-Continuous-Scroll mode if ARG
is positive, and disable it if ARG is zero or negative.  If
called from Lisp, also enable the mode if ARG is omitted or nil,
and toggle it if ARG is `toggle'; disable the mode otherwise.

\(fn &optional ARG)" t nil)

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "pdf-continuous-scroll-mode" '("pdf-c")))

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; coding: utf-8
;; End:
;;; pdf-continuous-scroll-mode-autoloads.el ends here
