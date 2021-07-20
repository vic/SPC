
(defun str-write-to-file (file content)
  (with-current-buffer (get-buffer-create file)
    (insert content)
    (write-file file nil)))

(defun hello (name)
  "Say hello to NAME"
  (interactive "sName: ")
  (message (format "HOLA %s" name))
  (server-reply-print (format "HELLO %s" name) (car server-clients)))

(define-key global-map (kbd "C-M-H-x hello") #'hello)

(setq server-socket-dir (concat (getenv "BATS_TMPDIR") "/socket"))
(str-write-to-file (concat server-socket-dir "/PID") (number-to-string (emacs-pid)))
