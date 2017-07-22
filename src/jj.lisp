;;;; jj.lisp
;;;; Main file for jj

(in-package #:jj)

;; TODO: Handle control and alt keys.
(defun ncurses-input-to-chord (ch)
  "Converts a result from GETCHAR to the corresponding chord. Doesn't yet know
about the control or alt keys."
  ;; TODO: The cl-charms source code said this wasn't quite right. Maybe fix
  ;; this or something.
  (make-chord (code-char ch)))

(defun main (argv)
  "Entry point for jj"
  (declare (ignore argv))
  (charms/ll:initscr)
  (charms/ll:cbreak)
  (charms/ll:noecho)
  (multiple-value-bind (rows columns)
      (charms/ll:get-maxyx charms/ll:*stdscr*)
    ;; The line height for the charm windows are done this way because using (1-
    ;; rows) sometimes makes the command buffer non-visible I think. That should
    ;; be tested again.
    (let* ((charms-win (charms/ll:newwin (- rows 2) columns 0 0))
           (command-win (charms/ll:newwin 1 columns (1- rows) 0))
           (main-display (make-charms-display charms-win))
           (command-display (make-charms-display command-win))
           (default-buffer (make-buffer))
           (command-buffer (make-buffer))
           (default-frame (make-buffer-frame
                           :buffer default-buffer
                           :display main-display))
           (command-frame (make-buffer-frame
                           :buffer command-buffer
                           :display command-display)))
      ;; This line also updates *SELECTION*, so no code is needed to initialize
      ;; it here.
      (set-buffer default-buffer)
      (setf (buffer-frame *current-buffer*) default-frame)
      (setf *command-buffer* command-buffer)
      (setf (buffer-frame *command-buffer*) command-frame)
      (setf *main-display* main-display)
      (setf *selection-mode* :move)
      (enter-mode 'normal-mode)
      ;; Use this restart in case MAIN is run multiple times within one Lisp
      ;; instance.
      (handler-bind ((override-binding-error #'use-new-binding))
        (enable-default-bindings))
      ;; Just in case this is being run multiple times in one Lisp instance.
      (clear-commands)
      (add-default-commands)
      (setf *exit-flag* nil)
      (update-frame default-frame)
      (update-frame command-frame)
      ;; (refresh-display main-displa)
      ;; (refresh-display command-display)
      (charms/ll:refresh)
      (update-time)
      (loop while (not *exit-flag*)
         for ch = (charms/ll:wgetch charms-win)
         for input-chord = (ncurses-input-to-chord ch)
         do
           (when (get-setting 'dump-key-events)
             (format t "Received ncurses key ~a, equivalent to ~a~%"
                     ch
                     input-chord))
           (update-time)
           (clear-display *main-display*)
           (clear-display command-display)
           (process-input input-chord)
           (update-frame default-frame)
           (update-frame command-frame)
         ;; This is like this because I'm not sure how to ensure which window
         ;; the cursor displays on. I'm pretty sure it's just whichever is
         ;; refreshed last. So, this ensures that the cursor is in the correct
         ;; section, a hopefully temporary hack.

         ;; TODO: Figure out how to choose which window the cursor is on.
           (cond ((command-mode-p)
                  (refresh-display *main-display*)
                  (refresh-display command-display))
                 (t
                  (refresh-display command-display)
                  (refresh-display *main-display*)))
           (when (eql ch (char-code #\a))
             (setf *exit-flag* t)))
      (charms/ll:delwin charms-win)
      (charms/ll:endwin))))
