(setq compilation-scroll-output t ; byte-compilation fails w/o this
      ido-enable-tramp-completion nil
      vc-follow-symlinks t
      ediff-window-setup-function 'ediff-setup-windows-plain
      tags-revert-without-query t ; why would you ever not want this?
      ruby-insert-encoding-magic-comment nil
      ;; can't interrupt geiser repls without this
      geiser-repl-read-only-prompt-p nil)

(delete 'try-expand-dabbrev-from-kill hippie-expand-try-functions-list)
(delete 'try-expand-line hippie-expand-try-functions-list)
(delete 'try-expand-list hippie-expand-try-functions-list)
(delete 'try-complete-file-name-partially hippie-expand-try-functions-list)
(delete 'try-complete-file-name hippie-expand-try-functions-list)

(eval-after-load 'magit
  '(ignore-errors
     (setq magit-diff-refine-hunk t)
     ;; don't be a jerk, magit
     (define-key git-commit-mode-map (kbd "C-x k") 'git-commit-abort)
     ;; don't use popups unless I ask (only tested against magit 1.2.1)
     (define-key magit-mode-map (kbd "P")
       (lambda (query)
         (interactive "p")
         (if (= 1 query)
             (magit-key-mode-popup-pushing)
           (magit-push))))
     (define-key magit-mode-map (kbd "F")
       (lambda (query)
         (interactive "p")
         (if (= 1 query)
             (magit-pull)
           (magit-key-mode-popup-pulling))))
     ;; plz not to refresh log buffer when I cherry-pick, mkay?
     (define-key magit-log-mode-map (kbd "A")
       (lambda ()
         (interactive)
         (flet ((magit-need-refresh (f)))
           (magit-cherry-pick-item))))))

(autoload 'yaml-mode "yaml-mode" nil t)
(add-to-list 'auto-mode-alist '("\\.yml$" . yaml-mode))

(add-to-list 'auto-mode-alist '("\\.md$" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.markdown$" . markdown-mode))

(add-hook 'oddmuse-mode-hook
          (lambda ()
            (unless (string-match "question" oddmuse-post)
              (setq oddmuse-post (concat "uihnscuskc=1;" oddmuse-post)))))

(setq-default ispell-program-name "aspell")

(add-to-list 'completion-ignored-extensions ".exe")

(defun leathekd-suck-it (suckee)
  "Insert a comment of appropriate length about what can suck it."
  (interactive "MWhat can suck it? ")
  (let ((prefix (concat ";; " suckee " can s"))
        (postfix "ck it!")
        (col (current-column)))
    (insert prefix)
    (dotimes (_ (- 80 col (length prefix) (length postfix))) (insert "u"))
    (insert postfix)))

(defun pnh-blog ()
  (interactive)
  (let ((post-number (first (split-string (buffer-name) "\\."))))
    (shell-command-to-string (format "rake post POST=%s" post-number))))

(global-set-key (kbd "C-c p") 'pnh-blog)

(defun pnh-insert-date ()
  (interactive)
  (insert (format-time-string "%Y-%m-%d %H:%M:%S" (current-time))))

;; cl.el byte compiler warnings can suuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuck it!
(defalias 'byte-compile-cl-warn 'identity)

(setenv "GHI_NO_COLOR" "y")

;; old cider crashes without this
(setq clojure--prettify-symbols-alist '())

(add-hook 'visual-line-mode-hook (lambda () (auto-fill-mode -1)))

(defun pnh-prime-gpg ()
  (interactive)
  (start-process-shell-command "prime-gpg" nil
                               "gpg --output /dev/null -sab --yes /etc/hosts"))
