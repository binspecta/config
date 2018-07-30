;; -*- lexical-binding: t -*-
(when (and window-system (require 'exwm nil t))
  (require 'exwm-config)
  (exwm-config-default)

  (setq exwm-workspace-number 9
        exwm-workspace-show-all-buffers t
        exwm-layout-show-all-buffers t)

  (require 'exwm-systemtray)
  (exwm-systemtray-enable)
  (display-time-mode 1)
  (display-battery-mode 1)
  (setq display-time-string-forms '((format-time-string "%H:%M " now)))

  (add-hook 'exwm-manage-finish-hook
            (defun pnh-exwm-manage-hook ()
              (when (or (string= exwm-class-name "URxvt")
                        (string= exwm-class-name "love"))
                (exwm-input-release-keyboard))
              (when (string-match "Chromium" exwm-class-name)
                (exwm-layout-hide-mode-line))
              (when (string-match "Firefox" exwm-class-name)
                (setq ido-make-buffer-list-hook 'pnh-trim-non-ff)
                (exwm-layout-hide-mode-line))))

  (exwm-enable-ido-workaround)

  (dolist (k '(("s-l" "gnome-screensaver-command -l")
               ("s-v" "killall evrouter; evrouter /dev/input/*")
               ("s-s" "scrot")
               ("s-S-s" "scrot -s")
               ("s-<return>" "urxvt")
               ("S-<f7>" "music-random")
               ("<f8>" "mpc toggle")
               ("<f10>" "mpc next")
               ("<XF86AudioLowerVolume>"
                "amixer sset Master 5%-")
               ("<XF86AudioRaiseVolume>"
                "amixer set Master unmute; amixer sset Master 5%+")))
    (let ((f (lambda () (interactive)
               (save-window-excursion
                 (start-process-shell-command (cadr k) nil (cadr k))))))
      (exwm-input-set-key (kbd (car k)) f)))

  (exwm-input-set-key (kbd "<f7>") 'pnh-music-choose)

  (defun pnh-run (command)
    (interactive (list (read-shell-command "$ ")))
    (start-process-shell-command command nil command))
  (define-key exwm-mode-map (kbd "C-x s-m") 'pnh-run)
  (global-set-key (kbd "C-x s-m") 'pnh-run)

  (exwm-input-set-simulation-keys
   (mapcar (lambda (c) (cons (kbd (car c)) (cdr c)))
           `(("C-b" . left)
             ("C-f" . right)
             ("C-p" . up)
             ("C-n" . down)
             ("C-a" . home)
             ("C-e" . end)
             ("M-v" . prior)
             ("C-v" . next)
             ("C-d" . delete)
             ("C-m" . return)
             ("C-i" . tab)
             ("C-g" . escape)
             ("C-s" . ?\C-f)
             ("C-y" . ?\C-v)
             ("M-w" . ?\C-c)
             ("M-<" . C-home)
             ("M->" . C-end)
             ("C-M-h" . C-backspace))))

  (when (string= system-name "alto")
    (require 'exwm-randr)
    (setq exwm-randr-workspace-output-plist '(2 "eDP-1" 3 "DP-1" 1 "HDMI-2"
                                                4 "DP-1" 5 "DP-1" 6 "DP-1"
                                                7 "eDP-1" 8 "eDP-1" 9 "eDP-1"
                                                0 "HDMI-2"))
    (add-hook 'exwm-randr-screen-change-hook
              (lambda ()
                (start-process-shell-command "xrandr" nil "~/bin/rotated")))
    (exwm-randr-enable))

  (global-set-key (kbd "C-x m")
                  (defun pnh-eshell-per-workspace (n)
                    (interactive "p")
                    (eshell (+ (case n (4 10) (16 20) (64 30) (t 0))
                               exwm-workspace-current-index))))

  (server-start))
