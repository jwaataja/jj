;;;; editing.lisp
;;;; Common functions that the user might use to edit text.

(in-package #:jj)

(defun enter-insert-mode ()
  (enter-mode 'insert-mode))

(defun enter-normal-mode ()
  (enter-mode 'normal-mode))

(defun begin-command ()
  (set-buffer *command-buffer*)
  (enter-insert-mode))

(defun move-cursor-down (&optional (buffer *current-buffer*))
  (let* ((mark (buffer-cursor-mark buffer)))
    (move-mark mark
               (text-position-move-line (text-mark-current-position mark))))
  (autoscroll-buffer-frame (buffer-frame buffer))
  (update-selection #'character-selector))

(defun move-cursor-up (&optional (buffer *current-buffer*))
  (let ((mark (buffer-cursor-mark buffer)))
    (move-mark mark
               (text-position-move-line (text-mark-current-position mark)
                                        -1)))
  (autoscroll-buffer-frame (buffer-frame buffer))
  (update-selection #'character-selector))

(defun move-cursor-forward (&optional (buffer *current-buffer*))
  (let* ((mark (buffer-cursor-mark buffer))
         (current-position (text-mark-current-position mark)))
    (let ((new-line-position (1+ (text-position-line-position current-position)))
          (line (buffer-line buffer (text-position-line-number current-position))))
      (cond ((minusp new-line-position)
             (setf new-line-position 0))
            ((> new-line-position
                (length line))
             (setf new-line-position (length line))))
      (move-mark mark
                 (make-text-position-with-line buffer
                                               (text-position-line-number current-position)
                                               new-line-position))))
  (update-selection #'character-selector))

(defun move-cursor-backward (&optional (buffer *current-buffer*))
  (let* ((mark (buffer-cursor-mark buffer))
         (current-position (text-mark-current-position mark)))
    (let ((new-line-position (1- (text-position-line-position current-position)))
          (line (buffer-line buffer (text-position-line-number current-position))))
      (cond ((minusp new-line-position)
             (setf new-line-position 0))
            ((> new-line-position
                (length line))
             (setf new-line-position (length line))))
      (move-mark mark
                 (make-text-position-with-line buffer
                                               (text-position-line-number current-position)
                                               new-line-position))))
  (update-selection #'character-selector))

(defun exit-command-mode ()
  "Assuming the user is in the command buffer, return to the previous buffer and
clear the command buffer. This function checks to see if it's in the command
buffer first."
  (when (eql *current-buffer* *command-buffer*)
    (set-to-last-buffer)
    (clear-command-buffer)))

(defun process-escape-key ()
  "Process the escape key when in insert mode. Special behavior when in the
  command buffer."
  (exit-command-mode))

(defun clear-buffer (buffer)
  "Deletes all text in BUFFER."
  (delete-text buffer 0 (buffer-length buffer)))

(defun clear-command-buffer ()
  "Calls CLEAR-BUFFER on *COMMAND-BUFFER*."
  (clear-buffer *command-buffer*))

(defparameter *exit-flag* nil "Variable to store if the program should exit.")

(defun exit-clean ()
  "Set the main loop to exit after the next iteration. Do any necessary cleanup
before hand, etc."
  ;; TODO: Add something to handle if there are multiple buffers open to resize
  ;; windows and not close, check if files need saving, etc.
  (setf *exit-flag* t))
