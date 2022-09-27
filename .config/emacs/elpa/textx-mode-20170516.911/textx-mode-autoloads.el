;;; textx-mode-autoloads.el --- automatically extracted autoloads
;;
;;; Code:

(add-to-list 'load-path (directory-file-name
                         (or (file-name-directory #$) (car load-path))))


;;;### (autoloads nil "textx-mode" "textx-mode.el" (0 0 0 0))
;;; Generated autoloads from textx-mode.el

(autoload 'textx-mode "textx-mode" "\


\(fn)" t nil)

(add-to-list 'auto-mode-alist '("\\.tx\\'" . textx-mode))

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "textx-mode" '("textx-")))

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; coding: utf-8
;; End:
;;; textx-mode-autoloads.el ends here
