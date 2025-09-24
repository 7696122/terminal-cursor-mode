;;; terminal-cursor-mode.el --- Change cursor appearance in terminal based on cursor-type

;;; Code:

(defvar terminal-cursor-mode-map (make-sparse-keymap)
  "Keymap for terminal-cursor-mode.")

(defun terminal-cursor-update ()
  "Update terminal cursor based on cursor-type, blink-cursor-mode, and cursor face."
  (when (not (display-graphic-p))
    (let* ((cursor-escape
            (pcase cursor-type
              ('box (if blink-cursor-mode "\e[1 q" "\e[2 q"))      ; Blinking/steady block
              ('bar (if blink-cursor-mode "\e[5 q" "\e[6 q"))      ; Blinking/steady bar
              ('hbar (if blink-cursor-mode "\e[3 q" "\e[4 q"))     ; Blinking/steady underline
              (_ (if blink-cursor-mode "\e[1 q" "\e[2 q"))))       ; Default
           (cursor-color (face-attribute 'cursor :background nil 'default))
           (color-escape (when (and cursor-color (not (eq cursor-color 'unspecified)))
                          (format "\e]12;%s\007" cursor-color))))
      (send-string-to-terminal cursor-escape)
      (when color-escape
        (send-string-to-terminal color-escape)))))

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
