;; for some reason debian screws this up for hand-compiled emacsen
(add-to-list 'load-path "/usr/share/emacs/site-lisp/mu4e")

(autoload 'mu4e "mu4e" "" t)

;; incoming
(setq mu4e-maildir-shortcuts '(("/INBOX"        . ?i)
                               ("/sent"         . ?s)
                               ("/drafts"       . ?d)
                               ("/INBOX.Archive" . ?a))
      mu4e-get-mail-command "offlineimap"
      mu4e-view-prefer-html t
      mu4e-headers-leave-behavior 'apply
      mu4e-show-images t
      mu4e-view-show-addresses t)

;; outgoing
(setq message-send-mail-function 'smtpmail-send-it
      smtpmail-stream-type 'starttls
      smtpmail-default-smtp-server "smtp.gmail.com"
      smtpmail-smtp-server "smtp.gmail.com"
      smtpmail-smtp-service 587
      user-mail-address "phil@hagelb.org"
      user-full-name  "Phil Hagelberg"
      mu4e-compose-signature-auto-include nil
      message-kill-buffer-on-exit t)

(add-hook 'mu4e-compose-mode-hook 'mml-secure-sign)
(add-hook 'mu4e-compose-mode-hook 'flyspell-mode)

(defun my-render-html-message ()
  (let ((dom (libxml-parse-html-region (point-min) (point-max))))
    (erase-buffer)
    (shr-insert-document dom)
    (goto-char (point-min))))

(setq mu4e-html2text-command 'my-render-html-message)

(eval-after-load 'mu4e
  '(progn (require 'mu4e-contrib)
          ;; (setq mu4e-html2text-command 'mu4e-shr2text)
          (define-key mu4e-main-mode-map (kbd "C-r") 'ignore)))

(add-hook 'mu4e-view-mode-hook
          (lambda()
            ;; try to emulate some of the eww key-bindings
            (local-set-key (kbd "<tab>") 'shr-next-link)
            (local-set-key (kbd "<backtab>") 'shr-previous-link)))

(when (require 'smtpmail-async nil t)
  (setq send-mail-function 'async-smtpmail-send-it
        message-send-mail-function
        (lambda ()
          (smtpmail-send-it)
          (setq message-send-mail-function
                'async-smtpmail-send-it))))

(defalias 'm 'mu4e)
