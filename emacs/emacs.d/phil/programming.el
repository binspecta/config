;;; general

(add-hook 'prog-mode-hook 'whitespace-mode)
(add-hook 'prog-mode-hook 'prettify-symbols-mode)
(add-hook 'prog-mode-hook 'idle-highlight-mode)
(add-hook 'prog-mode-hook 'hl-line-mode)
(add-hook 'prog-mode-hook 'page-break-lines-mode)
(add-hook 'prog-mode-hook (defun pnh-add-watchwords ()
                            (font-lock-add-keywords
                             nil `(("\\<\\(FIX\\(ME\\)?\\|TODO\\)"
                                    1 font-lock-warning-face t)))))

(global-set-key (kbd "C-c l") (lambda () (interactive) (insert "λ")))

(setq page-break-lines-char ?-)

(defun pnh-paredit-no-space ()
  (interactive)
  (set (make-local-variable 'paredit-space-for-delimiter-predicates)
       '((lambda (endp delimiter) nil))))

;; disable this in low-color environments
(when (<= (display-color-cells) 8)
  (defun hl-line-mode () (interactive)))

;; unfortunately some codebases use tabs. =(
;; http://www.emacswiki.org/pics/static/TabsSpacesBoth.png

(set-default 'tab-width 4)
(set-default 'c-basic-offset 2)

(defalias 'tdoe 'toggle-debug-on-error)

;; (add-hook 'prog-mode-hook (lambda ()
;;                             (add-to-list 'after-change-functions 'size-limit)))

(defvar size-limit-lines 25)

(defun size-limit (beginning end length)
  ;; (let* ((bod (save-excursion (beginning-of-defun) (line-number-at-pos)))
  ;;        (eod (save-excursion (end-of-defun) (line-number-at-pos))))
  ;;   (when (and (= 0 length) (> (- eod bod) size-limit-lines))
  ;;     (message "Function is too big!")
  ;;     (delete-region beginning end)))
  )

(global-set-key (kbd "C-c \\") (lambda () (interactive) (insert "λ")))

(defun normal-random (mean dev)
  (let ((x (+ 1 (sqrt (* -2 (log (random* 1.0))))))
        (y (/ (cos (* 2 pi (random* 1.0))) 2.0)))
    (+ mean (* x y dev))))

(defun choose-from (lst) (nth (random (length lst)) lst))

(defun random-name (&optional name syllables)
  (let* ((common-closed '("b" "c" "d" "f" "g" "h" "k" "l" "m" "n" "p"
                          "r" "s" "t" "w"))
         (uncommon-closed '("x" "z" "q" "v" "v" "j" "j" "gg" "ll" "ss" "tt"))
         (enders '("b" "d" "g" "m" "n" "s" "r" "t"))
         ;; weight towards common letters
         (closed (append common-closed common-closed enders uncommon-closed))
         (vowels '("a" "e" "i" "o" "u" "ie" "ou"))
         (syllables (or syllables (ceiling (normal-random 2.5 1.5))))
         (name (or name (concat (upcase (choose-from common-closed))
                                (choose-from vowels)
                                (choose-from closed)))))
    (if (< syllables 3)
        (concat name (choose-from vowels) (choose-from enders))
      (random-name (concat name (choose-from vowels) (choose-from closed))
                   (- syllables 1)))))

(defun insert-random-name (syllables)
  (interactive "P")
  (insert (random-name nil syllables) " "))

(defun add-metric ()
  (interactive)
  (let ((year (thing-at-point 'number)))
    (forward-word)
    (insert (format "/%s" (* (- year 1970) 365 52 7 24 60 60)))))


;;; ruby

(add-hook 'ruby-mode-hook 'pnh-paredit-no-space)
(add-hook 'ruby-mode-hook 'inf-ruby-keys)

(eval-after-load 'inf-ruby
  '(add-to-list 'inf-ruby-implementations '("bundler" . "bundle console")))

(eval-after-load 'ruby-mode
  '(define-key ruby-mode-map (kbd "#") (defun senny-ruby-interpolate ()
                                         "In a \"string\", interpolate."
                                         (interactive)
                                         (insert "#")
                                         (when (and
                                                (looking-back "\".*")
                                                (looking-at ".*\""))
                                           (insert "{}")
                                           (backward-char 1)))))


;;; clojure

(setq inferior-lisp-command "lein repl"
      monroe-detail-stacktraces t)

(add-hook 'clojure-mode-hook 'paredit-mode)
(add-hook 'clojure-mode-hook 'monroe-interaction-mode)

(defun pnh-monroe-run ()
  (interactive)
  (monroe-eval-buffer)
  (monroe-input-sender (get-buffer-process monroe-repl-buffer) "(-main)"))

(eval-after-load 'monroe
  '(define-key monroe-interaction-mode-map (kbd "C-x C-j") 'pnh-monroe-run))

;; TODO: echo to minibuffer
(defun pnh-monroe-eval-sexp ()
  (interactive)
  (monroe-eval-buffer)
  (monroe-input-sender (get-buffer-process monroe-repl-buffer)
                       (format "%s" (preceding-sexp))))

(eval-after-load 'monroe
  '(define-key monroe-interaction-mode-map (kbd "C-x C-e") 'pnh-monroe-eval-sexp))

(defun pnh-monroe-scad ()
  (interactive)
  (let ((str (format "(spit \"atreus.scad\" (write-scad %s))"
                     (preceding-sexp))))))

(eval-after-load 'monroe
  '(define-key monroe-interaction-mode-map (kbd "C-c C-s") 'pnh-monroe-scad))


;;; elisp

(add-hook 'emacs-lisp-mode-hook 'turn-on-eldoc-mode)
(add-hook 'emacs-lisp-mode-hook 'paredit-mode)

(define-key emacs-lisp-mode-map (kbd "C-c v") 'eval-buffer)

(define-key read-expression-map (kbd "TAB") 'lisp-complete-symbol)

(define-key emacs-lisp-mode-map (kbd "C-c e")
  (defun eval-and-replace ()
    "Replace the preceding sexp with its value."
    (interactive)
    (backward-kill-sexp)
    (condition-case nil
        (prin1 (eval (read (current-kill 0)))
               (current-buffer))
      (error (message "Invalid expression")
             (insert (current-kill 0))))))


;;; lisp (mostly for l2l)

(define-key lisp-mode-shared-map (kbd "RET") 'reindent-then-newline-and-indent)
(add-hook 'lisp-mode-hook 'paredit-mode)
(define-key lisp-mode-map (kbd "{") 'paredit-open-curly)


;;; racket and scheme

;; geiser
(add-hook 'scheme-mode-hook 'paredit-mode)

;; (setq geiser-active-implementations '(racket)
;;       geiser-racket-binary '("racket" "-l" "errortrace"))

(add-hook 'racket-mode-hook 'paredit-mode)
(eval-after-load 'racket-mode
  '(progn (define-key racket-mode-map (kbd "C-c C-k") 'racket-run)
          (define-key racket-mode-map (kbd "C-c C-d") 'racket-describe)
          (define-key racket-mode-map (kbd "{") 'paredit-open-curly)
          (define-key racket-mode-map (kbd "}") 'paredit-close-curly)
          (define-key racket-mode-map (kbd "RET")
            'reindent-then-newline-and-indent)))

(autoload 'shr-visit-file "shr" nil t)

;; this is great for docs. TODO: hook into geiser or whatever
(defun pnh/shr-follow ()
  (interactive)
  (let ((raw-url (get-text-property (point) 'shr-url)))
    (if raw-url
        (if (equal 0 (string-match "https?://" raw-url))
            (shr-browse-url raw-url)
          (shr-visit-file (concat default-directory raw-url)))
      (message "No link under point"))))

;; why doesn't shr do this already?
(defadvice shr-visit-file (after pnh-default-directory activate)
  (with-current-buffer "*html*"
    (setq default-directory (file-name-directory file))))

(eval-after-load 'shr-mode
  '(define-key shr-map (kbd "RET") 'pnh/shr-follow))

;; microscheme
(add-to-list 'auto-mode-alist '("\\.ms\\'" . scheme-mode))


;;; ocaml

(add-hook 'tuareg-mode-hook 'paredit-mode)
(add-hook 'tuareg-mode-hook 'pnh-paredit-no-space)
(add-hook 'tuareg-mode-hook (lambda () (run-hooks 'prog-mode-hook)))

(add-to-list 'load-path "~/.opam/system/build/utop.1.5/src/top/")
(autoload 'utop "utop" "Toplevel for OCaml" t)
(setq utop-command "opam config exec \"utop -emacs\"")
(setq tuareg-interactive-program "opam config exec ocaml")
(autoload 'utop-setup-ocaml-buffer "utop" "Toplevel for OCaml" t)
(add-hook 'tuareg-mode-hook 'utop-setup-ocaml-buffer)

(eval-after-load 'tuareg-mode
  '(progn
     (define-key tuareg-mode-map (kbd "C-M-h") 'backward-kill-word)
     (define-key tuareg-mode-map (kbd "[") 'paredit-open-square)
     (define-key tuareg-mode-map (kbd "]") 'paredit-close-square)
     (define-key tuareg-mode-map (kbd "{") 'paredit-open-curly)
     (define-key tuareg-mode-map (kbd "}") 'paredit-close-curly)
     (define-key tuareg-mode-map (kbd "<backspace>") 'paredit-backward-delete)
     (define-key tuareg-mode-map (kbd "RET") 'reindent-then-newline-and-indent)
     (define-key tuareg-mode-map (kbd "C-c C-k") 'tuareg-eval-buffer)
     (define-key tuareg-mode-map (kbd "C-c C-s") 'utop)
     ;; workaround for tuareg bug: https://forge.ocamlcore.org/tracker/index.php?func=detail&aid=1345&group_id=43&atid=255
     (setq tuareg-find-phrase-beginning-and-regexp
           "\\<\\(and\\)\\>\\|\\<\\(class\\|e\\(?:nd\\|xception\\)\\|let\\|module\\|s\\(?:ig\\|truct\\)\\|type\\)\\>\\|^#[ 	]*[a-z][_a-z]*\\>\\|;;")))


;;; er lang

(defun pnh-ct-results ()
  (interactive)
  (let* ((default-directory (locate-dominating-file default-directory "logs"))
         (runs (directory-files "logs" t "ct_run\.c"))
         (runs (reverse (sort runs 'string<))))
    (browse-url-of-file (concat (first runs) "/index.html"))))

;; therefore erlang.el version on marmalade is too old to be usable
(let ((tools (file-expand-wildcards "/usr/lib/erlang/lib/tools-*")))
  ;; oh yeah, and the path for this isn't even static; super gross.
  (when (first tools)
    (add-to-list 'load-path (concat (first tools) "/emacs"))))

(autoload 'erlang-mode "erlang" "erlang" t)

(add-to-list 'auto-mode-alist '("\\.erl$" . erlang-mode)) ; srsly?
(add-to-list 'auto-mode-alist '("rebar.config$" . erlang-mode))

(add-hook 'erlang-mode-hook (lambda () (run-hooks 'prog-mode-hook)))
(add-hook 'erlang-mode-hook 'pnh-paredit-no-space)
(add-hook 'erlang-mode-hook 'paredit-mode)
(add-hook 'erlang-mode-hook (lambda () (idle-highlight-mode -1)))

(eval-after-load 'erlang
  '(progn
     (setq erlang-indent-level 4)
     (define-key erlang-mode-map "{" 'paredit-open-curly)
     (define-key erlang-mode-map "}" 'paredit-close-curly)
     (define-key erlang-mode-map "[" 'paredit-open-bracket)
     (define-key erlang-mode-map "]" 'paredit-close-bracket)
     (define-key erlang-mode-map (kbd "C-M-h") 'backward-kill-word)
     (define-key erlang-mode-map (kbd "RET")
       'reindent-then-newline-and-indent)))

;; erlmode is on hold for now
;; (add-to-list 'load-path "/home/phil/src/erlmode/")
;; (autoload 'erlang-mode "erlmode-start" nil t)

;; ... but edts needs a lot of work
;; (add-to-list 'load-path (expand-file-name "~/src/edts/elisp/edts"))
;; (autoload 'edts-mode "edts" "erlang development tool suite" t)
;; (add-hook 'erlang-mode-hook 'edts-mode)

;; (setq edts-root-directory (expand-file-name "~/src/edts"))

;; ;; monkeypatch around completion for now
;; (eval-after-load 'edts-shell
;;   '(defun edts-shell-maybe-toggle-completion (last-output)))
;; requires my fork, plus manual installation of eproject+path-utils

;; heck let's try distel, just for completeness sake:

(add-to-list 'load-path "~/src/distel/elisp")
(eval-after-load 'erlang
  '(progn (require 'distel)
          (distel-setup)))



;;; forth

(autoload 'forth-mode "../gforth/gforth.el" nil t) ; /usr/share/emacs/site-lisp
(add-to-list 'auto-mode-alist '("\\.fs$" . forth-mode))

;; for some reason idle-highlight and whitespace-mode screw up forth font-lock
(add-hook 'forth-mode-hook (defun pnh-forth-hook ()
                             (hl-line-mode 1)
                             (pnh-paredit-no-space)
                             (paredit-mode 1)
                             (page-break-lines-mode 1)
                             (my-kill-word-key)
                             (define-key forth-mode-map (kbd "C-c C-k") 'compile)))


;;; lua

(setq lua-default-application "lua-repl"
      lua-documentation-function 'eww
      lua-local-require-completions t)

(setenv "LUA_REPL_RLWRAP" "sure") ; suppress rlwrap, which will fail

(add-hook 'lua-mode-hook 'paredit-mode)
(add-hook 'lua-mode-hook 'pnh-paredit-no-space)
(add-hook 'lua-mode-hook (defun pnh-lua-prettify ()
                           (push '("function" . "λ") prettify-symbols-alist)
                           (push '("<=" . ?≤) prettify-symbols-alist)
                           (push '(">=" . ?≥) prettify-symbols-alist)))

(defun pnh-lua-manual ()
  (interactive)
  (eww-open-file "/usr/share/doc/lua5.1-doc/doc/manual.html"))

(defun pnh-love-manual ()
  (interactive)
  ;; would be nice to jump to a specific page, but the filenames are garbled
  (eww-open-file "/home/phil/docs/love-ref.html"))

(defun pnh-lua-send-file ()
  (interactive)
  (lua-send-string (format "_ = dofile('%s') print('ok')" buffer-file-name)))

(eval-after-load 'lua-mode
  '(progn
     (define-key lua-mode-map (kbd "C-c C-s") 'pnh-lua-repl)
     (define-key lua-mode-map (kbd "C-c C-r") 'lua-send-region)
     (define-key lua-mode-map (kbd "C-c C-k") 'pnh-lua-send-file)
     (define-key lua-mode-map (kbd "C-M-x") 'lua-send-defun)
     (define-key lua-mode-map (kbd "[") 'paredit-open-square)
     (define-key lua-mode-map (kbd "]") 'paredit-close-square)
     (define-key lua-mode-map (kbd "{") 'paredit-open-curly)
     (define-key lua-mode-map (kbd "}") 'paredit-close-curly)))

(add-hook 'lua-mode-hook
          (defun pnh-lua-mode-hook ()
            (pnh-paredit-no-space)
            (paredit-mode 1)))

(defun pnh-lua-repl ()
  (interactive)
  (lua-start-process)
  ;; I think this breaks because sending the completion code causes the prompt
  ;; to print, which throws off the point offset.
  (make-variable-buffer-local 'completion-at-point-functions)
  (add-to-list 'completion-at-point-functions 'lua-complete-function))

(when (functionp 'flymake-lua-load)
  (add-hook 'lua-mode-hook 'flymake-lua-load))

;; (defvar _lua-init
;;   (setq lua-process-init-code
;;         (concat lua-process-init-code)))


;;; C

(eval-after-load 'cc-mode
  '(define-key c-mode-map (kbd "C-c C-k") 'compile))
