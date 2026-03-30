;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "Charles Ellis"
      user-mail-address "hamled@hamled.dev")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
(setq doom-font (font-spec :family "FiraCode Nerd Font Mono" :size 20 :weight 'semi-light)
      doom-variable-pitch-font (font-spec :family "FiraCode Nerd Font" :size 20)
      doom-symbol-font (font-spec :family "Noto Emoji" :weight 'light))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.


(after! lsp-java
  (setq
   ;; Let jdt.ls use a lot of memory
   lsp-java-vmargs
   `(,@lsp-java-vmargs
     "-Xmx5G")

   ;; Use absolute path for workspace dir
   lsp-java-workspace-dir
   (expand-file-name lsp-java-workspace-dir)

   ;; Don't format Java files with LSP
   lsp-java-format-enabled nil

   ;; Allow Gradle wrappers used by specific projects
   lsp-java-imports-gradle-wrapper-checksums
   ;; cmdnctrl/scoreboard/scoreboard-api
   [(:sha256 "e68185c8c0f67873dcd98916621870266a71584dfb0a2861d87d7077ebc39837"
     :allowed t)]))

(add-hook 'java-mode-local-vars-hook #'lsp! 'append)


;; Use prettier to format typescript
(setq-hook! 'typescript-mode-hook
  +format-with-lsp nil)
(setq-hook! 'typescript-tsx-mode-hook
  +format-with-lsp nil)

;; Extra LSP mode file watch ignore patterns
(defvar lsp-file-watch-ignored-directories-global
  '("[/\\\\]\\.devenv\\'")
  "Extra LSP mode file watcher ignored directories to use globally.")
(defvar lsp-file-watch-ignored-directories-local
  nil
  "Extra LSP mode file watcher ignored directories to use locally.")
(put 'lsp-file-watch-ignored-directories-local 'safe-local-variable #'lsp--string-listp)

(after! lsp-mode
  (add-function :around (symbol-function 'lsp-file-watch-ignored-directories)
                (lambda (orig)
                  (append
                   (funcall orig)
                   lsp-file-watch-ignored-directories-global
                   lsp-file-watch-ignored-directories-local))))

(defun projectile-customizable-project-name (root)
  (with-temp-buffer
    (setq default-directory root)
    (hack-dir-local-variables-non-file-buffer)
    (or projectile-project-name
        (projectile-default-project-name root))))

(defun project-type (project)
  "Return the type the given project."
  (car project))

(after! projectile
  (setq projectile-per-project-compilation-buffer t
        projectile-project-name-function #'projectile-customizable-project-name)
  (advice-add 'project-name :around
              (lambda (orig-fun project)
                (cond
                 ((eq 'projectile (project-type project))
                  (funcall projectile-project-name-function
                           (project-root project)))
                 (t (apply orig-fun (list project)))))))

(defun workspaces-project-unique-name-advice (orig-fun project-root)
  (let ((custom-name (funcall projectile-project-name-function
                              project-root)))
    (if-let* ((orig-name (apply orig-fun (list project-root)))
              (parts (split-string orig-name "/" t))
              (path (cdr parts)))
        (string-join (append path (list custom-name)) "/")
      custom-name)))

(after! (projectile persp-mode)
  (advice-add '+workspaces-project-unique-name :around
              #'workspaces-project-unique-name-advice))

(set-formatter! 'alejandra '("alejandra" "--quiet") :modes '(nix-mode nix-ts-mode))

(after! eglot
  (defun eglot-jdtls-project-config-update (server)
    "Send a signal to SERVER to update the Java project configuration.
     When called interactively, use the currently active server"
    (interactive (list (eglot--current-server-or-lose)))
    (jsonrpc-notify
     server :java/projectConfigurationsUpdate
     (list
      :identifiers
      (eglot--TextDocumentIdentifier)))))

(setq treesit-auto-install-grammar 'never)

;; Agent shell
(after! agent-shell
  (setq agent-shell-anthropic-claude-environment
        (agent-shell-make-environment-variables :inherit-env t)))


;;; config.el ends here
