;; █▀▄ █ █▀ ▄▀█ █▄▄ █░░ █▀▀
;; █▄▀ █ ▄█ █▀█ █▄█ █▄▄ ██▄
;; ========================
(setq inhibit-startup-message t)    ; Disable Startup Message
(tool-bar-mode -1)                  ; Disable Toolbar
(menu-bar-mode -1)                  ; Disable Menubar
(scroll-bar-mode -1)                ; Disable Scrollbar


;; █▀ █▀▀ ▀█▀ ▀█▀ █ █▄░█ █▀▀ █▀
;; ▄█ ██▄ ░█░ ░█░ █ █░▀█ █▄█ ▄█
;; ============================
(global-hl-line-mode t)                         ; Highligh Current Line
;; (load-theme `tango-dark)                        ; Colorscheme
(set-face-attribute 'default nil :height 150)   ; Font Size
(set-frame-parameter nil 'alpha-background 70)
(add-to-list 'default-frame-alist '(alpha-background . 70))


;; ORG Mode Stuff
(defvar dw/fixed-pitch-font "JetBrains Mono"
  "The font used for `default' and `fixed-pitch' faces.")
(defvar dw/fixed-pitch-size 102)
(defvar dw/variable-pitch-font "Noto Sans"
  "The font used for `variable-pitch' face.")
(defvar dw/variable-pitch-size 120)
(defvar dw/org-heading-font "Noto Sans"
  "The font used for Org Mode headings.")


;; █▄▀ █▀▀ █▄█ █▄▄ █ █▄░█ █▀▄ █ █▄░█ █▀▀ █▀
;; █░█ ██▄ ░█░ █▄█ █ █░▀█ █▄▀ █ █░▀█ █▄█ ▄█
;; ========================================
;; TMUX Keys
(global-set-key (kbd "C-SPC") 'Control-X-prefix)
(global-set-key (kbd "C-SPC x") 'save-buffers-kill-terminal)

;; Help Keys
(global-set-key (kbd "C-h b") 'describe-bindings)
(global-set-key (kbd "C-h f") 'counsel-describe-function)
(global-set-key (kbd "C-h i") 'info)
(global-set-key (kbd "C-h k") 'describe-key)
(global-set-key (kbd "C-h v") 'counsel-describe-variable)

;; Function Keys
(global-set-key (kbd "<C-tab>") 'other-window)
(global-set-key (kbd "C-f") 'swiper-isearch)
(global-set-key (kbd "C-w") 'kill-region)
(global-set-key (kbd "M-g") 'goto-line)


;; █▀▄▀█ █▀▀ █░░ █▀█ ▄▀█
;; █░▀░█ ██▄ █▄▄ █▀▀ █▀█
;; =====================
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(package-initialize)
;; (package-refresh-contents)
(unless package-archive-contents (package-refresh-contents))

;; EVIL
(unless (package-installed-p 'evil) (package-install 'evil))
(require 'evil)
(evil-mode 1)

;; COLORSCHEME
(unless (package-installed-p 'catppuccin-theme)
  (package-install 'catppuccin-theme))
(load-theme 'catppuccin :no-confirm)
(setq catppuccin-flavor 'mocha)
(catppuccin-reload)

;; DOOM MODELINE
(unless (package-installed-p 'doom-modeline)
  (package-install 'doom-modeline))
(require 'doom-modeline)
(doom-modeline-mode 1)


;; UNTOUCHABLES
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages '(evil)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
