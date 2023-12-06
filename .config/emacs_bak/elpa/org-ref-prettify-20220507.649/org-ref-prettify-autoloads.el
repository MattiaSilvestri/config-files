;;; org-ref-prettify-autoloads.el --- automatically extracted autoloads  -*- lexical-binding: t -*-
;;
;;; Code:

(add-to-list 'load-path (directory-file-name
                         (or (file-name-directory #$) (car load-path))))


;;;### (autoloads nil "org-ref-prettify" "org-ref-prettify.el" (0
;;;;;;  0 0 0))
;;; Generated autoloads from org-ref-prettify.el

(autoload 'org-ref-prettify-mode "org-ref-prettify" "\
Toggle Org Ref Prettify mode.

This is a minor mode.  If called interactively, toggle the
`Org-Ref-Prettify mode' mode.  If the prefix argument is
positive, enable the mode, and if it is zero or negative, disable
the mode.

If called from Lisp, toggle the mode if ARG is `toggle'.  Enable
the mode if ARG is nil, omitted, or is a positive number.
Disable the mode if ARG is a negative number.

To check whether the minor mode is enabled in the current buffer,
evaluate `org-ref-prettify-mode'.

The mode's hook is called both when the mode is enabled and when
it is disabled.

\\{org-ref-prettify-mode-map}

\(fn &optional ARG)" t nil)

(autoload 'org-ref-prettify-edit-link-at-point "org-ref-prettify" "\
Edit the current citation link in the minibuffer.
WHERE means where the point should be put in the minibuffer.  If
it is nil, try to be smart about its placement; otherwise, it can
be one of: `type', `beg', or `end'.

\(fn &optional WHERE)" t nil)

(autoload 'org-ref-prettify-edit-link-at-mouse "org-ref-prettify" "\
Edit the citation link at mouse position in the minibuffer.
This should be bound to a mouse click EVENT type.
See `org-ref-prettify-edit-link-at-point' for the meaning of WHERE.

\(fn EVENT &optional WHERE)" t nil)

(register-definition-prefixes "org-ref-prettify" '("org-ref-prettify-"))

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; coding: utf-8
;; End:
;;; org-ref-prettify-autoloads.el ends here
