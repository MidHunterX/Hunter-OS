;; Without init.el: 0.15s

;; ================================@[130ms]================================ ;;
;; Total Time: 280ms


;; █▀▄ █ █▀ ▄▀█ █▄▄ █░░ █▀▀
;; █▄▀ █ ▄█ █▀█ █▄█ █▄▄ ██▄
(setq inhibit-startup-message t)    ; Disable Startup Message
(tool-bar-mode -1)                  ; Disable Toolbar
(menu-bar-mode -1)                  ; Disable Menubar
(scroll-bar-mode -1)                ; Disable Scrollbar
(setq use-dialog-box nil)

;; █▀ █▀▀ ▀█▀ ▀█▀ █ █▄░█ █▀▀ █▀
;; ▄█ ██▄ ░█░ ░█░ █ █░▀█ █▄█ ▄█

;; ENCODING
(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(setq default-buffer-file-coding-system 'utf-8)

;; VISUAL
(global-hl-line-mode t)                         ; Highligh Current Line
(global-display-line-numbers-mode 1)
(show-paren-mode 1)
;;(setq visible-bell 1)
(setq blink-matching-paren nil)
(setq show-paren-delay 0.2)
(setq show-paren-highlight-openparen t)
(setq show-paren-when-point-inside-paren t)
(setq cursor-in-non-selected-windows 'hollow)
(setq highlight-nonselected-windows t)
(setq bidi-display-reordering nil)  ; Disable bidirectional txt for performance
(setq inhibit-startup-buffer-menu t)  ; buffer switching gets in the way
(setq scroll-margin 8)
(setq scroll-conservatively scroll-margin)
(setq select-enable-clipboard t)
(set-face-attribute 'default nil :height 150)   ; Font Size
(set-frame-parameter nil 'alpha-background 80)
(add-to-list 'default-frame-alist '(font . "jetbrains mono nerd font-14"))
(add-to-list 'default-frame-alist '(alpha-background . 80))
(setq-default frame-title-format "%b %& emacs")
(setq-default indicate-empty-lines t)  ; show blank lines at EOF
(defalias 'yes-or-no-p 'y-or-n-p)  ; answering just 'y' or 'n' is sufficient

;; INDENTATION
(setq default-tab-width 4)
(setq tab-width 4)
(setq default-fill-column 80)
(setq fill-column 80)
(setq-default evil-indent-convert-tabs nil)
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
(setq-default evil-shift-round nil)

;; ORG Mode Stuff
(defvar dw/fixed-pitch-font "JetBrains Mono"
  "The font used for `default' and `fixed-pitch' faces.")
(defvar dw/fixed-pitch-size 102)
(defvar dw/variable-pitch-font "Noto Sans"
  "The font used for `variable-pitch' face.")
(defvar dw/variable-pitch-size 120)
(defvar dw/org-heading-font "Noto Sans"
  "The font used for Org Mode headings.")

;; =================================@[70ms]================================= ;;
;; Total Time: 350ms


;; █▄▀ █▀▀ █▄█ █▄▄ █ █▄░█ █▀▄ █ █▄░█ █▀▀ █▀
;; █░█ ██▄ ░█░ █▄█ █ █░▀█ █▄▀ █ █░▀█ █▄█ ▄█
;; ========================================
;; TMUX Keys
(global-set-key (kbd "C-SPC") 'Control-X-prefix)

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

;; =================================@[0ms]================================= ;;
;; Total Time: 350ms


;; █▀▄▀█ █▀▀ █░░ █▀█ ▄▀█
;; █░▀░█ ██▄ █▄▄ █▀▀ █▀█
;; =====================
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(package-initialize)
;; (package-refresh-contents)
(unless package-archive-contents (package-refresh-contents))

;; ================================@[180ms]================================ ;;
;; Total Time: 530ms

;; EVIL
(unless (package-installed-p 'evil) (package-install 'evil))
(setq evil-want-C-u-scroll t)
(setq evil-want-C-i-jump t)
(setq evil-undo-system 'undo-redo)
(require 'evil)
(evil-mode 1)
(with-eval-after-load 'evil
  ;; set leader key in all states
  (evil-set-leader nil (kbd "C-SPC"))
  ;; set leader key in normal state
  (evil-set-leader '(normal) (kbd "<SPC>"))
  ;; Redo
  (evil-define-key 'normal 'global (kbd "U") 'undo-redo)
  ;; Save buffer
  (evil-define-key 'normal 'global (kbd "<leader>w") 'save-buffer)
  ;; Interactive file name search.
  (evil-define-key 'normal 'global (kbd "<leader>pf") 'project-find-file)
  ;; Interactive open-buffer switch.
  (evil-define-key 'normal 'global (kbd "<leader>x") 'kill-this-buffer))

;; ================================@[140ms]================================ ;;
;; Total Time: 670ms

;; COLORSCHEME
(unless (package-installed-p 'catppuccin-theme)
  (package-install 'catppuccin-theme))
(load-theme 'catppuccin :no-confirm)
(setq catppuccin-flavor 'mocha)
(catppuccin-set-color 'base "#262626")
(catppuccin-reload)

;; ================================@[1780ms]================================ ;;
;; Total Time: 1920ms

;; DOOM MODELINE
(unless (package-installed-p 'doom-modeline)
  (package-install 'doom-modeline))
(require 'doom-modeline)
(doom-modeline-mode 1)

;; ================================@[130ms]================================ ;;
;; Total Time: 2050ms

;; DASHBOARD
(unless (package-installed-p 'dashboard) (package-install 'dashboard))
(setq wallpaper (with-temp-buffer
                    (insert-file-contents "~/.cache/swww/eDP-1")
                    (thing-at-point 'line t)))
;; supported values are: string (filepath), 'official, 'logo and integers.
(setq dashboard-startup-banner wallpaper)
(setq dashboard-image-banner-max-width 600)
(setq dashboard-banner-logo-title "Welcome to Emacs")
(setq dashboard-center-content t)
(setq dashboard-vertically-center-content t)
(setq dashboard-show-shortcuts t)
(setq dashboard-items '((recents   . 5)
                        (projects  . 5)
                        (agenda    . 5)))
(setq dashboard-navigation-cycle t)
(setq dashboard-display-icons-p t)
(setq dashboard-icon-type 'nerd-icons)
(setq dashboard-startupify-list '(dashboard-insert-banner
                                  dashboard-insert-newline
                                  dashboard-insert-banner-title
                                  dashboard-insert-newline
                                  dashboard-insert-navigator
                                  dashboard-insert-newline
                                  dashboard-insert-init-info
                                  dashboard-insert-items
                                  dashboard-insert-newline
                                  dashboard-insert-footer))
(setq dashboard-set-heading-icons t)
(setq dashboard-set-file-icons t)
(require 'dashboard)
(dashboard-setup-startup-hook)

;; =================================@[10ms]================================= ;;
;; Total Time: 2060ms

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
