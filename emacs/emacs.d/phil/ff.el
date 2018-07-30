(when (and window-system (require 'exwm nil t))
  (defun pnh-trim-non-ff ()
    (delete-if-not (lambda (name)
                     (or (string-match "- Mozilla Firefox$" name)
                         (string-match "Chromium" name)))
                   ido-temp-list))

  (add-hook 'exwm-update-title-hook
            (defun pnh-ff-title-hook ()
              (when (string-match "Firefox" exwm-class-name)
                (exwm-workspace-rename-buffer exwm-title))))

  (exwm-input-set-key (kbd "s-i")
                      (defun pnh-icosahedron ()
                        (interactive)
                        (browse-url "https://icosahedron.website")))

  (exwm-input-set-key (kbd "s-d")
                      (defun pnh-ff-search ()
                        (interactive)
                        (browse-url
                         (format "https://duckduckgo.com/html?q=%s"
                                 (read-string "Search: ")))))

  (exwm-input-set-key (kbd "s-g")
                      (defun pnh-ff-gsearch ()
                        (interactive)
                        (browse-url
                         (format "https://google.com/search?q=%s"
                                 (read-string "Terms: ")))))

  (exwm-input-set-key (kbd "s-w")
                      (defun pnh-ff-wp-search ()
                        (interactive)
                        (browse-url
                         (format "https://en.wikipedia.org/w/index.php?search=%s"
                                 (read-string "Wikipedia: ")))))

  (exwm-input-set-key (kbd "s-n")
                      (defun pnh-ff ()
                        (interactive)
                        (browse-url (read-string "URL: "))))

  (exwm-input-set-key (kbd "s-e") 'eww)

  (setq browse-url-firefox-arguments '("-new-window")))
