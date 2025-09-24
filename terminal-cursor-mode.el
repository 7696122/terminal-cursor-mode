;;; terminal-cursor-mode.el --- Change cursor appearance in terminal based on cursor-type

;;; Code:

(defvar terminal-cursor-mode-map (make-sparse-keymap)
  "Keymap for terminal-cursor-mode.")

(defun terminal-cursor-update ()
  "Update terminal cursor based on cursor-type."
  (when (not (display-graphic-p))
    (let ((cursor-escape
           (pcase cursor-type
             ('box "\e[2 q")      ; Block cursor
             ('bar "\e[6 q")      ; Bar cursor
             ('hbar "\e[4 q")     ; Underline cursor
             (_ "\e[2 q"))))      ; Default to block
      (send-string-to-terminal cursor-escape))))

(defun terminal-cursor-mode-enable ()
  "Enable terminal cursor mode."
  (add-hook 'post-command-hook #'terminal-cursor-update nil t))

(defun terminal-cursor-mode-disable ()
  "Disable terminal cursor mode."
  (remove-hook 'post-command-hook #'terminal-cursor-update t))

;;;###autoload
(define-minor-mode terminal-cursor-mode
  "Minor mode to change cursor appearance in terminal based on cursor-type."
  :lighter " TCursor"
  :keymap terminal-cursor-mode-map
  (if terminal-cursor-mode
      (terminal-cursor-mode-enable)
    (terminal-cursor-mode-disable)))

(provide 'terminal-cursor-mode)
;;; terminal-cursor-mode.el ends here
