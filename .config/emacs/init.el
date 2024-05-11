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
(load-theme `tango-dark)                        ; Colorscheme
(set-face-attribute 'default nil :height 140)   ; Font Size

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

;; UNTOUCHABLES
(custom-set-variables '(package-selected-packages '(evil)))
(custom-set-faces)
