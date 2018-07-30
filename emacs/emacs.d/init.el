;;; My general personalizations

;; Random stuff

(package-initialize)

(require 'cl)

(setq custom-file (expand-file-name "~/.emacs.d/custom.el")
      ispell-extra-args '("--keyboard=dvorak")
      ido-use-virtual-buffers t
      org-default-notes-file "~/.dotfiles/.notes.org"
      org-remember-default-headline 'bottom
      org-completion-use-ido t
      epa-armor t
      load-prefer-newer t
      visible-bell t
      tls-checktrust 'ask
      el-get-allow-insecure nil
      inhibit-startup-message t
      uniquify-buffer-name-style 'post-forward
      browse-url-browser-function 'browse-url-firefox)

(when window-system
  (setq scroll-conservatively 1))

;; 3rd-party packages
(dolist (l (directory-files (concat user-emacs-directory "lib") nil "^[^\.]"))
  (add-to-list 'load-path (concat user-emacs-directory "lib/" l))
  (autoload (intern l) (concat l ".el")))

;; For some reason, update-directory-autoloads *always* writes its
;; paths as relative to user-emacs-directory, so we have to add
;; this. If we add user-emacs-directory by itself to load-path, Emacs
;; warns us that we shouldn't do that, so we trick it.
(add-to-list 'load-path (concat user-emacs-directory "/phil/../"))
(load (concat user-emacs-directory "my-autoload.el") t)
(load custom-file t)

;; personal stuff
(mapc 'load (directory-files (concat user-emacs-directory user-login-name)
                             t "^[^#].*el$"))

(setq custom-theme-load-path
      (directory-files (concat user-emacs-directory "themes") t "^[^\.]"))

(require 'find-file-in-project)
(add-to-list 'ffip-patterns "*.lua")
(add-to-list 'ffip-patterns "*.md")
(add-to-list 'ffip-patterns "*.lisp")
(add-to-list 'ffip-patterns "*.clj")
(add-to-list 'ffip-patterns "*.cljs")
(add-to-list 'ffip-patterns "*.cljc")
(add-to-list 'ffip-patterns "*.edn")
(add-to-list 'ffip-patterns "*.log")
(add-to-list 'ffip-patterns "*.sh")
(add-to-list 'ffip-patterns "*.sql")
(add-to-list 'ffip-patterns "*.txt")
(add-to-list 'ffip-patterns "*.yml")
(add-to-list 'ffip-patterns "*.xml")
(add-to-list 'ffip-patterns "*.json")
(add-to-list 'ffip-patterns "Dockerfile")

(when (require 'smex nil t)
  (smex-initialize)
  (global-set-key (kbd "M-x") 'smex))

(defalias 'yes-or-no-p 'y-or-n-p)

(column-number-mode t)

(winner-mode)

(ido-ubiquitous-mode t)

(eval-after-load 'markdown-mode
  (progn (add-hook 'markdown-mode-hook 'flyspell-mode)
         (add-hook 'markdown-mode-hook 'auto-fill-mode)))

(add-hook 'text-mode-hook 'flyspell-mode)
(add-hook 'text-mode-hook 'auto-fill-mode)

(defun uuid ()
  (interactive)
  (insert (shell-command-to-string "uuid -v 4")))

;; why not?
(eshell)
;; graaaaaaah! eshell doesn't respect eval-after-load for some reason:
(with-current-buffer "*eshell*" (setq pcomplete-cycle-completions nil))
(set-face-foreground 'eshell-prompt "turquoise")
(put 'upcase-region 'disabled nil)

;; Mitigate Bug#28350 (security) in Emacs 25.2 and earlier.
(eval-after-load "enriched"
  '(defun enriched-decode-display-prop (start end &optional param)
     (list start end)))
