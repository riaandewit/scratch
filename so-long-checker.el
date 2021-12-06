;;depends on so-long-mode
(global-so-long-mode 1)

(setq *longline-timer* nil)
;; function that checks lines, returns whether threshold has been hit
(defun longline-p (threshold lines-to-check)
  (save-excursion
    (goto-char (point-max))
    (let ((hit nil)
          (run t)
          (lines-to-check (min lines-to-check (line-number-at-pos))))
      (while (and (> lines-to-check 0) run)
        (end-of-line)
        (when (> (current-column) threshold)
          (setq hit t)
          (setq run nil))
        (setq lines-to-check (- lines-to-check 1))
        (when (> lines-to-check 0)
          (previous-line)))
      hit)))
;;every 5 seconds, check whether threshold has been exceeded,
;;enable so-long if that's the case
(defun watch-longlines ()
  (setq *longline-timer*
        (run-with-timer 0 5 (lambda ()
                              (when (and
                                     (boundp 'cider-result-buffer)
                                     (get-buffer cider-result-buffer))
                                (with-current-buffer cider-result-buffer
                                  (when
                                      (longline-p 1024 10)
                                    (so-long))))))))
;;when you want to switch it off
(defun unwatch-longlines ()
  (cancel-timer *longline-timer*))
;; make the thing run
;; it's now hunting every 5 seconds for the cider-results-buffer
;; and if any of the last 10 lines are > 1024 chars long, kicks
;; off so-long.
(watch-longlines)