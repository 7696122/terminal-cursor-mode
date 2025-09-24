;;; terminal-cursor-mode.el --- Change cursor appearance in terminal based on cursor-type -*- lexical-binding: t; -*-

;; Copyright (C) 2025

;; Author: 7696122 <7696122@gmail.com>
;; Version: 1.0.0
;; Package-Requires: ((emacs "24.1"))
;; Keywords: convenience, terminals
;; URL: https://github.com/7696122/terminal-cursor-mode

;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; This package provides a minor mode that changes the terminal cursor
;; appearance based on Emacs cursor-type, blink-cursor-mode, and cursor face.
;; Includes performance optimization and error handling.
;; 
;; Usage:
;;   (global-terminal-cursor-mode 1)  ; Enable for all buffers
;;   (terminal-cursor-mode 1)         ; Enable for current buffer only

;;; Code:

(defvar terminal-cursor-mode-map (make-sparse-keymap)
  "Keymap for terminal-cursor-mode.")

(defvar-local terminal-cursor--last-state nil
  "Last cursor state to avoid unnecessary updates.")

(defun terminal-cursor-update ()
  "Update terminal cursor based on cursor-type, blink-cursor-mode, and cursor face."
  (when (not (display-graphic-p))
    (let* ((cursor-color (face-attribute 'cursor :background nil 'default))
           (current-state (list cursor-type blink-cursor-mode cursor-color)))
      (unless (equal current-state terminal-cursor--last-state)
        (setq terminal-cursor--last-state current-state)
        (condition-case nil
            (let* ((cursor-escape
                    (pcase cursor-type
                      ('box (if blink-cursor-mode "\e[1 q" "\e[2 q"))
                      ('bar (if blink-cursor-mode "\e[5 q" "\e[6 q"))
                      ('hbar (if blink-cursor-mode "\e[3 q" "\e[4 q"))
                      (_ (if blink-cursor-mode "\e[1 q" "\e[2 q"))))
                   (color-escape (when (and cursor-color (not (eq cursor-color 'unspecified)))
                                  (format "\e]12;%s\007" cursor-color))))
              (send-string-to-terminal cursor-escape)
              (when color-escape
                (send-string-to-terminal color-escape)))
          (error nil))))))

(defun terminal-cursor-mode-enable ()
  "Enable terminal cursor mode."
  (add-hook 'post-command-hook #'terminal-cursor-update nil t)
  (terminal-cursor-update))

(defun terminal-cursor-mode-disable ()
  "Disable terminal cursor mode."
  (remove-hook 'post-command-hook #'terminal-cursor-update t)
  (setq terminal-cursor--last-state nil))

;;;###autoload
(define-minor-mode terminal-cursor-mode
  "Minor mode to change cursor appearance in terminal based on cursor-type."
  :lighter " TCursor"
  :keymap terminal-cursor-mode-map
  (if terminal-cursor-mode
      (terminal-cursor-mode-enable)
    (terminal-cursor-mode-disable)))

(defun terminal-cursor-mode-turn-on ()
  "Turn on terminal-cursor-mode if appropriate."
  (unless (minibufferp)
    (terminal-cursor-mode 1)))

;;;###autoload
(define-globalized-minor-mode global-terminal-cursor-mode
  terminal-cursor-mode
  terminal-cursor-mode-turn-on
  :group 'terminal-cursor)

(provide 'terminal-cursor-mode)
;;; terminal-cursor-mode.el ends here
