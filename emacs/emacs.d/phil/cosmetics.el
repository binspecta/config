;; lose the stupid pipe chars on the split-screen bar
(set-face-foreground 'vertical-border "white")
(set-face-background 'vertical-border "white")

;; themes

(defun zb ()
  (interactive)
  (load-theme 'zenburn)
  (set-face-background 'vertical-border "black")
  (set-face-foreground 'vertical-border "black")
  (require 'hl-line)
  (set-face-background 'hl-line "gray17")
  (set-face-foreground 'eshell-prompt "turquoise"))

(defun tw ()
  (interactive)
  (load-theme 'twilight)
  (set-face-background 'vertical-border "black")
  (set-face-foreground 'vertical-border "black")
  (require 'hl-line)
  (set-face-background 'magit-item-highlight "gray12")
  (set-face-foreground 'eshell-prompt "turquoise1")
  (set-face-background 'hl-line "black"))

(defun mk ()
  (interactive)
  (load-theme 'monokai)
  (set-face-background 'vertical-border "black")
  (set-face-foreground 'vertical-border "black")
  (require 'hl-line)
  (set-face-foreground 'eshell-prompt "turquoise1")
  (set-face-background 'hl-line "black")
  (eval-after-load 'diff-mode
    '(set-face-background 'diff-refine-change "gray18")))

(defun db ()
  (interactive)
  (load-theme 'deeper-blue)
  (set-face-background 'hl-line "dark slate gray"))

(defun bb ()
  "Black for use with glasstty in -nw"
  (interactive)
  (set-face-background 'vertical-border "bright green")
  (set-face-foreground 'vertical-border "bright green")
  (set-face-background 'hl-line "black"))

(eval-after-load 'hl-line
  '(set-face-background 'hl-line "darkseagreen2"))

;; TODO: port to dabbrevs
(defun disapproval () (interactive) (insert "ಠ_ಠ"))
(defun eyeroll () (interactive) (insert "◔_◔"))
(defun tables () (interactive) (insert "（╯°□°）╯︵ ┻━┻"))
(defun caruso () (interactive) (insert "( •_•) ( -_-)~⌐■-■ (⌐■_■)>"))
(defun shrug () (interactive) (insert "¯\\_(ツ)_/¯"))
(defun odin () (interactive) (insert "Hreðjar Óðins"))
(defun muk () (interactive) (insert "무"))
(defun mu () (interactive) (insert "無"))
(defun ww () (interactive) (insert "无为"))
(defun rectification () (interactive) (insert "正名"))
(defun tamade () (interactive) (insert "他妈的"))
(defun mingalaba () (interactive) (insert "မင်္ဂလာပါ"))
(defun nigaunla () (interactive) (insert "နေကောင်းလာ"))
(defun dn () (interactive) (insert "เดือน"))
(defun wat () (interactive) (insert "วัด"))
(defun is () (interactive) (insert "إن شاء الله"))
(defun monkey () (interactive) (insert "Nie mój cyrk, nie moje malpy"))

(when (and window-system (>= emacs-major-version 23))
  (let ((fontset (face-attribute 'default :fontset))
        (unifont "-gnu-unifont-medium-r-normal--13-120-75-75-c-0-iso10646-1"))
    (mapc
     (lambda (x)
       (set-fontset-font fontset (car x) (cdr x) nil))
     `(((#x02000 . #x026ff) . ,unifont )
       ((#x0210e . #x0210f) . "Unicode")
       ((#x02700 . #x028ff) . "Unicode")
       ((#x1f300 . #x1f6ff) . "Unicode"))) ))

;; monochrome? seriously?
(eval-after-load 'diff-mode
  '(progn
     (set-face-foreground 'diff-added "green4")
     (set-face-foreground 'diff-removed "red3")))

;; what's the deal, org? headers should be bold.
(eval-after-load 'org
  '(progn (set-face-attribute 'org-level-1 nil :weight 'bold)
          (set-face-attribute 'org-level-2 nil :weight 'bold)
          (set-face-attribute 'org-level-3 nil :weight 'bold)
          (set-face-attribute 'org-level-4 nil :weight 'bold)
          (font-lock-add-keywords
           nil
           '(("\(\+begin_src\)"
              (0 (progn (compose-region (match-beginning 1) (match-end 1) ?¦)
                        nil)))
             ("\(\+end_src\)"
              (0 (progn (compose-region (match-beginning 1) (match-end 1) ?¦)
                        nil)))))))

(eval-after-load 'magit
  '(set-face-background 'magit-item-highlight "dark grey"))

;; Display ido results vertically, rather than horizontally
(setq ido-decorations '("\n-> " "" "\n   " "\n   ..." "[" "]"
                        " [No match]" " [Matched]" " [Not readable]"
                        " [Too big]" " [Confirm]"))

(add-hook 'ido-minibuffer-setup-hook
          (defun ido-disable-line-truncation ()
            (set (make-local-variable 'truncate-lines) nil)))

(defun jf-ido-define-keys () ;; C-n/p is more intuitive in vertical layout
  (define-key ido-completion-map (kbd "C-n") 'ido-next-match)
  (define-key ido-completion-map (kbd "C-p") 'ido-prev-match))

(add-hook 'ido-setup-hook 'jf-ido-define-keys)

(if (<= (display-color-cells) 8)
  (eval-after-load 'paren-face
    '(set-face-foreground paren-face "magenta"))
  (when (string= "fbterm" (getenv "TERM"))
    (load "term/xterm")
    (xterm-register-default-colors)))

(setq whitespace-style '(face trailing lines-tail tabs))

(add-to-list 'auto-mode-alist '("\\.msg$" . message-mode))

(eval-after-load 'message-mode
  (add-hook 'message-mode-hook 'page-break-lines-mode))
