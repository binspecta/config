(global-set-key (kbd "C-c f") 'find-file-in-project)

(add-hook 'prog-mode-hook
          (defun my-kill-word-key ()
            (local-set-key (kbd "C-M-h") 'backward-kill-word)))

(global-set-key (kbd "C-M-h") 'backward-kill-word)

(global-set-key (kbd "C-x C-i") 'imenu)

(global-set-key (kbd "C-x M-f") 'ido-find-file-other-window)
(global-set-key (kbd "C-c y") 'bury-buffer)
(global-set-key (kbd "C-c r") 'revert-buffer)

(global-set-key (kbd "C-x O") (lambda () (interactive) (other-window -1)))
(global-set-key (kbd "C-x C-o") (lambda () (interactive) (other-window 2)))

(global-set-key (kbd "C-x m") 'eshell)
(global-set-key (kbd "C-x C-m") 'shell)

(global-set-key (kbd "C-c q") 'join-line)
(global-set-key (kbd "C-c g") 'magit-status)

(global-set-key (kbd "C-c n")
                (defun pnh-cleanup-buffer () (interactive)
                       (delete-trailing-whitespace)
                       (untabify (point-min) (point-max))
                       (indent-region (point-min) (point-max))))

(global-set-key (kbd "C-c b") 'browse-url-at-point)

(global-set-key (kbd "C-c w") 'winner-undo)

(eval-after-load 'paredit
  ;; need a binding that works in the terminal
  '(progn
     (define-key paredit-mode-map (kbd "M-)") 'paredit-forward-slurp-sexp)
     (define-key paredit-mode-map (kbd "M-(") 'paredit-backward-slurp-sexp)))

;; atreus bindings
(global-set-key (kbd "C-x '") 'delete-other-windows)
(global-set-key (kbd "C-x ,") 'split-window-below)
(global-set-key (kbd "C-x .") 'split-window-right)
(global-set-key (kbd "C-x l") 'delete-window)

(defun pnh-music-read ()
  (interactive)
  (let* ((lines (with-temp-buffer
                  (insert-file "~/music/.dirs")
                  (buffer-substring-no-properties 1 (point-max))))
         (dirs (split-string lines "\n")))
    (ido-completing-read "Play: " dirs nil t)))

(defun pnh-music-choose ()
  (interactive)
  (save-window-excursion
    (start-process-shell-command "*mpc*" nil
                                 (format "mpc clear; mpc add %s; mpc play"
                                         (pnh-music-read)))))

(global-set-key (kbd "<f7>") 'pnh-music-choose)
