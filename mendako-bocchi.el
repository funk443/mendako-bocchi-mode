;;; mendako-bocchi.el --- Mendako Bocchi in the header line  -*- lexical-binding: t; -*-

;; Copyright (C) 2023  CToID

;; Author: CToID <funk443@yandex.com>
;; Version: 1.0
;; Created: 02 Jun. 2023
;; Keywords: btr bocchi header

;; This file is not part of GNU Emacs.

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary
;; The Bocchi image came from <https://www.pixiv.net/artworks/107506106>

;;; Code:
(defgroup mendako-bocchi ()
  "Mendako Bocchi moving in the header line."
  :prefix "mendako-bocchi-"
  :group 'application)
(defcustom mendako-bocchi-update-interval (/ 1 25.0)
  "Specifies how long should the header line be updated."
  :type 'float)
(defcustom mendako-bocchi-step 1
  "Specifies how many pixels will Bocchi move in one update."
  :type 'integer)
(defcustom mendako-bocchi-image-scale 0.05
  "Specifies how big the image should be."
  :type 'float)

(defvar-local mendako-bocchi--original-header-line nil
  "Stores the `header-line-format' before enabling `mendako-bocchi-mode' in the
buffer.")
(defvar-local mendako-bocchi-image nil
  "Stores the image to be displayed in the header line.")
(defvar-local mendako-bocchi-timer nil
  "Stores the timer that calls the header line updating function.")
(defvar-local mendako-bocchi-update-function
    (let ((position -1))
      (lambda ()
        (setq position (+ position mendako-bocchi-step))
        (if (> position (window-width (selected-window) t))
            (setq position 0))
        (concat (if (> position 1)
                    (propertize " "
                                'display `(space :align-to (,position))))
                (propertize " "
                            'display mendako-bocchi-image))))
  "Stores the closure function to update the header line.")

(defun mendako-bocchi-update-header-line (buffer)
  "Update the header line in buffer BUFFER"
  (with-current-buffer buffer
    (setq header-line-format (funcall mendako-bocchi-update-function))))

(define-minor-mode mendako-bocchi-mode
  "Minor mode to display a mendako bocchi moving in the header line."
  :lighter " bocchi"
  (if mendako-bocchi-mode
      (setq mendako-bocchi--original-header-line
            header-line-format
            mendako-bocchi-timer
            (run-at-time nil mendako-bocchi-update-interval
                         (apply-partially #'mendako-bocchi-update-header-line
                                          (current-buffer)))
            mendako-bocchi-image
            (create-image (expand-file-name "./bocchi.png") 'png nil
                          :scale mendako-bocchi-image-scale
                          :heuristic-mask t))
    (setq header-line-format mendako-bocchi--original-header-line)
    (cancel-timer mendako-bocchi-timer)))

(provide 'mendako-bocchi)
;;; mendako-bocchi.el ends here
