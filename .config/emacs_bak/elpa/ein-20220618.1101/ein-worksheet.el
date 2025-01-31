;;; ein-worksheet.el --- Worksheet module    -*- lexical-binding:t -*-

;; Copyright (C) 2012 Takafumi Arakaki

;; Author: Takafumi Arakaki <aka.tkf at gmail.com>
;; Author: John M. Miller <millejoh at mac.com>

;; This file is NOT part of GNU Emacs.

;; ein-worksheet.el is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; ein-worksheet.el is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with ein-worksheet.el.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;;

;;; Code:

(require 'eieio)
(require 'ewoc)

(require 'ein-core)
(require 'ein-utils)
(require 'ein-cell)
(require 'ein-kill-ring)
(require 'warnings)
(require 'poly-ein)
(require 'seq)

;;; Configuration

;; (define-obsolete-variable-alias
;;   'ein:notebook-enable-undo 'ein:worksheet-enable-undo "0.2.0")

(defconst ein:worksheet--max-buffer-undo-list-length 2000
  "Emacs gc's buffer-undo-list at `undo-limit` size *bytes* which
we can't know in elisp-space.  So conservatively prune buffer-undo-list
at a certain length (which at time of writing is 2000).

Alas, this is bound to fail eventually (a big change drives gc while
buffer-undo-list is still under the threshold.")

(defcustom ein:worksheet-warn-obsolesced-keybinding t
  "Warn of keybindings we arbitrarily obsolesce."
  :type 'boolean
  :group 'ein)

(defcustom ein:worksheet-enable-undo t
  "When non-`nil', allow undo of cell inputs only (as opposed to
  whole-cell operations such as killing, moving, executing cells).

  Changes to this variable only take effect for newly opened worksheets."
  :type 'boolean
  :group 'ein)

(ein:deflocal buffer-local-enable-undo t
  "Buffer local variable activating undo accounting.  Should not modify.")

(ein:deflocal ein:%cell-lengths% nil
  "Buffer local variable with buffer-undo-list's current knowledge of cell lengths.")

(ein:deflocal ein:%which-cell% nil
  "Buffer local variable one-to-one buffer-undo-list item to cell id.")

(defsubst ein:worksheet--unique-enough-cell-id (cell)
  "Gets the first five characters of an md5sum.
How far I can get without r collisions follows a negative
binomial with p=1e-6 (should go pretty far)."
  (intern (substring (slot-value cell 'cell-id) 0 5)))

(defun ein:worksheet--which-cell-hook (change-beg change-end _prev-len)
  "This is a costly after-change-functions hook.
Normalize `buffer-undo-list' by removing extraneous details, and
update the ein:%which-cell% ledger that associates changes in
`buffer-undo-list' with individual cells."
  (when (and buffer-undo-list (listp buffer-undo-list))
    (setq buffer-undo-list
          (cl-delete-if
           (lambda (u) (or (numberp u) (and (consp u) (markerp (car u)))))
           buffer-undo-list))
    (let ((fill (- (length buffer-undo-list) (length ein:%which-cell%))))
      (if (< fill 0)
          (progn
            (ein:log 'debug "truncating %s to %s: %S -> %S"
                     (length ein:%which-cell%) (length buffer-undo-list)
                     ein:%which-cell% (nthcdr (- fill) ein:%which-cell%))
            (setq ein:%which-cell% (nthcdr (- fill)  ein:%which-cell%)))
        (when (> fill 0)
          (let ((cell-id (awhen (ein:worksheet-get-current-cell :noerror t)
                           (ein:worksheet--unique-enough-cell-id it))))
            (setq ein:%which-cell%
                  (nconc (make-list fill cell-id) ein:%which-cell%))
            (let ((ein:log-print-level 5))
              (ein:log 'debug "which-cell (%s . %s) %s %S fill=%s"
                       change-beg change-end cell-id
                       (cl-subseq buffer-undo-list 0 fill)
                       fill))))))))

(defun ein:worksheet--next-cell-start (cell)
  (let ((cell1 (ein:cell-next cell)))
    (if cell1
        (ein:worksheet--element-start cell1 :prompt)
      (ein:with-live-buffer (ein:cell-buffer cell) (point-max)))))

(defun ein:worksheet--element-start (cell key &optional cached)
  (if cached
      (plist-get (nth 4 (plist-get ein:%cell-lengths% (slot-value cell 'cell-id))) key)
    (let ((node (ein:cell-element-get cell key (if (eq key :output) 0))))
      (if node
          (marker-position (ewoc-location node))
        (if (eq key :output)
            (ein:worksheet--element-start cell :footer))))))

(defsubst ein:worksheet--saved-input-length (cell)
  (or (cl-fourth (plist-get ein:%cell-lengths% (slot-value cell 'cell-id))) 0))

(defsubst ein:worksheet--prompt-length (cell &optional cached)
  (if cached
      (or (cl-first (plist-get ein:%cell-lengths% (slot-value cell 'cell-id))) 0)
    ;; 1+ for newline
    (1+ (- (ein:worksheet--element-start cell :input)
           (ein:worksheet--element-start cell :prompt)))))

(defsubst ein:worksheet--output-length (cell &optional cached)
  (if cached
      ;; 1 for when cell un-executed, there is still a newline
      (or (cl-second (plist-get ein:%cell-lengths% (slot-value cell 'cell-id))) 1)
    (if (string= (slot-value cell 'cell-type) "code")
      (- (ein:worksheet--next-cell-start cell)
         (ein:worksheet--element-start cell :output))
      0)))

(defsubst ein:worksheet--total-length (cell &optional cached)
  (if cached
      (or (cl-third (plist-get ein:%cell-lengths% (slot-value cell 'cell-id))) 0)
    (- (ein:worksheet--next-cell-start cell)
       (ein:worksheet--element-start cell :prompt))))

(defun ein:worksheet--update-cell-lengths (cell &optional saved-input-length)
  (setq ein:%cell-lengths% (plist-put ein:%cell-lengths% (slot-value cell 'cell-id)
                                      (list (ein:worksheet--prompt-length cell)
                                            (ein:worksheet--output-length cell)
                                            (ein:worksheet--total-length cell)
                                            (or saved-input-length (ein:worksheet--saved-input-length cell))))))

;; can use apply-partially instead here
(defmacro hof-add (distance)
  "Return function that adds signed DISTANCE those undo elements.
'hof' refers to higher-order function,"
  `(lambda (u)
     (cond ((numberp u)
            (+ u ,distance))
           ((and (consp u) (numberp (car u)) (numberp (cdr u)))
            (cons (+ ,distance (car u))
                  (+ ,distance (cdr u))))
           ((and (consp u) (stringp (car u)) (numberp (cdr u)))
            (cons (car u)
                  (* (if (< (cdr u) 0) -1 1) (+ ,distance (abs (cdr u))))))
           ((and (consp u) (markerp (car u)))
            (let ((mp (marker-position (car u))))
              (if mp
                  (let ((m (set-marker (make-marker) (+ ,distance mp) (marker-buffer (car u)))))
                    (cons m (cdr u)))
                u)))
           ((and (consp u) (null (car u))
                 (numberp (car (last u))) (numberp (cdr (last u))))
            (append (cl-subseq u 0 3)
                    (cons (+ ,distance (car (last u)))
                          (+ ,distance (cdr (last u))))))
           ((and (consp u) (eq (car u) 'apply)
                 (numberp (nth 2 u)) (numberp (nth 3 u)))
            (append (cl-subseq u 0 2)
                    (list (+ ,distance (nth 2 u)))
                    (list (+ ,distance (nth 3 u)))
                    (nthcdr 4 u)))
           (t u))))

(defun ein:worksheet--get-ids-after (cell)
  (let ((cell0 cell) result)
    (while (ein:cell-next cell0)
      (setq result (plist-put result (ein:worksheet--unique-enough-cell-id (ein:cell-next cell0)) t))
      (setq cell0 (ein:cell-next cell0)))
    result))

(defun ein:worksheet--jigger-undo-list (&optional change-cell-id)
  "Nobody said it was easy.
No one ever said it would be this hard.
-- Martin et al."
  (cl-assert (listp buffer-undo-list))
  (let ((len-buffer-undo-list (length buffer-undo-list))
	(len-which-cell (length ein:%which-cell%)))
    (when (/= len-buffer-undo-list len-which-cell)
      (ein:log 'debug "jig %s to %s: %S %S"
	       len-which-cell len-buffer-undo-list
	       buffer-undo-list ein:%which-cell%))
    (-when-let* ((old-cell-id (car change-cell-id))
		 (new-cell-id (cdr change-cell-id))
		 (changed-p (not (eq old-cell-id new-cell-id))))
      (setq ein:%which-cell% (-replace old-cell-id new-cell-id ein:%which-cell%)))
    (let (multiple-cursors-p
	  (fill (- len-buffer-undo-list len-which-cell)))
      (cond ((and
	      (> (abs fill) 1)
	      (not (setq multiple-cursors-p
			 (cl-some
			  (lambda (entry)
			    (cl-flet ((check
				       (entry bogey)
				       (and (listp entry)
					    (not (atom (cdr entry)))
					    (eq (nth 1 entry) bogey))))
			      (or (check entry 'activate-cursor-for-undo)
				  (check entry 'deactivate-cursor-after-undo))))
			  (cl-subseq buffer-undo-list 0 (min len-buffer-undo-list 30))))))
	     (let ((msg (format "Undo failure diagnostic %s %s | %s"
				buffer-undo-list ein:%which-cell% fill))
		   (pm-allow-post-command-hook nil))
	       (setq ein:worksheet-enable-undo nil)
	       (ein:worksheet-undo-setup ein:%worksheet%)
	       (when pm/polymode
		 (dolist (b (eieio-oref pm/polymode '-buffers))
		   (when (buffer-live-p b)
		     (poly-ein--copy-state (ein:worksheet--get-buffer ein:%worksheet%) b))))
	       (ein:display-warning msg :error)
	       (error "ein:worksheet--jigger-undo-list: aborting")))
	    ((< fill 0)
	     (setq ein:%which-cell% (nthcdr (- fill) ein:%which-cell%)))
	    ((> fill 0)
	     (when (and (> fill 1) multiple-cursors-p)
	       (ein:log 'debug "multiple-cursors-mode exception fill %s" fill))
	     (setq ein:%which-cell% (nconc (make-list fill (car ein:%which-cell%))
				       ein:%which-cell%)))))
    (let ((len-a (length buffer-undo-list))
          (len-b (length ein:%which-cell%))
          (limit ein:worksheet--max-buffer-undo-list-length))
      (cl-assert (= len-a len-b) t
	         "ein:worksheet--jigger-undo-list %d != %d" len-a len-b)
      (when (> len-a limit)
        (setq buffer-undo-list (seq-take buffer-undo-list limit)
              ein:%which-cell% (seq-take ein:%which-cell% limit))
        (ein:log 'debug "ein:worksheet--jigger-undo-list: trim from %s to %s in %s"
                 len-a limit (buffer-name))))))

(defun ein:worksheet--unshift-undo-list (cell &optional exogenous-input old-cell)
  "Adjust `buffer-undo-list' for adding CELL.
Unshift in list parlance means prepending to list."
  (unless old-cell
    (setq old-cell cell))
  (when buffer-local-enable-undo
    (ein:with-live-buffer (ein:cell-buffer cell)
      (if (listp buffer-undo-list)
          (let* ((opl (ein:worksheet--prompt-length old-cell t))
                 (ool (ein:worksheet--output-length old-cell t))
                 (otl (ein:worksheet--total-length old-cell t))
                 (npl (ein:worksheet--prompt-length cell))
                 (nol (ein:worksheet--output-length cell))
                 (ntl (ein:worksheet--total-length cell))
                 (pdist (- npl opl))
                 (odist (- nol ool))
                 (has-output (memq :output (slot-value cell 'element-names)))
                 (old-has-output (memq :output (slot-value old-cell 'element-names)))
                 (converted-newline (if (eq has-output old-has-output) 0
                                      (if has-output -1 1)))
                 (after-ids (ein:worksheet--get-ids-after cell))
                 (func-same-cell (hof-add pdist))
                 (func-after-cell (hof-add (if (zerop otl)
                                               ntl (+ pdist odist converted-newline))))
                 lst)
            (ein:log 'debug "unsh trig=%s pdist=%s odist=%s otl=%s ntl=%s conv=%s"
                     (ein:worksheet--unique-enough-cell-id cell) pdist odist otl ntl converted-newline)
            (ein:worksheet--jigger-undo-list
             (cons (ein:worksheet--unique-enough-cell-id old-cell)
                   (ein:worksheet--unique-enough-cell-id cell)))
            (dolist (uc (cl-mapcar #'cons buffer-undo-list ein:%which-cell%))
              (let ((u (car uc))
                    (cell-id (or (cdr uc) "")))
                (if (string= (ein:worksheet--unique-enough-cell-id cell) cell-id)
                    (push (funcall func-same-cell u) lst)
                  (if (plist-member after-ids cell-id)
                      (progn
                        (ein:log 'debug "unsh adj %s %s" u cell-id)
                        (push (funcall func-after-cell u) lst))
                    (push u lst)))))
            (cl-assert (= (length buffer-undo-list) (length lst)) t
                       "ein:worksheet--unshift-undo-list %d != %d"
                       (length buffer-undo-list) (length lst))
            (setq buffer-undo-list (nreverse lst))
            (ein:worksheet--update-cell-lengths cell exogenous-input))
        (ein:log 'debug "ein:worksheet--unshift-undo-list: buffer-undo-list %s in %s"
                 buffer-undo-list (ein:cell-buffer cell))))))

(defun ein:worksheet--calc-offset (u)
  "Return length of inserted (or uninserted) text corresponding to undo entry U."
  (cond ((and (consp u) (numberp (car u)) (numberp (cdr u)))
         (- (cdr u) (car u)))
        ((and (consp u) (stringp (car u)) (numberp (cdr u)))
         (- (length (car u))))
        (t 0)))

(defun ein:worksheet--shift-undo-list (cell)
  "Adjust `buffer-undo-list' for deleting CELL.
Shift in list parlance means removing the front."
  (when buffer-local-enable-undo
    (ein:with-live-buffer (ein:cell-buffer cell)
      (if (listp buffer-undo-list)
          (let* ((pdist (ein:worksheet--prompt-length cell))
                 (odist (ein:worksheet--output-length cell))
                 (sdist (ein:worksheet--saved-input-length cell))
                 (after-ids (ein:worksheet--get-ids-after cell))
                 (offset 0)
                 lst wc)
            (ein:log 'debug "shft trig=%s pdist=%s odist=%s sdist=%s" (ein:worksheet--unique-enough-cell-id cell) pdist odist sdist)
            (ein:worksheet--jigger-undo-list)
            ;; Deletion of a less recent undo affects a more recent undo (arrow of time)
            ;; Since buffer-undo-list is ordered most to least recent, we must
            ;; reverse.
            (dolist (uc (nreverse (cl-mapcar #'cons buffer-undo-list ein:%which-cell%)))
              (let ((u (car uc))
                    (cell-id (or (cdr uc) "")))
                (if (string= (ein:worksheet--unique-enough-cell-id cell) cell-id)
                    (progn
                      (setq offset (+ offset (ein:worksheet--calc-offset u)))
                      (ein:log 'debug "shft del %s (%s) %s" u (ein:worksheet--calc-offset u) cell-id))
                  (push (cdr uc) wc)
                  (if (plist-member after-ids cell-id)
                      (progn
                        (ein:log 'debug "shft adj %s %s" u cell-id)
                        ;; 1 for when cell un-executed, there is still a newline
                        (push (funcall (hof-add (- (+ 1 offset pdist odist sdist))) u) lst))
                    (push u lst)))))
            (setq buffer-undo-list lst)
            (setq ein:%which-cell% wc)
            (ein:worksheet--jigger-undo-list)
            (cl-remprop 'ein:%cell-lengths% (slot-value cell 'cell-id)))
        (ein:log 'debug "ein:worksheet--shift-undo-list: buffer-undo-list %s in %s"
                 buffer-undo-list (ein:cell-buffer cell))))))

(ein:deflocal ein:%worksheet% nil
  "Buffer local variable to store an instance of `ein:worksheet'.")

(defun ein:worksheet-new (nbformat notebook-path kernel events &rest args)
  (apply #'make-instance 'ein:worksheet
         :nbformat nbformat
	 :notebook-path notebook-path
         :kernel kernel
	 :events events
         args))

(cl-defmethod ein:worksheet-bind-events ((ws ein:worksheet))
  (with-slots (events) ws
    ;; Bind events for sub components:
    (mapc (lambda (cell) (setf (slot-value cell 'events) events))
          (ein:worksheet-get-cells ws))))

(defun ein:worksheet-class-bind-events (events)
  "Binds event handlers which are not needed to be bound per instance."
  (ein:events-on events
                 'maybe_reset_undo.Worksheet
                 (lambda (_ignore cell)
                   (ein:worksheet--unshift-undo-list cell)))
  (ein:events-on events 'set_next_input.Worksheet
                 #'ein:worksheet--set-next-input)
  (ein:events-on events 'set_dirty.Worksheet #'ein:worksheet--set-dirty))

(defun ein:worksheet--set-next-input (_ignore data)
  (cl-destructuring-bind (&key cell text) data
    (ein:with-live-buffer (ein:cell-buffer cell)
      (ein:and-let* ((ws ein:%worksheet%)
                     (new-cell
                      (ein:worksheet-insert-cell-below ws 'code cell)))
        (ein:cell-set-text new-cell text)
        (setf (slot-value ws 'dirty) t)))))

(defun ein:worksheet--set-dirty (_ignore data)
  "Set dirty flag of worksheet in which CELL in DATA locates."
  (cl-destructuring-bind (&key value cell) data
    (ein:with-live-buffer (ein:cell-buffer cell)
      (ein:worksheet-set-modified-p ein:%worksheet% value))))

(cl-defmethod ein:worksheet-notebook-path ((ws ein:worksheet))
  (funcall (ein:worksheet--notebook-path ws)))

(cl-defmethod ein:worksheet-url-or-port ((ws ein:worksheet))
  (ein:kernel-url-or-port (ein:worksheet--kernel ws)))

(cl-defmethod ein:worksheet-buffer ((ws ein:worksheet))
  (ein:and-let* (((slot-boundp ws :ewoc))
                 (ewoc (ein:worksheet--ewoc ws))
                 (buffer (ewoc-buffer ewoc))
                 ((buffer-live-p buffer)))
    buffer))

(cl-defmethod ein:worksheet--buffer-name ((ws ein:worksheet))
  (format "*ein: %s/%s*" (ein:worksheet-url-or-port ws) (ein:worksheet-notebook-path ws)))

(cl-defmethod ein:worksheet--get-buffer ((ws ein:worksheet))
  (or (ein:worksheet-buffer ws)
      (with-current-buffer (generate-new-buffer (ein:worksheet--buffer-name ws))
        (prog1 (current-buffer)
          (unless (eq font-lock-support-mode 'jit-lock-mode)
            (ein:log 'info "ein:worksheet--get-buffer: deactivating %s in %s"
                     font-lock-support-mode (buffer-name))
            (setq-local font-lock-support-mode 'jit-lock-mode))
          (let ((buffer-undo-list t))
            (setf (ein:worksheet--ewoc ws)
                  (ein:ewoc-create 'ein:worksheet-pp
                                   (ein:propertize-read-only "\n")
                                   nil t)))))))

(cl-defmethod ein:worksheet-set-buffer-name ((ws ein:worksheet))
  (ein:with-live-buffer (ein:worksheet-buffer ws)
    (dolist (b (or (and pm/polymode (eieio-oref pm/polymode '-buffers))
                   (list (current-buffer))))
      (ein:with-live-buffer b
        (let* ((base-name (ein:worksheet--buffer-name ws))
               (impl-name
                (and pm/polymode
                     (not (eq (pm-base-buffer) (current-buffer)))
                     (format "%s%s[%s]" (if pm-hide-implementation-buffers " " "")
                             base-name
                             (replace-regexp-in-string
                              "poly-\\|-mode" ""
                              (symbol-name
                               (pm--get-existing-mode
                                (eieio-oref pm/chunkmode 'mode)
                                (eieio-oref pm/chunkmode 'fallback-mode)))))))
               (new-name (or impl-name base-name)))
          (unless (string= new-name (buffer-name b))
            (rename-buffer new-name)))))))

(cl-defmethod ein:worksheet-set-modified-p ((ws ein:worksheet) dirty)
  (ein:with-live-buffer (ein:worksheet-buffer ws)
    (set-buffer-modified-p dirty))
  (setf (slot-value ws 'dirty) dirty))

(cl-defmethod ein:worksheet-undo-setup ((ws ein:worksheet))
  (with-current-buffer (ein:worksheet--get-buffer ws)
    (setq buffer-local-enable-undo ein:worksheet-enable-undo)
    (let ((undo-binding (key-binding (kbd "C-/"))))
      (when (and buffer-local-enable-undo
                 (not (eq undo-binding 'undo)))
        (ein:log 'info "ein:worksheet-undo-setup: suspect undo `%s`."
                 undo-binding)))
    (ein:worksheet-reinstall-undo-hooks ws)
    (if buffer-local-enable-undo
        (progn
          (setq buffer-undo-list nil)
          (setq ein:%which-cell% nil)
          (setq ein:%cell-lengths% nil))
      (setq buffer-undo-list t))))

(cl-defmethod ein:worksheet-reinstall-undo-hooks ((ws ein:worksheet))
  (with-current-buffer (ein:worksheet--get-buffer ws)
    (if buffer-local-enable-undo
        (add-hook 'after-change-functions 'ein:worksheet--which-cell-hook nil t)
      (remove-hook 'after-change-functions 'ein:worksheet--which-cell-hook t))))

(cl-defmethod ein:worksheet-render ((ws ein:worksheet))
  (with-current-buffer (ein:worksheet--get-buffer ws)
    (setq ein:%worksheet% ws)
    (ein:worksheet-undo-setup ws)
    (let ((inhibit-read-only t)
          (ewoc (ein:worksheet--ewoc ws)))
      (if-let ((cells (ein:worksheet--saved-cells ws)))
          (let ((buffer-undo-list t))
            (mapc (lambda (c)
                    (setf (slot-value c 'ewoc) ewoc)
                    (ein:cell-enter-last c)
                    (ein:worksheet--update-cell-lengths c (- (ein:cell-input-pos-max c)
                                                             (ein:cell-input-pos-min c))))
                  cells))
        (ein:worksheet-insert-cell-below ws 'code nil t)))
    (set-buffer-modified-p nil)
    (ein:worksheet-bind-events ws)
    (ein:worksheet-set-kernel ws)))

(defun ein:worksheet-pp (ewoc-data)
  "Consider disabling `buffer-undo-list' here.
We currently disable in `ein:cell--ewoc-invalidate' which is probably
unnecessarily 'surgical'."
  (let ((path (ein:$node-path ewoc-data))
        (data (ein:$node-data ewoc-data)))
    (cl-case (car path)
      (cell (ein:cell-pp (cdr path) data)))))

(cl-defmethod ein:worksheet-from-json ((ws ein:worksheet) data)
  (cl-destructuring-bind (&key cells metadata &allow-other-keys) data
    (setf (slot-value ws 'metadata) metadata)
    (setf (slot-value ws 'saved-cells)
          (mapcar (lambda (data) (ein:cell-from-json data)) cells)))
  ws)

(cl-defmethod ein:worksheet-from-cells ((_ws ein:worksheet) _cells)
  )

(cl-defmethod ein:worksheet-to-json ((ws ein:worksheet))
  "Convert worksheet WS into JSON ready alist.
It sets buffer internally so that caller doesn not have to set
current buffer."
  (let* ((cells (ein:with-possibly-killed-buffer (ein:worksheet-buffer ws)
                  (mapcar (lambda (c)
                            (ein:cell-to-json c))
                          (ein:worksheet-get-cells ws)))))
    `((cells . ,(apply #'vector cells))
      ,@(ein:aand (ein:worksheet--metadata ws) `((metadata . ,it))))))

(cl-defmethod ein:worksheet-to-nb4-json ((ws ein:worksheet) wsidx)
  (let* ((cells (ein:with-possibly-killed-buffer (ein:worksheet-buffer ws)
                  (mapcar (lambda (c)
                            (ein:cell-to-nb4-json c wsidx))
                          (ein:worksheet-get-cells ws)))))
    cells))

(cl-defmethod ein:worksheet-save-cells ((ws ein:worksheet) &optional deactivate)
  "Save cells in worksheet buffer in cache before killing the buffer.

.. warning:: After called with non-nil DEACTIVATE flag is given,
   cells in worksheet cannot be used anymore.  Use only just
   before killing the buffer.

You don't need to set current buffer to call this function.
Do nothing when the worksheet WS has no buffer.

If the `:dont-save-cells' slot is non-nil (meaning that
`ein:worksheet-dont-save-cells' has been called), cells in the
worksheet buffer are not saved.  When the DEACTIVATE option is
given, cached cells are deactivated instead of the cells in
buffer.  Calling this function unconditionally resets
`:dont-save-cells' flag to nil to make caching work when the
worksheet WS is reopened.

\(fn ws deactivate)"
  (when (ein:worksheet-has-buffer-p ws)
    (unless (slot-value ws 'dont-save-cells)
      (let ((cells (ein:worksheet-get-cells ws)))
        (with-current-buffer (ein:worksheet-buffer ws)
          (mapc #'ein:cell-save-text cells))
        (when deactivate (mapc #'ein:cell-deactivate cells))
        (setf (slot-value ws 'saved-cells) cells)))
    (when deactivate
      (mapc #'ein:cell-deactivate (slot-value ws 'saved-cells))))
  (setf (slot-value ws 'dont-save-cells) nil))

(cl-defmethod ein:worksheet-dont-save-cells ((ws ein:worksheet))
  "Turn on `:dont-save-cells' flag so that next call on
`ein:worksheet-save-cells' actually do nothing.

\(fn ws)"
  (setf (slot-value ws 'dont-save-cells) t))


;;; Cell indexing, retrieval, etc.

(cl-defmethod ein:worksheet-cell-from-type ((ws ein:worksheet) type &rest args)
  "Create a cell of TYPE (symbol or string)."
  ;; FIXME: unify type of TYPE to symbol or string.
  (apply #'ein:cell-from-type
         (format "%s" type)
         :ewoc (slot-value ws 'ewoc)
         :events (slot-value ws 'events)
         args))

(cl-defmethod ein:worksheet-get-cells ((ws ein:worksheet))
  (if (ein:worksheet-has-buffer-p ws)
      (let* ((ewoc (slot-value ws 'ewoc))
             (nodes (ewoc-collect ewoc
                                  (lambda (n) (ein:cell-node-p n 'prompt)))))
        (mapcar #'ein:$node-data nodes))
    (slot-value ws 'saved-cells)))

(cl-defmethod ein:worksheet-ncells ((ws ein:worksheet))
  (length (ein:worksheet-get-cells ws)))

(defun ein:worksheet-get-ewoc (&optional ws)
  (ein:aand (or ws ein:%worksheet%) (slot-value it 'ewoc)))

(defun ein:worksheet-get-current-ewoc-node (&optional pos)
  (ein:aand (ein:worksheet-get-ewoc) (ewoc-locate it pos)))

(defun ein:worksheet-get-nearest-cell-ewoc-node (&optional pos _max cell-p)
  (ein:and-let* ((ewoc-node (ein:worksheet-get-current-ewoc-node pos)))
    ;; FIXME: can be optimized using the argument `max'
    (while (and ewoc-node
                (not (and (ein:cell-ewoc-node-p ewoc-node)
                          (if cell-p
                              (funcall cell-p
                                       (ein:cell-from-ewoc-node ewoc-node))
                            t))))
      (setq ewoc-node (ewoc-next (slot-value ein:%worksheet% 'ewoc) ewoc-node)))
    ewoc-node))

(cl-defun ein:worksheet-get-current-cell (&key pos noerror
                                               (cell-p #'ein:basecell-child-p))
  "Return a cell at POS.  If POS is not given, it is assumed be the
current cursor position.  When the current buffer is not worksheet
buffer or there is no cell in the current buffer, return `nil'."
  (let ((cell (ein:cell-from-ewoc-node
               (ein:worksheet-get-current-ewoc-node pos))))
    (if (funcall cell-p cell)
        cell
      (unless noerror
        (error "No cell of type %s found at current position." cell-p)))))

(defun ein:worksheet-at-codecell-p ()
  (ein:worksheet-get-current-cell :noerror t :cell-p #'ein:codecell-p))

(defun ein:worksheet-get-cells-in-region (beg end)
  (ein:clip-list (ein:aand ein:%worksheet% (ein:worksheet-get-cells it))
                 (ein:worksheet-get-current-cell :pos beg)
                 (ein:worksheet-get-current-cell :pos end)))

(cl-defun ein:worksheet-get-cells-in-region-or-at-point
    (&key noerror (cell-p #'ein:basecell-child-p))
  (or (seq-filter cell-p
                  (if (region-active-p)
                      (ein:worksheet-get-cells-in-region (region-beginning)
                                                         (region-end))
                    (list (ein:worksheet-get-current-cell))))
      (unless noerror
        (error "Cell not found"))))


;;; Insertion and deletion of cells

(defun ein:worksheet--get-ws-or-error ()
  (or ein:%worksheet% (error "Not in worksheet buffer.")))

(defun ein:worksheet-focus-cell ()
  (ein:aand (ein:worksheet-get-current-cell :noerror t) (ein:cell-goto it)))

(defun ein:worksheet-delete-cell (ws cell &optional focus)
  "Delete a cell.  \(WARNING: no undo!)
This command has no key binding because there is no way to undo
deletion.  Use kill to play on the safe side.

If you really want use this command, you can do something like this
\(but be careful when using it!)::

  \(define-key ein:notebook-mode-map \"\\C-c\\C-d\"
              'ein:worksheet-delete-cell)"
  (interactive (list (ein:worksheet--get-ws-or-error)
                     (ein:worksheet-get-current-cell)
                     t))
  (ein:worksheet--shift-undo-list cell)
  (let ((inhibit-read-only t)
        (buffer-undo-list t))
    (apply #'ewoc-delete
           (slot-value ws 'ewoc)
           (ein:cell-all-element cell)))
  (setf (oref ws :dirty) t)
  (when focus (ein:worksheet-focus-cell)))

(defun ein:worksheet-kill-cell (ws cells &optional focus)
  "Kill (\"cut\") the cell at point or cells in region.
Note that the kill-ring for cells is not shared with the default
kill-ring of Emacs (kill-ring for texts)."
  (interactive (list (ein:worksheet--get-ws-or-error)
                     (ein:worksheet-get-cells-in-region-or-at-point)
                     t))
  (when cells
    (mapc (lambda (c)
            (ein:cell-save-text c)
            (ein:worksheet-delete-cell ws c)
            (ein:cell-deactivate c))
          cells)
    (ein:kill-new cells)
    (when focus
      (deactivate-mark)
      (ein:worksheet-focus-cell))))

(defun ein:worksheet-copy-cell (cells)
  "Copy the cell at point.  (Put the current cell into the kill-ring.)"
  (interactive
   (list (when (ein:worksheet--get-ws-or-error)
           (prog1 (ein:worksheet-get-cells-in-region-or-at-point)
             (deactivate-mark)))))
  (let ((cells (mapcar
                (lambda (c)
                  (ein:cell-deactivate (ein:cell-copy c)))
                cells)))
    (ein:log 'info "%s cells are copied." (length cells))
    (ein:kill-new cells)))

(defun ein:worksheet-insert-clone (ws cell pivot up &optional focus)
  (let* ((clone (ein:cell-copy cell))
         (clone-buffer (ein:cell-buffer clone))
         (clone-buffer-base (buffer-base-buffer clone-buffer))
         (ws-buffer (ewoc-buffer (ein:worksheet--ewoc ws))))
    ;; Cell can be from another buffer, so reset `ewoc'.
    (when (if clone-buffer-base
              (not (equal clone-buffer-base ws-buffer))
            (not (equal clone-buffer ws-buffer)))
      (setf (ein:basecell--ewoc clone) (ein:worksheet--ewoc ws)))
    (funcall (intern (concat "ein:worksheet-insert-cell-" up)) ws clone pivot focus)
    clone))

(defun ein:worksheet-yank-cell (ws &optional n)
  "Paste the latest killed cell.
Treats prefixes identically to the normal `yank' command."
  (interactive (list (ein:worksheet--get-ws-or-error)
                     (let ((arg current-prefix-arg))
                       (cond ((listp arg) 0)
                             ((eq arg '-) -2)
                             (t (1- arg))))))
  (let* ((cell (ein:worksheet-get-current-cell :noerror t)) ; can be nil
         (killed (ein:current-kill n)))
    (cl-loop for c in killed
             with last = cell
             do (setq last (ein:worksheet-insert-clone ws c last "below"))
             finally (ein:cell-goto last))))

(defun ein:worksheet--node-positions (cell)
  (let ((result))
    (cl-loop for k in (slot-value cell 'element-names)
          do (setq result
                   (plist-put result k
                              (let* ((en-or-list (ein:cell-element-get cell k))
                                     (en (if (listp en-or-list) (nth 0 en-or-list) en-or-list)))
                                (if en (marker-position (ewoc-location en)))))))
    result))

(defun ein:worksheet-maybe-new-cell (ws type-or-cell)
  "Return TYPE-OR-CELL as-is if it is a cell, otherwise return a new cell."
  (let ((cell (if (cl-typep type-or-cell 'ein:basecell)
                  type-or-cell
                (ein:worksheet-cell-from-type ws type-or-cell))))
    ;; When newly created or copied, kernel is not attached or not the
    ;; kernel of this worksheet.  So reset it here.
    (when (cl-typep cell 'ein:codecell)
      (setf (slot-value cell 'kernel) (slot-value ws 'kernel)))
    (setf (slot-value cell 'events) (slot-value ws 'events))
    cell))

(defun ein:worksheet-insert-cell-below (ws type-or-cell pivot &optional focus)
  "Insert cell below.
Insert markdown cell instead of code cell when the prefix argument is given."
  (interactive (list (ein:worksheet--get-ws-or-error)
                     (if current-prefix-arg 'markdown 'code)
                     (ein:worksheet-get-current-cell :noerror t)
                     t))
  (let ((cell (ein:worksheet-maybe-new-cell ws type-or-cell)))
    (if (zerop (ein:worksheet-ncells ws))
        (ein:cell-enter-last cell)
      (ein:cell-insert-below pivot cell))
    (ein:worksheet--unshift-undo-list cell (- (ein:cell-input-pos-max cell)
                                              (ein:cell-input-pos-min cell)))
    (setf (oref ws :dirty) t)
    (when focus (ein:cell-goto cell))
    cell))

(defun ein:worksheet-insert-cell-above (ws type-or-cell pivot &optional focus)
  "Insert cell above.
Insert markdown cell instead of code cell when the prefix argument is given."
  (interactive (list (ein:worksheet--get-ws-or-error)
                     (if current-prefix-arg 'markdown 'code)
                     (ein:worksheet-get-current-cell :noerror t)
                     t))
  (let ((cell (ein:worksheet-maybe-new-cell ws type-or-cell)))
    (if (<= (ein:worksheet-ncells ws) 1)
        (ein:cell-enter-first cell)
      (let ((prev-cell (ein:cell-prev pivot)))
        (if prev-cell
            (ein:cell-insert-below prev-cell cell)
          (ein:cell-enter-first cell))))
    (ein:worksheet--unshift-undo-list cell (- (ein:cell-input-pos-max cell)
                                              (ein:cell-input-pos-min cell)))
    (setf (oref ws :dirty) t)
    (when focus (ein:cell-goto cell))
    cell))

(defun ein:worksheet-toggle-cell-type (ws cell &optional focus)
  "Toggle the cell type of the cell at point.
Use `ein:worksheet-change-cell-type' to change the cell type
directly."
  (interactive (list (ein:worksheet--get-ws-or-error)
                     (ein:worksheet-get-current-cell)
                     t))
  (let ((type (ein:case-equal (slot-value cell 'cell-type)
                (("code") "markdown")
                (("markdown") "raw")
                (("raw") "code"))))
    (let ((relpos (ein:cell-relative-point cell))
          (new (ein:cell-convert-inplace cell type)))
      (when (ein:codecell-p new)
        (setf (slot-value new 'kernel) (slot-value ws 'kernel))
        (setf (slot-value new 'events) (slot-value ws 'events)))
      (when focus (ein:cell-goto new relpos))
      (ein:worksheet--unshift-undo-list new nil cell))))

(defalias 'ein:worksheet-change-cell-type #'ein:worksheet-toggle-cell-type)

(defun ein:worksheet-split-cell-at-point (ws cell &optional no-trim focus)
  "Split cell at current position. Newlines at the splitting
point will be removed. This can be omitted by giving a prefix
argument \(C-u)."
  (interactive (list (ein:worksheet--get-ws-or-error)
                     (ein:worksheet-get-current-cell)
                     current-prefix-arg
                     t))
  (let* ((beg (set-marker (make-marker) (ein:cell-input-pos-min cell)))
         (pos (point-marker))
         (head (buffer-substring beg pos))
         (new (ein:worksheet-insert-cell-above ws
                                               (slot-value cell 'cell-type)
                                               cell)))
    (undo-boundary)
    (delete-region beg pos)
    (unless no-trim
      (setq head (ein:trim-right head "\n"))
      (save-excursion
        (goto-char pos)
        (let ((end (set-marker (make-marker) (ein:cell-input-pos-max cell))))
          (while (and (looking-at-p "\n") (< (point) end))
            (delete-char 1)))))
    (ein:cell-set-text new head)
    (when focus (ein:cell-goto cell))))

(defun ein:worksheet-merge-cell (ws cell &optional next focus)
  "Merge previous cell into current cell.
If prefix is given, merge current cell into next cell."
  (interactive (list (ein:worksheet--get-ws-or-error)
                     (ein:worksheet-get-current-cell)
                     current-prefix-arg
                     t))
  (unless next
    (setq cell (ein:cell-prev cell))
    (if cell
        (ein:cell-goto cell)
      (message "No previous cell")))
  (when cell
    (let* ((next-cell (ein:cell-next cell))
           (head (ein:cell-get-text cell)))
      (cl-assert next-cell nil "No cell to merge.")
      (ein:worksheet-delete-cell ws cell)
      (save-excursion
        (goto-char (ein:cell-input-pos-min next-cell))
        (insert head "\n"))
      (when focus (ein:cell-goto next-cell)))))


;;; Cell selection.

(cl-defun ein:worksheet-next-input-cell (ewoc-node &optional up (nth 1))
  "Return a cell containing the next input node after EWOC-NODE.
When UP is non-`nil', do the same for the *previous* input node.
When NTH is specified, return NTH cell.  Note that this function is
*not* defined for NTH=0; it returns nil."
  (unless (= nth 0)
    (when (< nth 0)
      (setq nth (* nth -1))
      (setq up (not up)))
    (let ((cell (ein:worksheet-next-input-cell-1 ewoc-node up)))
      (cl-loop repeat (1- nth)
            with next = (if up #'ein:cell-prev #'ein:cell-next)
            if (funcall next cell)
            do (setq cell it)
            else
            return nil)
      cell)))

(defun ein:worksheet-next-input-cell-1 (ewoc-node &optional up)
  (let* ((ewoc-data (ewoc-data ewoc-node))
         (cell (ein:$node-data ewoc-data))
         (path (ein:$node-path ewoc-data))
         (element (nth 1 path)))
    (if (memql element (if up '(output footer) '(prompt)))
        cell
      (funcall (if up #'ein:cell-prev #'ein:cell-next) cell))))

(defun ein:worksheet-goto-input (ewoc-node up)
  (aif (and ewoc-node (ein:worksheet-next-input-cell ewoc-node up))
      (ein:cell-goto it)
    (message "No %s input" (if up "previous" "next"))))

(defun ein:worksheet-goto-next-input (ewoc-node)
  (interactive (list (and (ein:worksheet--get-ws-or-error)
                          (ein:worksheet-get-current-ewoc-node))))
  (ein:worksheet-goto-input ewoc-node nil))

(defun ein:worksheet-goto-prev-input (ewoc-node)
  (interactive (list (and (ein:worksheet--get-ws-or-error)
                          (ein:worksheet-get-current-ewoc-node))))
  (ein:worksheet-goto-input ewoc-node t))

(defun ein:worksheet-goto-next-cell-element (&optional nth up relpos prop)
  "Go to NTH next cell element named PROP and shift cursor by RELPOS.
Go to previous cell if UP is t.
Return t when the movement is succeeded."
  (unless prop (setq prop :input))
  (-when-let* ((current-node (ein:worksheet-get-current-ewoc-node))
                 (current-cell (ein:cell-from-ewoc-node current-node))
                 (target-cell
                  (if (and (= nth 1)
                           (eq (ein:cell-element-get current-cell :input)
                               current-node)
                           (not (and up
                                     (= (1+ (ewoc-location current-node))
                                        (point)))))
                      current-cell
                    (ein:worksheet-next-input-cell current-node up nth))))
    (ein:cell-goto target-cell relpos prop)
    t))

(defun ein:worksheet-beginning-of-cell-input (&optional arg)
  "Move backward to the beginning of a cell.
This function is for `beginning-of-defun-function', so behaves
similarly with `beginning-of-defun'.
It is set in `ein:notebook-multilang-mode'."
  (ein:worksheet-goto-next-cell-element (or arg 1) t))

(defun ein:worksheet-end-of-cell-input (&optional arg)
  "Move forward to the end of a cell.
This function is for `end-of-defun-function', so behaves
similarly with `end-of-defun'.
It is set in `ein:notebook-multilang-mode'."
  (ein:worksheet-goto-next-cell-element (or arg 1) nil 0 :after-input))

(defun ein:worksheet-move-cell (ws cell up)
  "Effectively kill and yank modulo dirtying kill ring."
  (aif (if up (ein:cell-prev cell) (ein:cell-next cell))
      (let ((inhibit-read-only t)
            (pivot-cell it))
        (ein:cell-save-text cell)
        (ein:worksheet-delete-cell ws cell)
        (ein:cell-deactivate cell)

        ;; the clone conveniently makes otl zero
        ;; (as opposed to ein:worksheet-insert-cell)
        (ein:worksheet-insert-clone ws cell pivot-cell (if up "above" "below") t)
        (poly-ein-fontify-buffer (ein:worksheet--get-buffer ws)))
    (message "No %s cell" (if up "previous" "next"))))

(defun ein:worksheet-not-move-cell (which)
  (when ein:worksheet-warn-obsolesced-keybinding
    (ein:display-warning-once
     (mapconcat #'identity
                '("M-<up> and M-<down> no longer move cells."
                  "Use C-c <up> and C-c <down>."
                  "Custom set variable `ein:worksheet-warn-obsolesced-keybinding' to disable this warning.") "\n")
     warning-minimum-level))
  (aif (cl-some (lambda (c) (and (commandp c) c))
                (mapcar (lambda (pair) (lookup-key (cdr pair) which))
                        (cdr minor-mode-map-alist)))
      (call-interactively it)))

(defun ein:worksheet-not-move-cell-up (&rest _args)
  (interactive)
  (ein:worksheet-not-move-cell (kbd "M-<up>")))

(defun ein:worksheet-not-move-cell-down (&rest _args)
  (interactive)
  (ein:worksheet-not-move-cell (kbd "M-<down>")))

(defun ein:worksheet-move-cell-up (ws cell)
  (interactive (list (ein:worksheet--get-ws-or-error)
                     (ein:worksheet-get-current-cell)))
  (ein:worksheet-move-cell ws cell t))

(defun ein:worksheet-move-cell-down (ws cell)
  (interactive (list (ein:worksheet--get-ws-or-error)
                     (ein:worksheet-get-current-cell)))
  (ein:worksheet-move-cell ws cell nil))

;;; Cell collapsing and output clearing

(defun ein:worksheet-toggle-output (ws cell)
  "Toggle the visibility of the output of the cell at point.
This does not alter the actual data stored in the cell."
  (interactive (list (ein:worksheet--get-ws-or-error)
                     (ein:worksheet-get-current-cell
                      :cell-p #'ein:codecell-p)))
  (let ((buffer-undo-list t))
    (ein:cell-toggle-output cell)
    (setf (slot-value ws 'dirty) t))
  (ein:worksheet--unshift-undo-list cell))

(defun ein:worksheet-set-output-visibility-all (ws &optional collapsed)
  "Show all cell output.  When prefix is given, hide all cell output."
  (interactive (list (ein:worksheet--get-ws-or-error) current-prefix-arg))
  (when collapsed (setq collapsed t))   ; force it to be a boolean
  (mapc (lambda (c)
          (when (ein:codecell-p c)
            (let ((buffer-undo-list t))
              (ein:cell-set-collapsed c collapsed))
            (ein:worksheet--unshift-undo-list c)))
        (ein:worksheet-get-cells ws))
  (setf (slot-value ws 'dirty) t))

(defun ein:worksheet-clear-output (cell &optional preserve-input-prompt)
  "Clear output from the current cell at point.
Do not clear input prompt when the prefix argument is given."
  (interactive (list (ein:worksheet-get-current-cell
                      :cell-p #'ein:codecell-p)
                     current-prefix-arg))
  (ein:cell-clear-output cell t t t)
  (unless preserve-input-prompt
    (ein:cell-set-input-prompt cell))
  (ein:worksheet--unshift-undo-list cell))

(defun ein:worksheet-clear-all-output (ws &optional preserve-input-prompt)
  "Clear output from all cells.
Do not clear input prompts when the prefix argument is given."
  (interactive (list (ein:worksheet--get-ws-or-error) current-prefix-arg))
  (mapc (lambda (c) (ein:worksheet-clear-output c preserve-input-prompt))
        (seq-filter #'ein:codecell-p (ein:worksheet-get-cells ws))))

;;; Kernel related things

(defun ein:worksheet-kernel-status (ws)
  "Report kernel status."
  (interactive (list (ein:worksheet--get-ws-or-error)))
  (let ((kernel (slot-value ws 'kernel)))
    (message "%s" (cl-mapcan (lambda (slot)
                               (let ((channel (funcall slot kernel)))
                                 (and channel
                                      (list (cons slot
                                                  (websocket-ready-state
                                                   (ein:$websocket-ws channel)))))))
                             '(ein:$kernel-websocket
                               ein:$kernel-shell-channel
                               ein:$kernel-iopub-channel)))))

(cl-defmethod ein:worksheet-set-kernel ((ws ein:worksheet))
  (mapc (lambda (cell) (setf (slot-value cell 'kernel) (slot-value ws 'kernel)))
        (seq-filter #'ein:codecell-p (ein:worksheet-get-cells ws))))

(defun ein:worksheet-execute-cell (ws cell &optional batch)
  "Execute code type CELL."
  (interactive `(,(ein:worksheet--get-ws-or-error)
                 ,(ein:worksheet-get-current-cell)
                 ,(when current-prefix-arg
                    (prog1 (read-char-choice "[RET]all [a]bove [b]elow: " (list ?\r ?a ?b))
                      (message "")))))
  (if (ein:codecell-p cell)
      (ein:kernel-when-ready
       (slot-value ws 'kernel)
       (apply-partially
        (lambda (ws* cell* batch* _kernel)
          (cl-case batch*
            (?\r (ein:worksheet-execute-all-cells ws*))
            (?a (ein:worksheet-execute-all-cells ws* :above cell*))
            (?b (ein:worksheet-execute-all-cells ws* :below cell*))
            (t (ein:cell-execute cell*)
               (setf (oref ws* :dirty) t)
               (ein:worksheet--unshift-undo-list cell*))))
        ws cell batch))
    (message "ein:worksheet-execute-cell: not a code cell"))
  cell)

(defun ein:worksheet-execute-cell-and-goto-next (ws cell &optional insert)
  "Execute cell at point if it is a code cell and move to the
next cell, or insert if none."
  (interactive (list (ein:worksheet--get-ws-or-error)
                     (ein:worksheet-get-current-cell)))
  (when (cl-typep cell 'ein:codecell)
    (ein:worksheet-execute-cell ws cell))
  (aif (and (not insert) (ein:cell-next cell))
      (ein:cell-goto it)
    (ein:worksheet-insert-cell-below ws 'code cell t)))

(defun ein:worksheet-execute-cell-and-insert-below (ws cell)
  "Execute cell at point if it is a code cell and insert a
cell bellow."
  (interactive (list (ein:worksheet--get-ws-or-error)
                     (ein:worksheet-get-current-cell)))
  (ein:worksheet-execute-cell-and-goto-next ws cell t))

(define-obsolete-function-alias
  'ein:worksheet-execute-all-cell 'ein:worksheet-execute-all-cells "0.17.0")

(cl-defun ein:worksheet-execute-all-cells (ws &key above below)
  "Execute all cells in the current worksheet buffer.
If :above or :below specified, execute above/below the current cell."
  (interactive (list (ein:worksheet--get-ws-or-error)))
  (let ((all (ein:worksheet-get-cells ws)))
    (mapc (apply-partially #'ein:worksheet-execute-cell ws)
          (seq-filter
           #'ein:codecell-p
           (aif (or above below)
               (-when-let* ((current-id (slot-value it 'cell-id))
                            (not-matching (apply-partially
                                           (lambda (my other)
                                             (not (string= (slot-value other 'cell-id) my)))
                                           current-id)))
                 (append (when above
                           (aif (seq-take-while not-matching all)
                               it
                             (prog1 nil
                               (ein:log 'info
                                 "ein:worksheet-execute-all-cells: no cells above current"))))
                         (when below
                           (seq-drop-while not-matching all))))
             all)))))

(defun ein:worksheet-execute-all-cells-above (ws)
  "Execute all cells above the current cell (exclusively) in the
current worksheet buffer."
  (interactive (list (ein:worksheet--get-ws-or-error)))
  (ein:worksheet-execute-all-cells ws :above (ein:worksheet-get-current-cell)))

(defun ein:worksheet-execute-all-cells-below (ws)
  "Execute all cells below the current cell (inclusively) in the
current worksheet buffer."
  (interactive (list (ein:worksheet--get-ws-or-error)))
  (ein:worksheet-execute-all-cells ws :below (ein:worksheet-get-current-cell)))

(defun ein:get-url-or-port--worksheet ()
  (when (ein:worksheet-p ein:%worksheet%)
    (ein:worksheet-url-or-port ein:%worksheet%)))

(defun ein:get-kernel--worksheet ()
  (when (ein:worksheet-p ein:%worksheet%) (slot-value ein:%worksheet% 'kernel)))

(defun ein:get-cell-at-point--worksheet ()
  (ein:worksheet-get-current-cell :noerror t))

(defun ein:get-traceback-data--worksheet ()
  (ein:aand (ein:get-cell-at-point--worksheet) (ein:cell-get-tb-data it)))


;;; Predicate

(defun ein:worksheet-buffer-p ()
  "Return non-`nil' if the current buffer is a worksheet buffer."
  ein:%worksheet%)

(cl-defmethod ein:worksheet-has-buffer-p ((ws ein:worksheet))
  (ein:aand (ein:worksheet-buffer ws) (buffer-live-p it)))

(cl-defmethod ein:worksheet-modified-p ((ws ein:worksheet))
  (let ((buffer (ein:worksheet-buffer ws)))
    (and (buffer-live-p buffer)
         (or (slot-value ws 'dirty)
             (buffer-modified-p buffer)))))


;;; Utility commands

(defun ein:worksheet-dedent-cell-text (cell)
  "Dedent text in CELL."
  (interactive (list (ein:worksheet-get-current-cell)))
  (let* ((beg (ein:cell-input-pos-min cell))
         (end (ein:cell-input-pos-max cell)))
    (indent-rigidly
     beg end (- (ein:find-leftmost-column beg end)))))

;;; Workarounds

(defadvice fill-paragraph (around ein:worksheet-fill-paragraph activate)
  "Prevent \"Text is read-only\" error when filling paragraph in
EIN worksheet."
  (if ein:%worksheet%
      (let* ((cell (ein:worksheet-get-current-cell))
             (beg (copy-marker (ein:cell-input-pos-min cell))))
        (save-excursion
          (goto-char beg)
          (insert "\n"))
        (unwind-protect
            ad-do-it
          (save-excursion
            (goto-char beg)
            (delete-char 1))))
    ad-do-it))

(provide 'ein-worksheet)

;;; ein-worksheet.el ends here
