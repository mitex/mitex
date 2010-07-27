;;
;; hyperlatex.el
;;
(defvar hyperlatex-rcs-string 
  "$Id: hyperlatex.el,v 1.20 2006/11/20 02:31:51 tomfool Exp $") 
;; 
;; A common input format for LaTeX and Html documents
;; This file realizes the translation to Html format.
;;
;; This file is part of Hyperlatex
;; Copyright (C) 1994-2000 Otfried Cheong	
;;  
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2 of the License, or (at
;; your option) any later version.
;;      
;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.
;;     
;; A copy of the GNU General Public License is available on the World
;; Wide web at "http://www.gnu.org/copyleft/gpl.html".
;; You can also obtain it by writing to the Free Software Foundation,
;; Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
;;
;; -------------------------------------------------------------------
;;
;; To run conversion from within Emacs, put the following lines in your
;; `.emacs' file:
;;
;;   (setq hyperlatex-extension-dirs
;;      '("~/.hyperlatex/" "HYPERLATEX_DIR/"))
;;   (autoload 'hyperlatex-format-buffer "HYPERLATEX_DIR/hyperlatex" nil t)
;;   (global-set-key "\C-ch" 'hyperlatex-format-buffer)
;;
;; where you replace HYPERLATEX_DIR by the directory containing the
;; *.hlx and *.el files for Hyperlatex
;;
;; Then you can call `hyperlatex-format-buffer' in the buffer
;; containing the LaTeX input file by typing `C-c h'.
;; (You might want to set it up such that a key is only defined in
;;  the Latex mode that you are using.)
;;
;;------------------------------------------------------------------------

;; set to true to see all macro expansions
(setq hyperlatex-show-expansions nil)

(defvar hyperlatex-version "2.9-in-waiting-rk (oct06)")

(defvar hyperlatex-rcs-version (substring hyperlatex-rcs-string 21 25))
(defvar hyperlatex-rcs-date (substring hyperlatex-rcs-string 26 36))

;; RK's. Set to true to see debug messages
(defvar hyperlatex-debug-mode nil)

(defun hyperlatex-debug-msg (msg)
  (if hyperlatex-debug-mode (hyperlatex-message msg)))
;; end of RK's

;;------------------------------------------------------------------------

;; Emacs 18 backwards compatibility
(if (fboundp 'buffer-disable-undo)
    ()
  (fset 'buffer-disable-undo 'buffer-flush-undo))

;; non-complete definition
;; in Emacs 18 HYPERLATEX_DIR can only contain one directory
(if (fboundp 'parse-colon-path)
    ()
  (defun parse-colon-path (arg)
    (list (concat arg "/"))))
     
(if (fboundp 'string-to-number)
    ()
  (fset 'string-to-number 'string-to-int)
  (fset 'number-to-string 'int-to-string))

(if (fboundp 'find-file-literally)
    ()
  (fset 'find-file-literally 'find-file)) 

(if (fboundp 'insert-file-contents-literally)
    ()
  (fset 'insert-file-contents-literally 'insert-file-contents))

(if (fboundp 'add-to-list)
    ()
  (defun add-to-list (list-var element)
    (or (member element (symbol-value list-var))
	(set list-var (cons element (symbol-value list-var))))))

;; for Emacs 18 and 19
(defvar enable-multibyte-characters)

(if (fboundp 'set-buffer-multibyte)
    ()
  (defun set-buffer-multibyte (arg)
    (setq enable-multibyte-characters arg)))

(defvar hyperlatex-active-space nil 
"A boolean flag to indicate whether a space has meaning (like in a
<pre> tag)")
(defvar hyperlatex-attributes nil "A list of attributes to apply to HTML/XML tags")
(defvar hyperlatex-basename nil "The base name to use in naming HTML files.")
(defvar hyperlatex-bibitem-number nil "The number of a bibliography item.")
(defvar hyperlatex-cite-names nil "An alist containing labels and
mnemonics of bibliography items.")
(defvar hyperlatex-command-name nil 
"The symbol representing the LaTeX macro (command) to be expanded
(executed).  The name of the symbol is the macro name, and the
hyperlatex property is the name of the function that will execute
it.");;"
(defvar hyperlatex-command-start nil 
"The buffer position of the start of the command currently being
digested.")
(defvar hyperlatex-continue-scan nil "Used to control the depth of the recursion.")
(defvar hyperlatex-counters nil "An alist containing the names of counters and their current values.")
(defvar hyperlatex-current-filename nil "The name of the file currently being built.")
(defvar hyperlatex-current-ref "" "A string containing the number of the counter relevant to the most recent reference.")
(defvar hyperlatex-document-options nil "The list of document options (from the \\documentclass command).")
(defvar hyperlatex-example-depth nil "Used to limit recursion in 'example' environments.")
(defvar hyperlatex-final-pass nil "A boolean value indicating whether this is the last pass through the document or not.")
(defvar hyperlatex-footnote-number nil "The number of the most recently formatted footnote.")
(defvar hyperlatex-footnotes nil "A stack of the footnotes to be set.")
(defvar hyperlatex-group-stack nil "A stack of commands to executed at the close of the current group.  The commands are inserted with the \\aftergroup command.")
(defvar hyperlatex-html-accents nil "")
(defvar hyperlatex-html-directory nil "")
(defvar hyperlatex-imagetype "png" "Use this variable to select gif or png images.")
(defvar hyperlatex-in-paragraph nil "Boolean value to identify whether we're somewhere that needs to be ended with a </p>.")
(defvar hyperlatex-in-body nil "Boolean value to identify whether we're actually in the body of an html page (as opposed to the header).  This variable is also used to signal that <p> tags are not currently appropriate, as in headings and lists and so on.")
(defvar hyperlatex-index nil "")
(defvar hyperlatex-input-buffer nil "")
(defvar hyperlatex-input-directory nil "")
(defvar hyperlatex-is-article nil "")
(defvar hyperlatex-known-packages nil "")
(defvar hyperlatex-label-number nil "")
(defvar hyperlatex-label-strings nil "")
(defvar hyperlatex-labels nil "")
(defvar hyperlatex-made-panel nil "")
(defvar hyperlatex-make-panel nil "")
(defvar hyperlatex-making-frames nil "")
(defvar hyperlatex-math-italic nil "")
(defvar hyperlatex-math-mode nil "")
(defvar hyperlatex-menu-in-section nil "")
(defvar hyperlatex-message-buffer nil "")
(defvar hyperlatex-message-window nil "")
(defvar hyperlatex-new-commands nil "")
(defvar hyperlatex-node-names nil "")
(defvar hyperlatex-node-number nil "")
(defvar hyperlatex-node-section nil "")
(defvar hyperlatex-options nil "")
(defvar hyperlatex-packages nil "")
(defvar hyperlatex-produced-from nil "Information for header of output files.")
(defvar hyperlatex-produced-from-file nil "File name to go in header of output files.")
(defvar hyperlatex-recursion-depth nil "")
(defvar hyperlatex-rev-sections nil "")
(defvar hyperlatex-sect-number nil "")
(defvar hyperlatex-sections nil "")
(defvar hyperlatex-special-chars-regexp nil "")
(defvar hyperlatex-stack nil "A stack of the nested environments and groups at the current point.")
(defvar hyperlatex-tabular-column-descr nil "")
(defvar hyperlatex-tabular-column-types nil "")
(defvar hyperlatex-title nil "")
(defvar hyperlatex-topnode-name nil "")
(defvar hyperlatex-warning-count 0 "")
(defvar hyperlatex-xml nil "")

(defvar hyperlatex-format-syntax-table nil)

;; File extension for HTML files.
;; Change this to .htm for braindamaged systems
(defvar hyperlatex-html-ext ".html")


;; RK's
;; === Vertical and horizontal mode, paragraph mode.
;;

(defvar hyperlatex-in-b nil "RK's replacement for hyperlatex-in-body")

(defvar hyperlatex-in-tag nil "Watched by hyperlatex-enter-par to prevent it from generating <p> when we are inside another tag.")

(defconst hyperlatex-h-mode 1) ;; horizontal (and also mathematical)
(defconst hyperlatex-v-mode 2) ;; vertical
(defconst hyperlatex-p-mode 3) ;; parapraph

(defconst hyperlatex-undefined-tag-point -1)

(defvar hyperlatex-mode-stack nil
"A stack of mode and paragraph states at the entered recursion levels.
An element of the stack should be a dot pair (m . p) of integers 
where m denotes a mode and p is a buffer point")

(defun hyperlatex-push-mode-stack (state)
;; Extend hyperlatex-mode-stack by consing a given state to it.
  (setq hyperlatex-mode-stack (cons state hyperlatex-mode-stack)))

(defun hyperlatex-pop-mode-stack ()
;; Remove the first element from hyperlatex-mode-stack (error when empty).
  (if (null hyperlatex-mode-stack)
    (progn
      (hyperlatex-debug-msg (if hyperlatex-in-b "In body." "Not in body."))
      (error "Removing an element from empty hyperlatex-mode-stack."))
   (setq hyperlatex-mode-stack (cdr hyperlatex-mode-stack))
   (if (not (null hyperlatex-mode-stack))
     (hyperlatex-set-point (point)))))

(defun hyperlatex-get-state ()
;; Return the top-most element, nil if the stack is empty."
  (if (null hyperlatex-mode-stack) nil
     (car hyperlatex-mode-stack)))

(defun hyperlatex-get-mode ()
;; Return the top-most element, nil if the stack is empty."
  (if (null hyperlatex-mode-stack) nil 
    (caar hyperlatex-mode-stack)))

(defun hyperlatex-get-tag-point ()
;; Return the point of the top-most element, 
;; hyperlatex-undefined-tag-point when the stack is empty."
  (if (null hyperlatex-mode-stack) hyperlatex-undefined-tag-point 
    (cdar hyperlatex-mode-stack)))

(defun hyperlatex-set-state (state)
;; Replace stack's top-most state (mode . point) with a given one.
  (if (null hyperlatex-mode-stack)
    (progn
      (hyperlatex-debug-msg (if hyperlatex-in-b "In body." "Not in body."))
      (error "Empty hyperlatex-mode-stack in hyperlatex-set-state."))
    (setq hyperlatex-mode-stack (cons state (cdr hyperlatex-mode-stack)))))

(defun hyperlatex-set-point (pnt)
;; Change the second component of current state to pnt.
  (let ((state (hyperlatex-get-state)))
    (if (null state) nil
      (hyperlatex-set-state (cons (car state) pnt)))))

(defun hyperlatex-in-v-mode-p ()
;; Inspect hyperlatex-mode-stack on whether we are in vertical mode.
  (equal (hyperlatex-get-mode) hyperlatex-v-mode))

(defun hyperlatex-in-h-mode-p ()
;; Inspect hyperlatex-mode-stack on whether we are in horizontal mode.
  (equal (hyperlatex-get-mode) hyperlatex-h-mode))

(defun hyperlatex-in-par-p ()
;; Inspect hyperlatex-mode-stack on whether a paragraph is running.
  (equal (hyperlatex-get-mode) hyperlatex-p-mode))

(defun hyperlatex-enter-v-mode ()
;; If not yet in v-mode then close h-mode (if in one) and set v-mode.
  (if (not hyperlatex-in-b) nil
    (if (hyperlatex-in-v-mode-p) nil
      (hyperlatex-leave-h-mode)
      (hyperlatex-set-state (cons hyperlatex-v-mode (point))))))

(defun hyperlatex-enter-h-mode ()
;; If not yet in horizontal mode enter one at the current level.
  (if (not hyperlatex-in-b) nil
    (if (hyperlatex-in-h-mode-p) nil
      (hyperlatex-set-state (cons hyperlatex-h-mode (point))))))

(defun hyperlatex-leave-h-mode ()
;; If in h-mode leave it by leaving and then by changing mode.
  (if (not hyperlatex-in-b) nil
    (if (not (hyperlatex-in-h-mode-p)) nil   
      (hyperlatex-leave-par))))

(defun hyperlatex-enter-par ()
;; RK's
;; If not yet in par and not h-mode, open a new par and go p-mode.
  (if (not hyperlatex-in-b) nil ;; don't generate a <p> when in preamble
  (if hyperlatex-in-tag nil ;; don't generate a <p> when inside a tag
  (if (hyperlatex-in-par-p) nil ;; already in p-mode
  (if (hyperlatex-in-h-mode-p) nil  ;; don't generate a <p> when in h-mode
  (hyperlatex-debug-msg
    (concat (char-to-string (following-char))
               " stack's length before <p>="
             (number-to-string (length hyperlatex-mode-stack))
               " tag-point=" 
             (number-to-string (hyperlatex-get-tag-point))
               " current point="
             (number-to-string (point))))

;; The place where <p> tag should be placed in the output is not 
;; necessarily (point). The tag should go to the point stored at 
;; the current level of mode stack. We are nice and skip whitespace
;; characters after the point stored at the stack before outputing <p>.
        (let ((tag-point (hyperlatex-get-tag-point))
              (current-point (point)))
          (if (= tag-point hyperlatex-undefined-tag-point) 
            ;; tag-point is undefined, so put <p> at (point) 
            (hyperlatex-gen (hyperlatex-get-attributes "p"))
            ;; otherwise  put <p> at tag-point
            (goto-char tag-point)           
            (hyperlatex-gen (hyperlatex-get-attributes "p"))
            (goto-char (+ (- (point) tag-point) current-point)))
          ;; Keep in the stack that we are in p-mode and that 
          ;; the just changed (point) is a candidate for next <p>.
          ;; This candidate will probably be shadowed by the nearest
          ;; </p> at the same mode level
          (hyperlatex-set-state (cons hyperlatex-p-mode (point)))))))))

(defun hyperlatex-leave-par ()
;; Leave the current paragraph (if in any) and go into vertical mode.
  (if (not hyperlatex-in-b) nil
    (if (hyperlatex-in-par-p) (hyperlatex-gen "/p" "\n"))
    (if (hyperlatex-get-state) ; if state is defined the stack is non-empty
      (hyperlatex-set-state (cons hyperlatex-v-mode (point))))))

(defun hyperlatex-first-par ()
;; Enters either v-mode or non-paragraph h-mode.
;; To be used when an item or cell is entered.
;; Non-paragraph h-mode is entered when 
;; hyperlatex-gen-first-par-p = nil.
  (if (not hyperlatex-in-b) nil
    (if hyperlatex-gen-first-par-p
       (hyperlatex-enter-v-mode)
       (hyperlatex-enter-h-mode))))

(defun hyperlatex-mode-level-up (&optional debug-info)
;; Push (h-mode, hyperlatex-undefined-tag-point) to the mode stack.
  (if (not hyperlatex-in-b) nil
    ;; before entering a higher level mark tag-point as undefined
    ;; when back to this level <p> will have to be placed at (point)
    (hyperlatex-set-point hyperlatex-undefined-tag-point)
    (hyperlatex-push-mode-stack 
      (cons hyperlatex-h-mode hyperlatex-undefined-tag-point))
    (hyperlatex-debug-msg 
      (concat "Up to level " (number-to-string (length hyperlatex-mode-stack))
              "  at " (if (null debug-info) "UNSPECIFIED" debug-info)
              "  point " (number-to-string (point)) ))))

(defun hyperlatex-mode-level-down (&optional debug-info)
  (if (not hyperlatex-in-b) nil
    (hyperlatex-leave-par)
    (hyperlatex-pop-mode-stack)
    (hyperlatex-set-point hyperlatex-undefined-tag-point)
    (hyperlatex-debug-msg 
      (concat "Down to level " (number-to-string (length hyperlatex-mode-stack))
              "  at " (if (null debug-info) "UNSPECIFIED" debug-info)
              "  point " (number-to-string (point))))))

(put 'HlxEnterVmode    'hyperlatex 'hyperlatex-enter-v-mode)
(put 'HlxEnterHmode    'hyperlatex 'hyperlatex-enter-h-mode)
(put 'HlxEnterPar      'hyperlatex 'hyperlatex-enter-par)
(put 'HlxLeavePar      'hyperlatex 'hyperlatex-leave-par)
(put 'HlxFirstPar      'hyperlatex 'hyperlatex-first-par)
(put 'HlxModeLevelUp   'hyperlatex 'hyperlatex-mode-level-up)
(put 'HlxModeLevelDown 'hyperlatex 'hyperlatex-mode-level-down)

(defvar hyperlatex-gen-first-par-p nil
"Should the first paragraph within an item-cell generate a <p>...</p>?")

(defun hyperlatex-debug-show-p-positions ()
  (if hyperlatex-debug-mode
    (save-excursion
      (goto-char (point-min))
      (while (search-forward "<p>" nil t)
        (hyperlatex-debug-msg (concat "<p> found at " 
                             (number-to-string (point))))))))

;; === End of variables and procedures related to hyperlatex-mode-stack

(defun hyperlatex-html-ext ()
  (if hyperlatex-xml ".xml" hyperlatex-html-ext))

(defvar hyperlatex-extension-dirs
  (cons "~/.hyperlatex/" 
	(cons "./" (parse-colon-path (getenv "HYPERLATEX_DIR")))))

;; Notes about the magic characters.  These are known as
;; hyperlatex-meta-whatever, and are set just below here.

;; meta-C is used to escape the magic characters, if they appear in the 
;; input file.

;; Most magic characters (especially meta-&, meta-<, and meta->, but also 
;; meta-{, meta-}, meta-", meta-' etc.) are used to protect characters from 
;;   final substitution.  After Hyperlatex conversion, all &, <, and > 
;; characters in the file are converted to XML symbols (i.e. &amp; &lt; and 
;; &gt;), while the meta-&, meta-< and meta-> are converted to the normal 
;; &, <, > characters.

;; meta-| is used in parsing arguments to macros to delimit arguments 
;; from following text.

;; meta-l is used to mark the spot after something that has been labeled. 
;; For instance, saying

;; \section{abc}

;; will generate an automatic label, a <h> tag, and then a meta-l marker. 
;; If now a \label command follows, Hyperlatex checks the presence of 
;; meta-l to make sure that the label _before_ the section heading is used.

;; meta-X is used to mark locations where Hyperlatex didn't yet know what 
;; text to mark as the anchor of a label (i.e. the contents of an <a 
;; name="xxx">xxx</a> tag).  This is then done in the final substitution 
;; stage.

;; meta-p is used to mark paragraph breaks, and meta-n is used to mark 
;; places where NO paragraph break should occur.
;; meta-P is for marking paragraph endings, and meta-p is for beginnings.
;;
(setq hyperlatex-meta-offset 128)

(defun hyperlatex-meta (ch)
  (char-to-string (+ ch hyperlatex-meta-offset)))

(setq hyperlatex-meta-n (hyperlatex-meta ?n))
(setq hyperlatex-metachar-n (+ ?n hyperlatex-meta-offset))
(setq hyperlatex-meta-p (hyperlatex-meta ?p))
(setq hyperlatex-meta-P (hyperlatex-meta ?P))
(setq hyperlatex-metachar-p (+ ?p hyperlatex-meta-offset))
;; RK's -- just for symmetry
(setq hyperlatex-metachar-P (+ ?P hyperlatex-meta-offset))
;;
(setq hyperlatex-meta-l (hyperlatex-meta ?l))
(setq hyperlatex-metachar-l (+ ?l hyperlatex-meta-offset))
(setq hyperlatex-meta-X (hyperlatex-meta ?X))
(setq hyperlatex-meta-C (hyperlatex-meta ?C))
(setq hyperlatex-meta-< (hyperlatex-meta ?<))
(setq hyperlatex-meta-> (hyperlatex-meta ?>))
(setq hyperlatex-meta-{ (hyperlatex-meta ?{))
(setq hyperlatex-meta-} (hyperlatex-meta ?}))
(setq hyperlatex-meta-& (hyperlatex-meta ?&))
(setq hyperlatex-meta-| (hyperlatex-meta ?|))
(setq hyperlatex-meta-dq (hyperlatex-meta ?\"))

(setq hyperlatex-a-name-format
      (concat "a name=" hyperlatex-meta-dq "%s" hyperlatex-meta-dq))
(setq hyperlatex-a-href-format
      (concat "%s href=" hyperlatex-meta-dq "%s" hyperlatex-meta-dq))

;; all characters that need to be protected before working on the file
(setq hyperlatex-meta-protect
      (concat "["
	      hyperlatex-meta-n
	      hyperlatex-meta-l
	      hyperlatex-meta-p
	      hyperlatex-meta-P
	      hyperlatex-meta-|
	      hyperlatex-meta-X
	      hyperlatex-meta-C
	      hyperlatex-meta-&
	      hyperlatex-meta-<
	      hyperlatex-meta->
	      (hyperlatex-meta ?%)
	      hyperlatex-meta-{
	      hyperlatex-meta-}
	      hyperlatex-meta-dq
	      (hyperlatex-meta ?\\)
	      (hyperlatex-meta ?~)
	      (hyperlatex-meta 32)
	      (hyperlatex-meta ?-)
	      (hyperlatex-meta ?')
	      (hyperlatex-meta ?`)
	      "]"))

;; meta characters that are later converted to their normal value
(setq hyperlatex-meta-all
      (concat "["
	      hyperlatex-meta-&
	      hyperlatex-meta-<
	      hyperlatex-meta->
	      (hyperlatex-meta ?%)
	      hyperlatex-meta-{
	      hyperlatex-meta-}
	      hyperlatex-meta-dq
	      (hyperlatex-meta ?\\)
	      (hyperlatex-meta ?~)
	      (hyperlatex-meta 32)
	      (hyperlatex-meta ?-)
	      (hyperlatex-meta ?')
	      (hyperlatex-meta ?`)
	      "]"))

;(defvar hyperlatex-special-chars-basic-regexp
;  (concat "\\\\%{}]\\|\n[ ]*\r?\n\\|---?\\|``\\|''\\|\\?`\\|!`\\|"
;	  hyperlatex-meta-|))
(defvar hyperlatex-special-chars-basic-regexp
  (concat "\\\\%{}]\\|---?\\|``\\|''\\|\\?`\\|!`\\|"
	  hyperlatex-meta-|))

(defvar hyperlatex-purify-regexp
  (concat hyperlatex-meta-< "[^" hyperlatex-meta-> "]+" 
	  hyperlatex-meta->))

(defvar hyperlatex-special-characters "~$^_&"
  "Special characters in standard Latex.")

(defvar hyperlatex-additional-special-characters ""
  "Characters made special.")

;; RK's change:
(defvar hyperlatex-xml-charset "UTF-8"
  "The name of character encoding for an entire XML document") 

;;;
;;; The syntax table is only used to read arguments
;;;  (it is responsible for balancing the { } brackets)
;;; Comments do not work correctly in arguments
;;;
(progn
  (setq hyperlatex-format-syntax-table (copy-syntax-table))

  ;; \ escapes a bracket
  (modify-syntax-entry ?\\ "\\" hyperlatex-format-syntax-table)

  ;; the only brackets are { and }
  (modify-syntax-entry ?{ "(}" hyperlatex-format-syntax-table)
  (modify-syntax-entry ?} "){" hyperlatex-format-syntax-table)

  ;; disallow brackets [ ] and ( )
  (modify-syntax-entry ?\[ "_" hyperlatex-format-syntax-table)
  (modify-syntax-entry ?\] "_" hyperlatex-format-syntax-table)
  (modify-syntax-entry ?\( "_" hyperlatex-format-syntax-table)
  (modify-syntax-entry ?\) "_" hyperlatex-format-syntax-table)

  ;; there are no "string literals"
  (modify-syntax-entry ?\" "." hyperlatex-format-syntax-table)
  (modify-syntax-entry ?\' "." hyperlatex-format-syntax-table)
)

(defun batch-hyperlatex-format ()
  "Runs  hyperlatex-format-buffer  on the files remaining on the command line.
Must be used only with -batch, and kills emacs on completion.
Each file will be processed even if an error occurred previously."
  (if (not noninteractive)
      (error "batch-hyperlatex-format may only be used -batch."))
  (if (null command-line-args-left)
      (error "No file specified."))
  (let ((auto-save-default nil)
	(find-file-run-dired nil)
	(error 0)
	(file (expand-file-name (car command-line-args-left))))
    (if (not (file-exists-p file))
	(error ">> %s does not exist!" file))
    (find-file-literally file)
    (buffer-disable-undo (current-buffer))
    (message "Hyperlatex formatting %s..." file)
    (message "  (on Emacs %s)" emacs-version)
    (kill-emacs (hyperlatex-format-buffer-0))))
      
(defun hyperlatex-format-buffer ()
  "Process the current buffer as hyperlatex code, into a Html document.
The Html file output is generated in a directory specified in the
 \\htmldirectory command, or in the current directory."
  (interactive)
  (setq hyperlatex-message-buffer
	(get-buffer-create "*Hyperlatex messages*"))
  (save-excursion
    (set-buffer hyperlatex-message-buffer)
    (buffer-disable-undo hyperlatex-message-buffer)
    (delete-region (point-min) (point-max)))
  (setq hyperlatex-message-window (display-buffer hyperlatex-message-buffer))
  (if (zerop (hyperlatex-format-buffer-0))
      (hyperlatex-warning-summary)
    (error "Hyperlatex formatting error.")))

(defun hyperlatex-format-buffer-0 ()
  "Process the current buffer as hyperlatex code.
Send messages to standard-output.
Returns 0 if no error, 1 otherwise."
  (condition-case err
      (progn 
	(hyperlatex-format-buffer-1)
	(hyperlatex-warning-summary)
	0)
    (error
     (setq standard-output
	   (if noninteractive
	       t
	     hyperlatex-message-buffer))
     (princ "\nHyperlatex ERROR: ")
     (if (eq (car err) 'error)
	 (princ (eval (cons 'format (cdr err))))
       (prin1 err))
     (princ "\nHint: Try running Latex, it may give a better error message.\n")
     (princ "\nError discovered here: \n>>>")
     (princ (buffer-substring (point)
			      (min (+ (point) 2000)
				   (point-max))))
     (princ " ...\n")
     (hyperlatex-message "\n")
     1)))

(defun hyperlatex-message (form &optional arg1 arg2 arg3)
  (if noninteractive
      (message form arg1 arg2 arg3)
    (setq standard-output hyperlatex-message-buffer)
    (princ (format form arg1 arg2 arg3))
    (princ "\n")
    (set-window-point hyperlatex-message-window
		      (save-excursion
			(set-buffer hyperlatex-message-buffer)
			(point)))
    (sit-for 0)))

(defun hyperlatex-warning (form &optional arg1 arg2 arg3)
  (setq hyperlatex-warning-count (1+ hyperlatex-warning-count))
  (hyperlatex-message form arg1 arg2 arg3))

(defun hyperlatex-warning-summary ()
  (message (if (zerop hyperlatex-warning-count)
	       "Hyperlatex formatting done."
	     (format "Hyperlatex formatting done: there were %d warnings."
		     hyperlatex-warning-count))))

(defun hyperlatex-write-region (from to name)
  (let ((coding-system-for-write 'no-conversion))
    (write-region from to name)))

(defun hyperlatex-format-buffer-1 ()
  (let* (hyperlatex-html-directory	 ;; where to put HTML files
	 hyperlatex-produced-from	 ;; for header in HTML files
	 hyperlatex-title                ;; <TITLE> title </TITLE>
	 
	 hyperlatex-xml

	 (hyperlatex-known-packages 
	  '(hyperlatex a4 xspace verbatim))
	 
	 (hyperlatex-index nil)
	 (hyperlatex-labels nil)
	 (hyperlatex-label-strings nil)
	 (hyperlatex-sections nil)
	 (hyperlatex-node-names nil)
	 (hyperlatex-cite-names nil)
	 
	 (hyperlatex-produced-from-file
	  (if (buffer-file-name)
	      (file-name-sans-versions
	       (file-name-nondirectory (buffer-file-name)))
	    ()))
	 (hyperlatex-produced-from
	  (if hyperlatex-produced-from-file
	      (concat "file: " hyperlatex-produced-from-file)
	    (concat "buffer " (buffer-name))))
	 (hyperlatex-basename
	  (progn
	    (string-match "\\.\\(tex\\|hlx\\)$" hyperlatex-produced-from-file)
	    (substring hyperlatex-produced-from-file 0 (match-beginning 0))))
	 ;; to set levels of headings correctly:
	 hyperlatex-rev-sections
	 ;; the depth of automatic menus, 0 for none
	 (hyperlatex-input-buffer (current-buffer))
	 (hyperlatex-input-directory default-directory))
    ;;----------------------------------------------------------
    (set-buffer (get-buffer-create " *Hyperlatex Html output*"))
    (set-buffer-multibyte nil)
    (fundamental-mode)
    (set-syntax-table hyperlatex-format-syntax-table)
    (setq case-fold-search nil)
    ;; run first pass
    (hyperlatex-message "Running Hyperlatex %s (%s -- %s)" 
			hyperlatex-version hyperlatex-rcs-version
			hyperlatex-rcs-date)
    (hyperlatex-message "Parsing ... ")
    (hyperlatex-format-buffer-2 nil)
    ;; generate link and node tables
    (setq hyperlatex-rev-sections (reverse hyperlatex-sections))
    ;; run second pass
    (hyperlatex-message "Formatting ... ")
    (hyperlatex-format-buffer-2 t)))

(defun hyperlatex-format-buffer-2 (hyperlatex-final-pass)
  "Run one pass on the buffer. HYPERLATEX-FINAL-PASS is true in the 
second pass."
  (let (hyperlatex-menu-in-section ;; did we create a menu in this section?
	hyperlatex-command-start
	hyperlatex-command-name
	hyperlatex-stack
	hyperlatex-group-stack
	(hyperlatex-math-italic nil)
	(hyperlatex-active-space nil)
	(hyperlatex-current-ref "")
	(hyperlatex-tabular-column-descr nil)
	(hyperlatex-tabular-column-types nil)
	(hyperlatex-html-accents nil)
	(hyperlatex-attributes nil)
	(hyperlatex-new-commands nil)
	(hyperlatex-make-panel t)
	(hyperlatex-made-panel nil)
	(hyperlatex-math-mode nil)
	(hyperlatex-document-options nil)
	(hyperlatex-options nil)
	(hyperlatex-footnotes nil)
	(hyperlatex-counters nil)
	(hyperlatex-footnote-number 0)
	(hyperlatex-node-number 0)
	(hyperlatex-sect-number 0)
	(hyperlatex-node-section 0)
	(hyperlatex-recursion-depth 0)
	hyperlatex-continue-scan
	(hyperlatex-label-number 0)
	(hyperlatex-bibitem-number 0))
    (erase-buffer)
    (setq hyperlatex-warning-count 0)
    (insert-buffer-substring hyperlatex-input-buffer)
    (hyperlatex-update-special-chars)
    (hyperlatex-prelim-substitutions (point-min) (point-max))
    ;; insert linefeed at end of file
    (goto-char (point-max))
    (insert "\n")
    ;; Scan the buffer
    (hyperlatex-format-region (point-min) (point-max))))

;;;
;;; ----------------------------------------------------------------------
;;;

(defun hyperlatex-update-special-chars ()
    ;; compute hyperlatex-special-chars-regexp
    (setq  hyperlatex-special-chars-regexp
	   (concat "["
		   hyperlatex-special-characters
		   hyperlatex-additional-special-characters
		   hyperlatex-special-chars-basic-regexp)))
  
(defun hyperlatex-prelim-substitutions (start end)
  "Protects characters that are needed for wizardry."
  (let ((meta-iso-format (concat
			  hyperlatex-meta-C
			  hyperlatex-meta-{
			  "%d"
			  hyperlatex-meta-})))
    (goto-char start)
    (while (search-forward "\r" end t)
      (replace-match ""))
    (goto-char start)
    (while (re-search-forward hyperlatex-meta-protect end t)
      (replace-match (format meta-iso-format (preceding-char)) t))
;    (let ((bigstring (buffer-string)))
;      (if hyperlatex-final-pass
;	  (hyperlatex-message "FINAL:%s" bigstring)
;      (hyperlatex-message "FIRST:%s" bigstring)))
    ))

(defun hyperlatex-final-substitutions ()
  "Scan buffer and replace the characters special for Html.
Replace PAR (meta-p) entries by \\html{P}, unless there is a magic NOPAR (meta-n)
next to it. Finally, remove or convert all magic entries."
  ;; replace PAR entries by <P>, if okay
  (let ((meta-l-p (concat " \n" hyperlatex-meta-l hyperlatex-meta-p))
	(meta-n-p-l (concat "[" hyperlatex-meta-n hyperlatex-meta-l
			    hyperlatex-meta-p "]"))
	(meta-amp (concat hyperlatex-meta-& "amp;"))
	(meta-gt (concat hyperlatex-meta-&  "gt;"))
	(meta-lt (concat hyperlatex-meta-&  "lt;"))
	(meta-iso-regexp (concat hyperlatex-meta-C "{\\([0-9]+\\)}")))
    (goto-char (point-min))
    (while (search-forward hyperlatex-meta-p nil t)
      (replace-match "")
      ;; Duplicate paragraph marks or CRs can be deleted here.
      (while (or (= (following-char) ?\n)
		 (= (following-char) hyperlatex-metachar-p)
		 (= (following-char) hyperlatex-metachar-P)) ;check for empty <p></p>
	(delete-char 1))
      (or (progn
	    (goto-char (match-beginning 0))
	    (skip-chars-backward meta-l-p )
	    (equal (preceding-char) hyperlatex-metachar-n))
	  (progn
	    (goto-char (match-beginning 0))
	    (skip-chars-forward meta-l-p)
	    (equal (following-char) hyperlatex-metachar-n))
	  (progn
	    (goto-char (match-beginning 0))
	    (hyperlatex-blk)
	    (hyperlatex-gen (hyperlatex-get-attributes "p")))))
    (goto-char (point-min))
    (while (search-forward hyperlatex-meta-P nil t)
      (replace-match "")
      (hyperlatex-gen "/p"))   
    ;; remove magic NOPAR, LABEL
    (goto-char (point-min))
    (while (re-search-forward meta-n-p-l nil t)
      (replace-match ""))
    ;; fixup &, <, >
    (goto-char (point-min))
    (while (search-forward "&" nil t)
      (replace-match meta-amp t))
    (goto-char (point-min))
    (while (search-forward ">" nil t)
      (replace-match meta-gt t))
    (goto-char (point-min))
    (while (search-forward "<" nil t)
      (replace-match meta-lt t))
    ;; finally, convert the magic chars to their real counterpart
    (goto-char (point-min))
    (while (re-search-forward hyperlatex-meta-all nil t)
      (replace-match
       (char-to-string (- (preceding-char) hyperlatex-meta-offset)) t))
    ;; make labels
    (goto-char (point-min))
    (while (search-forward hyperlatex-meta-X nil t)
      (replace-match "")
      (if (looking-at "[ \t\n]*[^<> \t\n]+\\([ \t\n]\\)")
	  (goto-char (match-beginning 1)))
;;	(insert "&nbsp;"))  commented out 3/11/05 ts.
      (insert "</a>"))
    ;; put back protected characters
    (goto-char (point-min))
    (while (re-search-forward meta-iso-regexp nil t)
      (replace-match (char-to-string
		      (string-to-number
		       (buffer-substring (match-beginning 1)
					 (match-end 1)))) t))))

;;;
;;; ----------------------------------------------------------------------
;;;
;;; These functions generate protected Html
;;;

(put 'HlxBlk	'hyperlatex 'hyperlatex-blk)

(defun hyperlatex-blk ()
  "This command should be used before a HTML tag that starts a new 
block.  It leaves a magic marker that stops empty lines at this place
from creating <P> tags."
;; RK's
;;  (hyperlatex-leave-par)
;; end of RK's
  (insert hyperlatex-meta-n))
  
(defun hyperlatex-gen (str &optional after)
  "Inserts Html tag STR. Optional argument AFTER is inserted after the tag."
  (let ((afterstr (if after after "")))
    (insert hyperlatex-meta-< str hyperlatex-meta-> afterstr)))

(defun hyperlatex-gensym (str)
  "Inserts Html command to generate special characters. Use
`(hyperlatex-gensym \"amp\")' to generate `&amp;'."
  (insert hyperlatex-meta-& str ";"))

(defun hyperlatex-purify (str)
  "Remove html tags from a string, and also remove any meta characters."
  (while (string-match hyperlatex-purify-regexp str)
    (setq str (replace-match "" t t str)))
  (while (string-match (concat hyperlatex-meta-& "[a-z#0-9]+;") str)
    (setq str (replace-match " " t t str)))
  (while (string-match hyperlatex-meta-protect str)
    (setq str (replace-match "" t t str)))
  str)

;;;
;;; ----------------------------------------------------------------------
;;;
;;; Parsing Hyperlatex
;;;

(defun hyperlatex-format-region (begin end &optional save-white-space)
  "This function formats the region from BEGIN to END into Html.
It is reentrant, so environments can call it recursively."
  (save-restriction
    (narrow-to-region (point-min) end)
    (goto-char begin)
    (let ((hyperlatex-recursion-depth (1+ hyperlatex-recursion-depth))
	  (foochar nil))
      (setq hyperlatex-continue-scan hyperlatex-recursion-depth)
;; Maybe a better approach would be to go character by character and if we're
;; looking at a special character, proceed as shown below.  But if we're 
;; looking at a normal character, make sure that if it begins a paragraph, 
;; that the \par command (or its magic equivalent) is inserted.
      (while (and (= hyperlatex-continue-scan hyperlatex-recursion-depth)
		  (< (point) (point-max)))
	(if (looking-at hyperlatex-special-chars-regexp)
	    (hyperlatex-format-special-char)
	  (if (or save-white-space
		  (looking-at hyperlatex-meta-protect))
;; RK's              
;; Set hyperlatex-in-tag depending on whether the next char is meta-< or meta->.
;; The variable hyperlatex-in-tag is watched by hyperlatex-enter-par
;; in order not to generate <p>-s within other tags.
             (progn
               ;; atomic action of setting hyperlatex-in-tag and moving point forward
               (if (string= (char-to-string (following-char)) hyperlatex-meta-<)
                 (setq hyperlatex-in-tag t))
                (if (string= (char-to-string (following-char)) hyperlatex-meta->)
                  (setq hyperlatex-in-tag nil))
;; end of RK's
	        (forward-char 1)
;; RK's
             )
            (if (looking-at hyperlatex-printable-chars-regexp)
               (progn (hyperlatex-enter-par) (forward-char 1))
;; end of RK's
              (hyperlatex-format-non-special-char)))))
	(if (= hyperlatex-continue-scan hyperlatex-recursion-depth)
	    (setq hyperlatex-continue-scan (1- hyperlatex-recursion-depth)))
      (goto-char (point-max)))))

(defun hyperlatex-format-special-char ()
  "We've seen a special character.  This definition changes, depending
on the environment, what we really mean is that we have seen a match to 
special-chars-regexp, which is likely one character, but may be two or 
three.  This function figures out what it (they) really is (are) -- the 
beginning of a command, or just a quoted character?  If it's a command, 
it's executed here."
  (let ((foochar (preceding-char)))
    (forward-char (- (match-end 0) (point))) ;; Some of the matches are more than
                                             ;; one character, like ?'.
    (setq foochar (preceding-char))
    (delete-region (1- (point)) (point))
    
    (cond
     ((= foochar (+ ?| hyperlatex-meta-offset)))
     ((= foochar ?\n)
      (hyperlatex-empty-line))
     ((/= foochar ?\\ )
      (funcall (get (intern (char-to-string foochar)) 'hyperlatex-active)))
     (t
      ;; \command
      ;; Handle a few special \-followed-by-one-char commands.
      (if (looking-at "[{} \n%_&#$]")
	  ;; These characters are simply quoted
	  (let ((ch (following-char)))
	    (delete-char 1)
	    (hyperlatex-gensym (concat "#" (number-to-string ch))))
	(setq hyperlatex-command-start (point))
	(if (not (looking-at "[a-zA-Z]"))
	    ;; a single letter command
	    (forward-char 1)
	  ;; \ is followed by a word; find the end of the word.
	  (skip-chars-forward "a-zA-Z")
	  ;; and delete white space
	  (hyperlatex-delete-whitespace))
	(setq hyperlatex-command-name
	      (intern (buffer-substring hyperlatex-command-start
					(point))))
	;; remove command
	(delete-region hyperlatex-command-start (point))
	;; Now find the command.  If it's in hyperlatex-command-name, execute
	;; it with funcall.  If not, use hyperlatex-unsupported.
	;; Either way, check if the command left behind printable
	;; characters.  If so, start a new paragraph if we're not
	;; already in one.
	(let ((cmd (get hyperlatex-command-name 'hyperlatex)))
	  (if cmd
	      (progn 
		(funcall cmd)
		(if (hyperlatex-printable-p hyperlatex-command-start (point))
		  (hyperlatex-format-par)))
	    (hyperlatex-unsupported)
	    (let ((command-end (point)))
	      (goto-char hyperlatex-command-start)
	      (if (hyperlatex-printable-p (point) command-end)
		  (hyperlatex-format-par)))) ))))))

(defvar hyperlatex-printable-chars-regexp "[-=+a-zA-Z0-9`'!@#$%^&*():;,.?/]" 
  "This expression should match any character that is to be displayed by the web browser.")

(defun hyperlatex-printable-p (start end)
  "Returns t if any of the characters in the given range are printable 
characters.  Right now, the function ignores everything inside a pair 
of <> brackets.  Eventually, <img> tags should count as printable, but 
they don't yet."
;;;  (hyperlatex-message "printable-p inp:%s, inb:%s, buf:%s" hyperlatex-in-paragraph hyperlatex-in-body (buffer-substring start end))
  (save-excursion
    (let ((printable-answer nil))
      (goto-char start)
      (while (and (not printable-answer) 
		  (< (point) end))
	(cond ((looking-at hyperlatex-printable-chars-regexp)
	       (setq printable-answer t))
	      ((looking-at hyperlatex-meta-<)
	       (search-forward hyperlatex-meta-> end t))
	      (t
	       (forward-char 1))))
      printable-answer)))

(defun hyperlatex-format-non-special-char ()
  "There are things to do even if we're not looking at a special character.
This function looks at our state and decides how to interpret spaces and
blank lines to make paragraphs.  A paragraph marker is triggered by a 
printable character that belongs in one."
  (let ((foochar (following-char))
	(env (symbol-name (car hyperlatex-stack))))
    (if (= (preceding-char) ?\n)
	(cond
;; RK's
;; There is a problem here with comment-lines or, in general,
;; with lines that contain just space characters and comments.
;; end of RK's
	 ((= foochar ?\n)
 	    (delete-char 1)
;; RK's
            (hyperlatex-leave-par))
;; end of RK's
	 ((or (= foochar ?\ ) (= foochar ?\t))
	    (delete-char 1))
;; RK's
  (t
    ()
;;	  (if (or (and hyperlatex-in-paragraph hyperlatex-in-body)
;;		  (not (string= env "document")))
;;	      ()
;;	    (insert hyperlatex-meta-p) 
;;            (setq hyperlatex-in-paragraph t))
;; end of RK's
	  (forward-char 1)))
      (forward-char 1))))

;;;
;;; ----------------------------------------------------------------------
;;;
;;; "Active" characters
;;;

(put '-  'hyperlatex-active 'hyperlatex-format-ignore)
(put '\` 'hyperlatex-active 'hyperlatex-active-backquote)
(put '\' 'hyperlatex-active 'hyperlatex-active-quote)
(put '%  'hyperlatex-active 'hyperlatex-active-percent)
(put '{  'hyperlatex-active 'hyperlatex-begin-group)
(put '}  'hyperlatex-active 'hyperlatex-end-group)
(put '~  'hyperlatex-active 'hyperlatex-active-tilde)
(put '&  'hyperlatex-active 'hyperlatex-format-tab)
(put '$  'hyperlatex-active 'hyperlatex-math-mode)
(put '_  'hyperlatex-active 'hyperlatex-subscript)
(put '^  'hyperlatex-active 'hyperlatex-superscript)

(defun hyperlatex-active-percent ()
  (delete-region (point) (progn (forward-line 1) (point)))
  (hyperlatex-delete-whitespace))

(defun hyperlatex-active-tilde ()
  (hyperlatex-gensym "nbsp"))

(defun hyperlatex-active-quote ()
  (delete-char -1)
  (insert "\""))

(defun hyperlatex-active-backquote ()
  (let ((prechar (preceding-char)))
    (delete-char -1)
    (cond ((= prechar ?`)
	   (insert "\""))
	  ((= prechar ??)
	   (hyperlatex-gensym "#191"))
	  ((= prechar ?!)
	   (hyperlatex-gensym "#161")))))

;;;
;;; ----------------------------------------------------------------------
;;;
;;; Parse arguments to commands
;;;

(put 'ignorespaces	'hyperlatex 'hyperlatex-format-ignorespaces)

(defun hyperlatex-parse-required-argument ()
  "Parses the next argument, deletes, and returns it."
  (goto-char hyperlatex-command-start)
  (hyperlatex-delete-|)
  (hyperlatex-delete-comment)
  (prog1
      (cond
       ;; argument in braces
       ((looking-at "{")
	(forward-sexp 1)
	(buffer-substring (1+ hyperlatex-command-start) (1- (point))))
       ;; single token
       ((looking-at "\\\\")
	(forward-char 1)
	(if (not (looking-at "[a-zA-Z]"))
	    ;; a single letter command
	    (forward-char 1)
	  ;; \ is followed by a word; find the end of the word.
	  (skip-chars-forward "a-zA-Z")
	  ;; and delete white space
	  (hyperlatex-delete-whitespace))
	(buffer-substring hyperlatex-command-start (point)))
       ;; any other character
       (t
	(forward-char 1)
	(buffer-substring hyperlatex-command-start (point))))
    (delete-region hyperlatex-command-start (point))))

(defun hyperlatex-parse-optional-argument ()
  "Parses the argument enclosed in brackets after the commands.
Deletes command and returns argument (nil if none)."
  (goto-char hyperlatex-command-start)
  (hyperlatex-delete-|)
  (hyperlatex-delete-comment)
  (if (= (following-char) ?\[ )
      (progn
	(goto-char (1+ (point)))
	(while (/= (following-char) ?\])
	  (if (= (following-char) ?\{)
	      (forward-sexp 1)
	    (goto-char (1+ (point)))))
	(prog1
	    (buffer-substring (1+ hyperlatex-command-start) (point))
	  (delete-region hyperlatex-command-start (1+ (point)))))))

(defun hyperlatex-parse-optional-arguments ()
  "Parses the arguments enclosed in brackets after the commands.
Returns a list of strings, one for each comma separated option.
Deletes command and returns argument (nil if none)."
  (goto-char hyperlatex-command-start)
  (hyperlatex-delete-|)
  (hyperlatex-delete-comment)
  (if (= (following-char) ?\[ )
      (let ((options nil) (pos (1+ (point))))
	(goto-char (1+ (point)))
	(while (/= (following-char) ?\])
	  (cond
	    ((= (following-char) ?,)
		  (setq options (cons (buffer-substring pos (point)) options))
	      (setq pos (1+ (point))))
	    ((= (following-char) ?\{)
	      (forward-sexp 1))
	  )
	  (goto-char (1+ (point))))
	  (add-to-list 'options (buffer-substring pos (point)))
	  (delete-region hyperlatex-command-start (1+ (point)))
	  (reverse options))))

(defun hyperlatex-starred-p ()
  "Is current command starred? Remove star, and skip whitespace."
  (hyperlatex-delete-|)
  (hyperlatex-delete-whitespace)
  (cond ((= (following-char) ?*)
	 (delete-char 1)
	 (hyperlatex-delete-whitespace)
	 t)))

(defvar hyperlatex-beginning-new-line nil)

(defun hyperlatex-delete-whitespace (&optional at-begin-line)
  (setq hyperlatex-beginning-new-line at-begin-line)
  (if hyperlatex-active-space
      ;; if space is active, we should not skip it
      ()
    (let ((beg (point)))
      (skip-chars-forward " \t")
      (delete-region beg (point))
      (if (looking-at "\n")
	  ;; if in mode N (TeXBook Chapter 8), make <P>  (not any more)
	  (cond (hyperlatex-beginning-new-line
		 (goto-char beg))
		;; else eat it and continue
		(t
		 (delete-char 1)
		 (hyperlatex-delete-whitespace t)))))))

(defun hyperlatex-format-ignorespaces ()
  (hyperlatex-delete-|)
  (hyperlatex-delete-whitespace))
  
(defun hyperlatex-delete-| ()
  "Skip and delete all meta-| magic characters."
  (let ((here (point)))
    (skip-chars-forward hyperlatex-meta-|)
    (delete-region here (point))))
  
(defun hyperlatex-insert-required-argument ()
  (save-excursion (insert (hyperlatex-parse-required-argument))))

(defun hyperlatex-delete-comment ()
  "When looking at % character, deletes the comment."
  (hyperlatex-delete-whitespace)
  (while (looking-at "%")
    (delete-region (point) (progn (forward-line 1) (point)))
    (hyperlatex-delete-whitespace t)))

(defun hyperlatex-format-T ()
  (goto-char hyperlatex-command-start)
  (if hyperlatex-beginning-new-line
      ;; the comment line was empty
      ()
    (delete-region (point) (progn (forward-line 1) (point)))
    (hyperlatex-delete-whitespace t)))

(defun hyperlatex-evaluate-string (str &optional special)
  "Evaluates a STRING.
Optional argument SPECIAL is regexp to match special characters."
  (let ((hyperlatex-special-chars-regexp
	 (if special special hyperlatex-special-chars-regexp))
	(here (point)))
    (insert str)
    (hyperlatex-format-region here (point) t)
    (prog1
	(buffer-substring here (point))
      (delete-region here (point))
      (goto-char here))))

(defun hyperlatex-parse-evaluated-argument (special)
  "Parses a required argument, and evaluates it completely, returning string.
Argument SPECIAL is regexp to match special characters."
  (let ((arg (hyperlatex-parse-required-argument)))
    (hyperlatex-evaluate-string arg special)))

;;;
;;; ----------------------------------------------------------------------
;;;
;;; \newcommand, \newenvironment, \xxx
;;;

(put 'newcommand	'hyperlatex 'hyperlatex-format-newcommand)
(put 'providecommand	'hyperlatex 'hyperlatex-format-providecommand)
(put 'newenvironment	'hyperlatex 'hyperlatex-format-newenvironment)
(put 'renewcommand	'hyperlatex 'hyperlatex-format-newcommand)
(put 'renewenvironment	'hyperlatex 'hyperlatex-format-newenvironment)
(put 'HlxSkipStar	'hyperlatex 'hyperlatex-format-hlxskipstar)
(put 'HlxTraceMacros	'hyperlatex 'hyperlatex-format-hlxtracemacros)
(put 'begingroup	'hyperlatex 'hyperlatex-format-begingroup)
(put 'endgroup		'hyperlatex 'hyperlatex-format-endgroup)
(put 'HlxNameUse	'hyperlatex 'hyperlatex-format-hlxnameuse)
(put 'HlxAppend         'hyperlatex 'hyperlatex-format-hlxappend)
(put 'HlxCallEval       'hyperlatex 'hyperlatex-format-hlxcalleval)

(defun hyperlatex-format-hlxcalleval ()
  "Call command with evaluated argument."
  (let ((command (hyperlatex-parse-required-argument))
	(arg (hyperlatex-parse-evaluated-argument
	      hyperlatex-special-chars-regexp)))
    (insert command "{" arg "}")
    (goto-char hyperlatex-command-start)))

(defun hyperlatex-format-hlxskipstar ()
  "Skip a star if it is present, and insert argument after it."
  (let ((arg (hyperlatex-parse-required-argument)))
    (hyperlatex-starred-p)
    (insert arg)
    (goto-char hyperlatex-command-start)))

(defun hyperlatex-format-newcommand ()
  (let ((name (hyperlatex-parse-required-argument))
	(nbargs (hyperlatex-parse-optional-argument))
	(opttext (hyperlatex-parse-optional-argument))
	(expansion (hyperlatex-parse-required-argument)))
    (hyperlatex-define-macro (substring name 1)
			     (if nbargs (string-to-int nbargs) 0)
			     expansion
			     opttext)))

(defun hyperlatex-format-providecommand ()
  (let ((name (substring (hyperlatex-parse-required-argument) 1))
	(nbargs (hyperlatex-parse-optional-argument))
	(opttext (hyperlatex-parse-optional-argument))
	(expansion (hyperlatex-parse-required-argument)))
    (let ((match (assoc name hyperlatex-new-commands)))
      (if match
	  () ;; nothing to be done if already defined
	(hyperlatex-define-macro name
				 (if nbargs (string-to-int nbargs) 0)
				 expansion
				 opttext)))))
    
(defun hyperlatex-format-hlxappend ()
  (let* ((name (substring (hyperlatex-parse-required-argument) 1))
	 (expansion (hyperlatex-parse-required-argument))
	 (match (assoc name hyperlatex-new-commands)))
    (if match
	(let ((nbargs (elt match 1))
	      (old-expansion (elt match 2))
	      (opttext (elt match 3)))
	  (setcdr match 
		  (list nbargs (concat old-expansion expansion) opttext)))
      (error "Name `%s' not yet defined" name))))
    
(defun hyperlatex-format-newenvironment ()
  (let ((name (hyperlatex-parse-required-argument))
	(nbargs (hyperlatex-parse-optional-argument))
	(opttext (hyperlatex-parse-optional-argument))
	(beginexp (hyperlatex-parse-required-argument))
	(endexp   (hyperlatex-parse-required-argument)))
    (hyperlatex-define-environment name
				   (if nbargs (string-to-int nbargs) 0)
				   beginexp endexp
				   opttext)))

(defun hyperlatex-replace-parm (end nbargs arguments)
  "Replaces the first parameter occurrance.
Returns NIL if no parameter in string, t otherwise."
  (let ((cont t))
    (if (looking-at "#")
	(goto-char (1+ (point)))
      (setq cont (re-search-forward "[^\\]#" end t)))
    ;; point is behind # char if found
    (if cont
	(if (looking-at "[1-9]")
	    (let ((narg (- (following-char) ?1)))
	      (delete-region (1- (point)) (1+ (point)))
	      (if (> narg nbargs)
		  (error "Illegal parameter number in definition"))
	      (insert-before-markers
	       (nth (- (1- nbargs) narg) arguments)))
	  (if (looking-at "#")
	      (progn
		(delete-char 1)
		(skip-chars-forward "#"))
	    (error "Illegal parameter substitution"))))
    cont))

(defun hyperlatex-unsupported (&optional silent)
  "Called for \\commands not defined in Hyperlatex. Looks them up in
`hyperlatex-new-commands' and inserts them at point.
 Complains if not found, unless optional argument SILENT is non-nil."
  (let ((match (assoc (symbol-name hyperlatex-command-name)
		      hyperlatex-new-commands)))
    (if match
	(let* ((nbargs (car (cdr match)))
	       (count nbargs)
	       (expansion (car (cdr (cdr match))))
	       (opttext (car (cdr (cdr (cdr match)))))
	       (arguments nil))
	  (if (and (> count 0) opttext)
	      (let ((oarg (hyperlatex-parse-optional-argument)))
		(setq count (1- count))
		(setq arguments (cons (if oarg oarg opttext) arguments))))
	  (while (> count 0)
	    (setq count (1- count))
	    (setq arguments
		  (cons (hyperlatex-parse-required-argument) arguments)))
	  (insert expansion)
	  ;; replace arguments in expansion
	  (let ((end (point-marker)))
	    (insert hyperlatex-meta-|)
	    (goto-char hyperlatex-command-start)
	    (while (hyperlatex-replace-parm end nbargs arguments))
	    (goto-char end)
	    (if hyperlatex-show-expansions
		(let ((a arguments))
		  (hyperlatex-message "Expanding: \\%s[%d]"
			   (symbol-name hyperlatex-command-name)
			   nbargs)
		  (while a
		    (hyperlatex-message "Argument: %s" (car a))
		    (setq a (cdr a)))
		  (hyperlatex-message "Expansion: %s"
			   (buffer-substring hyperlatex-command-start end))))
	    (set-marker end nil)))
      (if silent
	  ()
	(error "Unknown command: %s" (symbol-name hyperlatex-command-name))))))

(defun hyperlatex-define-macro (name nbargs expansion &optional opttext)
;;  (hyperlatex-message "Defined macro: %s[%d] --> %s"
;;	   name nbargs expansion)
  (setq hyperlatex-new-commands
	(cons (list name nbargs expansion opttext)
	      hyperlatex-new-commands)))

(defun hyperlatex-define-environment (name nbargs beginexp endexp
					   &optional opttext)
  (setq hyperlatex-new-commands
	(cons (list name nbargs beginexp opttext)
	      (cons (list (concat "end" name) 0 endexp nil)
		    hyperlatex-new-commands))))

(defun hyperlatex-format-hlxtracemacros ()
  (setq hyperlatex-show-expansions t))

(defun hyperlatex-format-begingroup ()
  ;; start new group of command definitions
  (setq hyperlatex-new-commands (cons 'group hyperlatex-new-commands)))

(defun hyperlatex-format-endgroup ()
  ;; remove command definitions inside the group
  (while (and (consp hyperlatex-new-commands)
	      (not (eq 'group (car hyperlatex-new-commands))))
    (setq hyperlatex-new-commands (cdr hyperlatex-new-commands)))
  (if (null hyperlatex-new-commands)
      (error "Unmatched \\endgroup")
    (setq hyperlatex-new-commands (cdr hyperlatex-new-commands))))
  
(defun hyperlatex-format-hlxnameuse ()  
  "\\HlxNameUse{arg}"
  (let ((arg (hyperlatex-parse-required-argument)))
    (insert (concat "\\" arg))
    (goto-char hyperlatex-command-start)))


;;;
;;; ----------------------------------------------------------------------
;;;
;;; Grouping and Environments
;;;

(put 'begin		'hyperlatex 'hyperlatex-format-begin)
(put 'end		'hyperlatex 'hyperlatex-format-end)
(put 'group		'hyperlatex 'hyperlatex-format-ignore)
(put 'aftergroup	'hyperlatex 'hyperlatex-format-aftergroup)

;; \begin{xxx} pushes 'xxx on hyperlatex-stack.
;; \end{yyy} checks whether the proper environment is terminated.
;; { and } is treated as `group' environment
;; \begin adds new entry "" to hyperlatex-group-stack
;; \end pops the top string and inserts it

(defun hyperlatex-format-begin ()
  (setq hyperlatex-command-name (intern (hyperlatex-parse-required-argument)))
  (setq hyperlatex-stack
	(cons hyperlatex-command-name hyperlatex-stack))
  (setq hyperlatex-group-stack
	(cons "" hyperlatex-group-stack))
  (let ((cmd (get hyperlatex-command-name 'hyperlatex)))
    (if cmd
	(funcall cmd)
      (hyperlatex-unsupported)
      (goto-char hyperlatex-command-start))))

(defun hyperlatex-format-end ()
  (let* ((env    (hyperlatex-parse-required-argument))
	 (endenv (intern (concat "end" env)))
	 (cmd    (get endenv 'hyperlatex)))
    (setq hyperlatex-command-name endenv)
    (insert (car hyperlatex-group-stack))
    (if (not cmd) (hyperlatex-unsupported t))
    (hyperlatex-format-region hyperlatex-command-start (point))
    (if cmd (funcall cmd))
    (hyperlatex-return-environment (intern env))))

(defun hyperlatex-begin-group ()
  (setq hyperlatex-stack (cons 'group hyperlatex-stack))
  (setq hyperlatex-group-stack (cons "" hyperlatex-group-stack)))

(defun hyperlatex-end-group ()
  ;; insert and execute \aftergroup stuff
  (setq hyperlatex-command-start (point))
  (insert (car hyperlatex-group-stack))
  (hyperlatex-format-region hyperlatex-command-start (point))
  (hyperlatex-return-environment 'group))

(defun hyperlatex-return-environment (env)
  ;; check matching of environments
  ;; (must be done after executing the environment definition)
  (if (not (eq (car hyperlatex-stack) env))
      (if (eq env 'group)
	  (error "Too many }'s.")
	(error "\\end{%s} matches \\begin{%s}"
	       (symbol-name env) (car hyperlatex-stack))))
  ;; pop stacks
  (setq hyperlatex-stack (cdr hyperlatex-stack))
  (setq hyperlatex-group-stack (cdr hyperlatex-group-stack))
  ;; The paragraphination only needs to be adjusted after returning to
  ;; text.  This test is not adequate, but it works most of the time.
  (if (eq (car hyperlatex-stack) "document")
      (setq hyperlatex-in-paragraph nil)))

(defun hyperlatex-pop-stacks ()
  "This function is used in an environment that skips its contents completely."
  (setq hyperlatex-stack (cdr hyperlatex-stack))
  (setq hyperlatex-group-stack (cdr hyperlatex-group-stack)))

(defun hyperlatex-in-stack (tag)
  (memq tag hyperlatex-stack))

(defun hyperlatex-format-aftergroup ()
  (let ((arg (hyperlatex-parse-required-argument)))
    (setq hyperlatex-group-stack
	  (cons (concat arg (car hyperlatex-group-stack))
		(cdr hyperlatex-group-stack)))))
  
;;;
;;; ----------------------------------------------------------------------
;;;
;;; Simple Tex/Html choices, par
;;;

(put 'par       'hyperlatex 'hyperlatex-new-format-par)
(put 'endpar    'hyperlatex 'hyperlatex-format-endpar)
(put 'suspendpars 'hyperlatex 'hyperlatex-format-suspendpars)
(put 'resumepars 'hyperlatex 'hyperlatex-format-resumepars)
(put 'T	        'hyperlatex 'hyperlatex-format-T)
(put 'W	        'hyperlatex 'hyperlatex-format-ignore)
(put 'input     'hyperlatex 'hyperlatex-format-input)

(defun hyperlatex-format-ignore ()
  "Function that does not do anything.")

(defun hyperlatex-new-format-par ()
  "Leave a paragraph (if in one) and enter v-mode."
  (hyperlatex-leave-par)
  (hyperlatex-enter-v-mode))

(defun hyperlatex-format-par ()
  "Starts a paragraph."
;; RK's 
  (if t nil
;;
  (if (and hyperlatex-in-body
	   (not hyperlatex-in-paragraph))
      (progn
	(insert hyperlatex-meta-p)
	(setq hyperlatex-in-paragraph t))))
;; RK's
)
;;

(defun hyperlatex-format-endpar ()
  "Explicitly ends a paragraph.  In most environment definitions, 
this function must be explicitly called at the \begin, either as 
\endpar or as the lisp function.  See the definition of the itemize 
environment in siteinit.hlx and the definition of example in this
file. " 
;; RK's
  (hyperlatex-leave-par)
;;  (if (and hyperlatex-in-paragraph hyperlatex-in-body)
;;      (progn 
;;	(insert hyperlatex-meta-P)
;;	(setq hyperlatex-in-paragraph nil))))
;; end of RK's
)

(defun hyperlatex-format-suspendpars ()
;; RK's
;;  (setq hyperlatex-in-b nil)
;;  
  (setq hyperlatex-in-body nil))

(defun hyperlatex-format-resumepars ()
;; RK's
;;  (setq hyperlatex-in-b t)
;;
  (setq hyperlatex-in-body t))

(defun hyperlatex-empty-line ()
  (delete-region (match-beginning 0) (point))
  (insert "\n"))

(defun hyperlatex-format-texorhtml ()
  (hyperlatex-parse-required-argument)
  (hyperlatex-insert-required-argument))

(defun hyperlatex-format-input ()
  (let* ((arg (hyperlatex-parse-evaluated-argument
	       (concat "[\\\\%{}" hyperlatex-meta-| "]")))
	 (file-name
	  (cond ((file-readable-p
		  (expand-file-name arg hyperlatex-input-directory))
		 (expand-file-name arg hyperlatex-input-directory))
		((file-readable-p (expand-file-name
				   (concat arg ".tex")
				   hyperlatex-input-directory))
		 (expand-file-name (concat arg ".tex")
				   hyperlatex-input-directory))
		(t (error "I can't find the file %s" arg)))))
    (hyperlatex-insert-file file-name)))

(defun hyperlatex-insert-file (file-name)
  (hyperlatex-message "Inserting file %s..." file-name)
  (goto-char (+ (point) 
		(car (cdr (insert-file-contents-literally file-name)))))
  (save-restriction
    (narrow-to-region hyperlatex-command-start (point))
    (hyperlatex-prelim-substitutions (point-min) (point-max))
    (goto-char (point-min)))
  (hyperlatex-message "Inserting file %s...done" file-name))

;;; ----------------------------------------------------------------------
;;;
;;; Make sections and nodes
;;;

(put 'HlxSection	'hyperlatex 'hyperlatex-format-hlxsection)
(put 'xname		'hyperlatex 'hyperlatex-format-xname)
(put 'htmlpanel		'hyperlatex 'hyperlatex-format-htmlpanel)
(put 'HlxTocName        'hyperlatex 'hyperlatex-format-hlxtocname)

(defun hyperlatex-format-hlxtocname ()
  (if hyperlatex-final-pass
      ()
    (setq hyperlatex-node-names
	  (cons (cons (1+ hyperlatex-node-number)
		      (format "%s_toc%s" hyperlatex-basename
			      (hyperlatex-html-ext)))
		hyperlatex-node-names))))

(defun hyperlatex-format-xname ()
  (if hyperlatex-final-pass
      (hyperlatex-parse-required-argument)
    (setq hyperlatex-node-names
	  (cons (cons (1+ hyperlatex-node-number)
		      (format "%s%s" (hyperlatex-parse-required-argument)
			      (hyperlatex-html-ext)))
		hyperlatex-node-names))))

(defun hyperlatex-format-htmlpanel ()
  (setq hyperlatex-make-panel
	(string= (hyperlatex-parse-required-argument) "1")))

(defun hyperlatex-new-node (level head)
  "Finish up the previous node, and start a new node.
Assumes that the command starting the new node has already been removed,
and that we are at the beginning of a new line."
  ;; finish up old node
  (hyperlatex-finish-node)
  (setq hyperlatex-node-number (1+ hyperlatex-node-number))
  (setq hyperlatex-sect-number (1+ hyperlatex-sect-number))
  (hyperlatex-make-node-header head))

(defun hyperlatex-format-hlxsection ()
;; RK's
;;  (hyperlatex-leave-par)
;;  (hyperlatex-mode-level-up "hlxsection") 
;;  (hyperlatex-enter-h-mode)
;; end of RK's
  (let* ((ltxlevel (string-to-number (hyperlatex-parse-required-argument)))
	 (secnumbase (hyperlatex-counter-value "HlxSecNumBase"))
	 (level (if (<= ltxlevel secnumbase) 1 (- ltxlevel secnumbase)))
	 (counter (hyperlatex-parse-required-argument))
	 (star	  (hyperlatex-starred-p))
	 (optarg (hyperlatex-parse-optional-argument))
	 (reqarg (hyperlatex-parse-required-argument))
	 (head   (if optarg optarg reqarg))
	 (hyperlatex-in-body nil)
	 (new-node (if hyperlatex-xml
		       ()
		     (or (<= ltxlevel -5)
			 (< level (hyperlatex-counter-value "htmldepth"))))))
;; RK's
    (hyperlatex-debug-msg "Section header being analysed")
    (hyperlatex-debug-msg (concat "Counter=" (if (null counter) "nil" counter)))
    (hyperlatex-debug-msg (concat "optarg="  (if (null optarg) "nil" optarg)))
    (hyperlatex-debug-msg (concat "reqarg="  (if (null reqarg) "nil" reqarg)))
;; end of RK's
    (setq hyperlatex-in-paragraph nil)
    (hyperlatex-delete-whitespace)
    ;; Section number required?
    (if (or star
	    (> ltxlevel (hyperlatex-counter-value "secnumdepth")))
	()
      (hyperlatex-refstepcounter counter)
      (setq head (concat "\\the" counter "{} " head))
      (setq reqarg (concat "\\the" counter "{} " reqarg)))
    ;; Evaluate title for toc and navigation panels
    (setq head (hyperlatex-evaluate-string head))
    ;; So we can see where we are.
    (hyperlatex-message 
      (if hyperlatex-final-pass "Formatting: %s ... " "Parsing: %s ... ") 
			(hyperlatex-purify head))
    ;; if level is high enough, start new node
;; RK's
    (hyperlatex-debug-msg (concat "Node level " (number-to-string level)
     " htmldepth " (number-to-string (hyperlatex-counter-value "htmldepth"))
     " ltxlevel " (number-to-string ltxlevel)))
;; end of RK's
    (if new-node
	(hyperlatex-new-node level head)
      ;; otherwise add a new label
      (setq hyperlatex-sect-number (1+ hyperlatex-sect-number))
      (setq hyperlatex-label-number (1+ hyperlatex-label-number)))
    ;; finally, add new heading
    (if hyperlatex-final-pass
	()
      (setq hyperlatex-sections
	    (cons (list hyperlatex-sect-number
			hyperlatex-node-number
			head
			level
			(1- hyperlatex-label-number))
		  hyperlatex-sections)))
    (setq hyperlatex-menu-in-section nil)
    (if (string= reqarg "")
	(if new-node
	    (insert hyperlatex-meta-l)
	  (hyperlatex-blk)
	  (hyperlatex-gen (format hyperlatex-a-name-format
				  (hyperlatex-label-string
				   (1- hyperlatex-label-number)
				   hyperlatex-node-number)))
	  ;;;(hyperlatex-gensym "nbsp") commented out 3/11/05 ts.
	  (hyperlatex-gen "/a" (concat hyperlatex-meta-l "\n"))
	  (hyperlatex-format-par))
;; RK's -- save-excursion needed here for reqarg 
;; to be read again, starting from (point)
    (save-excursion  
	(hyperlatex-blk)
;; RK's: Remove the two whiles as not needed any more after my changes.
;;       The latter removes national characters from section header
;;       so it cannot stay here anyway!
	;;; The next two whiles are a bit of a hack.  They exist to keep a <p> tag from being
        ;;; placed inside the <h1> tags.  They work by removing any carriage returns that might
        ;;; exist there.  This is not the best solution to the <p> placement problem.  Ideally, 
        ;;; a <p> simply shouldn't be put inside a header, but the mechanism doesn't currently
        ;;; exist to guarantee it.  4/24/05
;;	(while (string-match "\n" reqarg)
;;	  (setq reqarg (replace-match "" t t reqarg)))
;;	(while (string-match "\\s \\s +" reqarg)
;;	  (setq reqarg (replace-match " " t t reqarg)))
;; end of commented out by RK
	(if new-node
	    (progn
;; RK's: commented out to keep the original version, and then rearranged
;;	      (hyperlatex-gen 
;;                 (hyperlatex-get-attributes (format "h%d" level)) reqarg)
	      (hyperlatex-gen (hyperlatex-get-attributes (format "h%d" level)))
              (insert "\\beginsectionarg{}" reqarg "\\endsectionarg{}")
;; end of RK's
	      (hyperlatex-gen (format "/h%d" level)
			      (concat hyperlatex-meta-l "\n")))
;	      (setq hyperlatex-in-paragraph nil))
	  (insert "\n")
	  (hyperlatex-gen
            (hyperlatex-get-attributes (format "h%d" level)))
	  (hyperlatex-gen (format hyperlatex-a-name-format
				  (hyperlatex-label-string
				   (1- hyperlatex-label-number)
				   hyperlatex-node-number)))
;; RK's commented out to preserve the original and then reprogrammed
;;	  (insert reqarg)
          (insert "\\beginsectionarg{}" reqarg "\\endsectionarg{}")
          (hyperlatex-debug-msg (concat "stack's length "
                                (number-to-string (length hyperlatex-mode-stack))
                                 " point " 
                                (number-to-string (hyperlatex-get-tag-point))))
;; 
          
	  (hyperlatex-gen "/a" hyperlatex-meta-l)
	  (hyperlatex-gen (format "/h%d" level) hyperlatex-meta-l)
	  ;(setq hyperlatex-in-paragraph nil)
	  )
        (insert "\\endsectionassuch{}")
; should be done by endsectionarg  (hyperlatex-mode-level-down "hlxsection")
)))
;; RK's
       (hyperlatex-debug-msg
           (if hyperlatex-final-pass "Final pass" "Not final"))
       (hyperlatex-debug-msg (concat "char(" 
           (buffer-substring-no-properties (point) (point)) ")"))
       (hyperlatex-debug-msg (concat "char(" 
           (buffer-substring-no-properties (+ (point) 1) (+ (point) 1)) ")"))
       (hyperlatex-debug-msg (concat "End of section " 
         (number-to-string (length hyperlatex-mode-stack))))
;; end of RK's
)

;; RK's
(defun hyperlatex-format-beginsectionarg ()
"Enters new mode level for paragraph recognition inside a section header.
Actually LaTeX and HTML forbid paragraphs in section headers
so we enter a new level just to prevent them from being genrtated."
  (hyperlatex-mode-level-up "beginsectionarg")
  ;; enter horizontal mode to prevent <p> from being
  ;; generated at the beginning of a section title
  (hyperlatex-enter-h-mode))

(defun hyperlatex-format-endsectionarg ()
"Leaves mode level entered by hyperlatex-format-beginsectionarg."
  (hyperlatex-mode-level-down "endsectionarg"))

(defun hyperlatex-format-endsectionassuch ()
"Leaves mode level entered by hyperlatex-format-beginsectionarg."
;;  (hyperlatex-mode-level-down "endsectionassuch")
  ;; allow generating a <p> at current point
  (hyperlatex-set-point (point)))
;; end of RK's

;;;
;;; ----------------------------------------------------------------------
;;;
;;; Final Pass: Insert Panels and Menus
;;;

(defun hyperlatex-make-node-header (head)
  "Creates header for new node, with filename, title etc."
  (delete-region (point-min) (point))
  (setq hyperlatex-current-filename
	(concat hyperlatex-html-directory "/"
		(hyperlatex-fullname hyperlatex-node-number)))
  (setq hyperlatex-made-panel hyperlatex-make-panel)
;; RK's change (replace UTF-8 with hyperlatex-xml-charset)
;;  (hyperlatex-gen "?xml version=\"1.0\" encoding=\"UTF-8\"?" "\n")
  (hyperlatex-gen 
    (concat "?xml version=\"1.0\" encoding=\"" hyperlatex-xml-charset "\"?") 
    "\n")
  ;; XML intro is user defined
  (if hyperlatex-xml
      ()
    (hyperlatex-gen
     (concat
      "!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\"\n"
      "   \"DTD/xhtml1-transitional.dtd\"")
     "\n")
    (hyperlatex-gen "html xmlns=\"http://www.w3.org/1999/xhtml\"" "\n"))
  (hyperlatex-gen
   (concat "!-- XML file produced from " hyperlatex-produced-from
	   "\n     using Hyperlatex v "
	   hyperlatex-version " (c) Otfried Cheong"
	   "\n     on Emacs " emacs-version ", " (current-time-string) " --")
   "\n")
  (if hyperlatex-xml
      (let ((start (point)))
	(insert "\\HlxXmlIntro{}\n")
	(hyperlatex-format-region start (point)))
    (hyperlatex-gen (hyperlatex-get-attributes "head") "\n")
    (hyperlatex-gen (hyperlatex-get-attributes "title"))
    (insert hyperlatex-title 
	    (hyperlatex-purify (if head (concat " -- " head) "")))
    (hyperlatex-gen "/title" "\n")
    (if hyperlatex-final-pass
	(let ((start (point)))
	  (insert "\\HlxStyleSheet{}\n\\HlxMetaFields{}\n")
	  (hyperlatex-format-region start (point))))
    (hyperlatex-gen "/head" "\n")
    (hyperlatex-gen (hyperlatex-get-attributes "body") "\n"))
  (setq hyperlatex-label-number 1)
  (setq hyperlatex-node-section hyperlatex-sect-number)
  (if (and hyperlatex-final-pass hyperlatex-made-panel)
      (let ((start (point)))
	(insert "\\HlxTopPanel{}\n")
	(hyperlatex-format-region start (point))))
  (hyperlatex-format-resumepars))

(defun hyperlatex-finish-node ()
  "Finish up the previous node, and saves it."
  ;; insert automatic menu, if desired
  (hyperlatex-format-suspendpars)
  (setq hyperlatex-in-paragraph nil)
  (and (not hyperlatex-menu-in-section)
       (not (zerop (hyperlatex-counter-value "htmlautomenu")))
       hyperlatex-final-pass
       (hyperlatex-insert-menu
	hyperlatex-sect-number
	(hyperlatex-counter-value "htmlautomenu")))
  ;; and finish with bottom panel
  (if hyperlatex-final-pass
      (let ((start (point)))
	(insert "\\HlxBottomMatter{}\n")
	(if (and hyperlatex-made-panel)
	    (insert "\\HlxBottomPanel{}"))
	(hyperlatex-format-region start (point))))
  (if hyperlatex-xml
      ;; XML extro is user defined
      (let ((start (point)))
	(insert "\\HlxXmlExtro{}\n")
	(hyperlatex-format-region start (point)))
    (hyperlatex-gen "/body")
    (hyperlatex-gen "/html" "\n"))
  ;; save the node
  (if hyperlatex-final-pass
      (save-restriction
	(narrow-to-region (point-min) (point))
	(hyperlatex-final-substitutions)
	(hyperlatex-write-region (point-min) (point-max) 
				 hyperlatex-current-filename)
	(if (not noninteractive)
	    (hyperlatex-message "Wrote file %s" hyperlatex-current-filename))
	(goto-char (point-max)))))

(defun hyperlatex-fullname (node-number)
  (if (and (not hyperlatex-making-frames)
	   (zerop node-number))
      (concat hyperlatex-basename (hyperlatex-html-ext))
    (let ((m (assoc node-number hyperlatex-node-names)))
      (if m
	  (cdr m)
	(format "%s_%d%s" hyperlatex-basename node-number
		(hyperlatex-html-ext))))))

;;;
;;; ----------------------------------------------------------------------
;;;   Frames
;;;

(defun hyperlatex-make-frames-headers ()
  "Creates frameset file."
  ;; first we make the frameset
  (delete-region (point-min) (point))
;; RK's change
  (hyperlatex-gen "?xml version=\"1.0\" encoding=\"UTF-8\"?" "\n")
;;  (hyperlatex-gen 
;;    (concat "?xml version=\"1.0\" encoding=\"" hyperlatex-xml-charset "\"?") 
;;    "\n")
  (hyperlatex-gen
   (concat "!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Frameset//EN\"\n"
           "   \"DTD/xhtml1-frameset.dtd\"")
   "\n")
  (hyperlatex-gen "html xmlns=\"http://www.w3.org/1999/xhtml\"" "\n")
  (hyperlatex-gen
   (concat "!-- XML file produced from " hyperlatex-produced-from
	   "\n     using Hyperlatex v "
	   hyperlatex-version " (c) Otfried Cheong"
	   "\n     on Emacs " emacs-version ", " (current-time-string) " --")
   "\n")
  (hyperlatex-gen (hyperlatex-get-attributes "head") "\n")
  (hyperlatex-gen (hyperlatex-get-attributes "title"))
  (insert hyperlatex-title)
  (hyperlatex-gen "/title" "\n")
  (hyperlatex-gen "/head")
  (let ((begin (point)))
    (insert "\\HlxFramesDescription{"
	    hyperlatex-basename "}{" hyperlatex-html-ext "}")
    (hyperlatex-gen "/html" "\n")
    (let ((end (point-marker)))
      (hyperlatex-format-region begin end)
      (goto-char end)
      (set-marker end nil)))
;; RK's
  (hyperlatex-debug-show-p-positions)
;;
  ;; save the node
  (save-restriction
    (narrow-to-region (point-min) (point))
    (hyperlatex-final-substitutions)
    (hyperlatex-write-region (point-min) (point-max)
			     (concat hyperlatex-html-directory "/"
				     hyperlatex-basename hyperlatex-html-ext))
    (goto-char (point-max))))

;;;
;;; ----------------------------------------------------------------------
;;;

(put 'HlxPrevUrl	'hyperlatex 'hyperlatex-format-hlxprevurl)
(put 'HlxUpUrl		'hyperlatex 'hyperlatex-format-hlxupurl)
(put 'HlxNextUrl	'hyperlatex 'hyperlatex-format-hlxnexturl)
(put 'HlxBackUrl	'hyperlatex 'hyperlatex-format-hlxbackurl)
(put 'HlxForwUrl	'hyperlatex 'hyperlatex-format-hlxforwurl)
(put 'HlxPrevTitle	'hyperlatex 'hyperlatex-format-hlxprevtitle)
(put 'HlxUpTitle	'hyperlatex 'hyperlatex-format-hlxuptitle)
(put 'HlxNextTitle	'hyperlatex 'hyperlatex-format-hlxnexttitle)
(put 'HlxBackTitle	'hyperlatex 'hyperlatex-format-hlxbacktitle)
(put 'HlxForwTitle	'hyperlatex 'hyperlatex-format-hlxforwtitle)
(put 'HlxNodeNumber	'hyperlatex 'hyperlatex-format-hlxnodenumber)
(put 'HlxThisUrl	'hyperlatex 'hyperlatex-format-hlxthisurl)
(put 'HlxThisTitle	'hyperlatex 'hyperlatex-format-hlxthistitle)
(put 'HlxPure           'hyperlatex 'hyperlatex-format-hlxpure)

(defun hyperlatex-format-hlxpure ()
  (let ((arg (hyperlatex-parse-evaluated-argument
	      hyperlatex-special-chars-regexp)))
    (insert (hyperlatex-purify arg))))
     
(defun hyperlatex-this-node ()
  "Return (sect-num sect-node sect-head sect-lvl sect-label) of current node."
  (let ((sp hyperlatex-sections))
    (while (/= (hyperlatex-sect-num (car sp)) hyperlatex-node-section)
      (setq sp (cdr sp)))
    ;; sp points to section
    (car sp)))

(defun hyperlatex-format-hlxthisurl ()
  "Return URL of current node."
  (insert (hyperlatex-fullname hyperlatex-node-number)))

(defun hyperlatex-format-hlxthistitle ()
  "Return title of current node." 
  (let ((this (hyperlatex-this-node)))
    (insert (hyperlatex-sect-head this))))

(defun hyperlatex-format-hlxnodenumber ()
  (insert (int-to-string hyperlatex-node-number)))

(defun hyperlatex-format-hlxprevurl ()
  (let ((node (hyperlatex-prev-node hyperlatex-node-section)))
    (if node
	(insert (hyperlatex-fullname (hyperlatex-sect-node node))))))

(defun hyperlatex-format-hlxupurl ()
  (let ((node (hyperlatex-up-node hyperlatex-node-section)))
    (if node
	(insert (hyperlatex-fullname (hyperlatex-sect-node node))))))

(defun hyperlatex-format-hlxnexturl ()
  (let ((node (hyperlatex-next-node hyperlatex-node-section)))
    (if node
	(insert (hyperlatex-fullname (hyperlatex-sect-node node))))))

(defun hyperlatex-format-hlxbackurl ()
  (let ((node (hyperlatex-back-node hyperlatex-node-section)))
    (if node
	(insert (hyperlatex-fullname (hyperlatex-sect-node node))))))
  
(defun hyperlatex-format-hlxforwurl ()
  (let ((node (hyperlatex-forw-node hyperlatex-node-section)))
    (if node
	(insert (hyperlatex-fullname (hyperlatex-sect-node node))))))

(defun hyperlatex-format-hlxprevtitle ()
  (let ((node (hyperlatex-prev-node hyperlatex-node-section)))
    (if node
	(insert (hyperlatex-sect-head node)))))

(defun hyperlatex-format-hlxuptitle ()
  (let ((node (hyperlatex-up-node hyperlatex-node-section)))
    (if node
	(insert (hyperlatex-sect-head node)))))

(defun hyperlatex-format-hlxnexttitle ()
  (let ((node (hyperlatex-next-node hyperlatex-node-section)))
    (if node
	(insert (hyperlatex-sect-head node)))))

(defun hyperlatex-format-hlxbacktitle ()
  (let ((node (hyperlatex-back-node hyperlatex-node-section)))
    (if node
	(insert (hyperlatex-sect-head node)))))

(defun hyperlatex-format-hlxforwtitle ()
  (let ((node (hyperlatex-forw-node hyperlatex-node-section)))
    (if node
	(insert (hyperlatex-sect-head node)))))

;;;
;;; ----------------------------------------------------------------------
;;;

(defun hyperlatex-sect-head (sect)
  "Returns heading of SECT, a pointer into either list."
  (nth 2 sect))

(defun hyperlatex-sect-level (sect)
  "Returns level of SECT, a pointer into either list."
  (nth 3 sect))

(defun hyperlatex-sect-node (sect)
  "Returns node number of SECT, a pointer into either list."
  (nth 1 sect))

(defun hyperlatex-sect-num (sect)
  "Returns section number of SECT, a pointer into either list."
  (car sect))

(defun hyperlatex-sect-label (sect)
  "Returns label of SECT, a pointer into either list."
  (nth 4 sect))

;;;
;;; ----------------------------------------------------------------------
;;;

;; fixed by tom sgouros 99/2/24
(defun hyperlatex-back-node (sect)
  "Returns the backwards node of section number SECT."
  (if (zerop sect)
      ()
    (let ((sp hyperlatex-sections))
      (while (/= (hyperlatex-sect-num (car sp)) sect)
	(setq sp (cdr sp)))
      ;; sp points to section
      (let ((sect-node (hyperlatex-sect-node (car sp))))
	(while (and sp (= sect-node (hyperlatex-sect-node (car sp))))
	  (setq sp (cdr sp)))
	(if sp (car sp) ())))))
      
;; fixed by tom sgouros 99/2/24
(defun hyperlatex-forw-node (sect)
  "Returns the forwards node of section number SECT."
  (if (zerop sect)
      ()
    (let ((sp hyperlatex-rev-sections))
      (while (/= (hyperlatex-sect-num (car sp)) sect)
	(setq sp (cdr sp)))
      ;; sp points to section
      (let ((sect-node (hyperlatex-sect-node (car sp))))
	(while (and sp (= sect-node (hyperlatex-sect-node (car sp))))
	  (setq sp (cdr sp)))
	(if sp (car sp) ())))))
      
(defun hyperlatex-prev-node (sect)
  "Returns the previous node of section number SECT."
  (if (zerop sect)
      ()
    (let ((sp hyperlatex-sections))
      (while (/= (hyperlatex-sect-num (car sp)) sect)
	(setq sp (cdr sp)))
      ;; sp points to section 
      (let ((lev (hyperlatex-sect-level (car sp))))
	(setq sp (cdr sp))
	(while (> (hyperlatex-sect-level (car sp)) lev)
	  (setq sp (cdr sp)))
	;; now sp points at previous section with level equal or higher
	(if (= (hyperlatex-sect-level (car sp)) lev)
	    (car sp)
	  ())))))

(defun hyperlatex-up-node (sect)
  "Returns the up node of section number SECT."
  (if (zerop sect)
      ()
    (let ((sp hyperlatex-sections))
      (while (/= (hyperlatex-sect-num (car sp)) sect)
	(setq sp (cdr sp)))
      ;; sp points to section 
      (let ((lev (hyperlatex-sect-level (car sp))))
	(setq sp (cdr sp))
	(while (and sp (>= (hyperlatex-sect-level (car sp)) lev))
	  (setq sp (cdr sp)))
	;; now sp points at previous section with higher level
	(car sp)))))
  
(defun hyperlatex-next-node (sect)
  "Returns the next node of section number SECT."
  (if (zerop sect)
      ()
    (let ((sp hyperlatex-rev-sections))
      (while (/= (hyperlatex-sect-num (car sp)) sect)
	(setq sp (cdr sp)))
      ;; sp points to section 
      (let ((lev (hyperlatex-sect-level (car sp))))
	(setq sp (cdr sp))
	(while (and sp (> (hyperlatex-sect-level (car sp)) lev))
	  (setq sp (cdr sp)))
	;; now sp points at next section with higher or same level, or is nil
	(if (and sp (= (hyperlatex-sect-level (car sp)) lev))
	    (car sp)
	  ())))))

;;;
;;; ----------------------------------------------------------------------
;;;
;;; Make menus
;;;

(put 'htmlmenu	'hyperlatex 'hyperlatex-format-makemenu)

(defun hyperlatex-format-makemenu ()
  "We want a menu here, with given depth."
  (let ((narg (hyperlatex-parse-optional-argument)) 
        (depth (string-to-int (hyperlatex-parse-evaluated-argument
                                hyperlatex-special-chars-regexp))))
    (if narg
	(setq narg (string-to-number narg))
      (setq narg hyperlatex-sect-number)
      (setq hyperlatex-menu-in-section t))
    (if hyperlatex-final-pass
        (hyperlatex-insert-menu narg depth))))

(defun hyperlatex-close-menus (newlev lastlev)
  "Inserts enough UL or /UL tags to get to NEWLEV (from LASTLEV)."
  (let ((oldlev lastlev))
    (while (> newlev oldlev)
      (hyperlatex-gen (hyperlatex-get-attributes "ul") "\n")
      (setq oldlev (1+ oldlev)))
    (while (< newlev oldlev)
      (hyperlatex-gen "/ul" "\n")
      (setq oldlev (1- oldlev)))))

(defun hyperlatex-insert-menu (secnum depth)
  "Insert a menu for section SECNUM of depth DEPTH."
  (let ((sp hyperlatex-rev-sections))
    (hyperlatex-blk)
    (while (/= (hyperlatex-sect-num (car sp)) secnum)
      (setq sp (cdr sp)))
    ;; sp points to section 
    (let* ((lev (hyperlatex-sect-level (car sp)))
	   (nodenum (hyperlatex-sect-node (car sp)))
	   (lastlev lev))
      (setq sp (cdr sp))
      (while (and sp (> (hyperlatex-sect-level (car sp)) lev))
	;; sp points to a subsection of mine!
	(if (<= (hyperlatex-sect-level (car sp)) (+ lev depth))
	    ;; make a menu entry
	    (let ((newlev (hyperlatex-sect-level (car sp))))
	      (hyperlatex-close-menus newlev lastlev)
	      (setq lastlev newlev)
	      (hyperlatex-gen (hyperlatex-get-attributes "li"))
	      (hyperlatex-gen (format hyperlatex-a-href-format
				      (hyperlatex-get-attributes "a")
				      (hyperlatex-gen-url
				       (hyperlatex-sect-node (car sp))
				       (hyperlatex-sect-label (car sp)))))
	      ;;nodenum)))
	      (insert (hyperlatex-sect-head (car sp)))
	      (hyperlatex-gen "/a")
	      (hyperlatex-gen "/li" "\n")))
	(setq sp (cdr sp)))
      (hyperlatex-close-menus lev lastlev))))

;;;
;;; ----------------------------------------------------------------------
;;;
;;; Cross referencing, hypertext links
;;;

(put 'label	'hyperlatex 'hyperlatex-format-label)
(put 'Label	'hyperlatex 'hyperlatex-format-Label)
(put 'endLabel	'hyperlatex 'hyperlatex-end-Label)
(put 'link	'hyperlatex 'hyperlatex-format-link)
(put 'xlink	'hyperlatex 'hyperlatex-format-xlink)
(put 'htmlref	'hyperlatex 'hyperlatex-format-htmlref)

(defun hyperlatex-gen-url (label-node label-number &optional current)
  "Generates a URL for a label in NODE with NUMBER. If node is the same as the
CURRENT node, simply returns `#LABEL', else returns `NAME#LABEL', unless
NUMBER is zero, in which case the returned url is `NAME`.
CURRENT is optional, and defaults to the current node."
  (if (zerop label-number)
      (hyperlatex-fullname label-node)
    (format "%s#%s"
	    (if (= (if current current hyperlatex-node-number) label-node)
		""
	      (hyperlatex-fullname label-node))
	    (hyperlatex-label-string label-number label-node))))

(defun hyperlatex-label-string (num node-number)
  "Return actual string value (in URL) of label number NUM
 in node NODE-NUMBER."
  (if hyperlatex-final-pass
      (let ((match (assoc (cons num node-number) hyperlatex-label-strings)))
	(if match (cdr match) (concat "id" (number-to-string num))))
    ""))

(defun hyperlatex-label-to-url (label node-number)
  "Generates the url for label LABEL in node NODE-NUMBER."
  (let ((match (assoc label hyperlatex-labels)))
    (if match
	(hyperlatex-gen-url (nth 2 match) (nth 1 match) node-number)
      (hyperlatex-warning "WARNING: Unknown label %s " label)
      label)))

(defun hyperlatex-drop-label (&optional no-meta-X)
  "Drop a label at the current position and return its number. Reuse last label
if there is one."
  (let ((meta-p-n (concat " \t\n" hyperlatex-meta-p hyperlatex-meta-n)))
    (if (save-excursion
	  (skip-chars-backward meta-p-n)
	  (= (preceding-char) hyperlatex-metachar-l))
	()
      ;; else make a new label at current position
      (insert hyperlatex-meta-< "a name=" hyperlatex-meta-dq
	      (hyperlatex-label-string hyperlatex-label-number
				       hyperlatex-node-number)
	      hyperlatex-meta-dq hyperlatex-meta->)
      (if no-meta-X
	  ()
	(insert hyperlatex-meta-X hyperlatex-meta-l))
      (setq hyperlatex-label-number (1+ hyperlatex-label-number)))
    (1- hyperlatex-label-number)))

(defun hyperlatex-format-label (&optional no-meta-X)
  "Creates a label at current position... But if we are directly behind
another label (or section heading), use previous label instead."
  (let ((label (hyperlatex-parse-evaluated-argument
		(concat "[\\\\" hyperlatex-meta-| "]")))
	(number (hyperlatex-drop-label no-meta-X)))
    (if hyperlatex-final-pass
	()
      (setq hyperlatex-labels
	    (cons (list label number hyperlatex-node-number
			hyperlatex-current-ref)
		  hyperlatex-labels))
      (if (and (string-match "^[a-zA-Z][a-zA-Z0-9\-\_\.\:]*$" label)
               ;; (if (and (string-match "^[a-zA-Z][a-zA-Z0-9_-.:]+$" label)
	       (not (string-match "^id[0-9]+$" label)))
	  ;; label is a legal URL and doesn't clash with internal numbers
	  (setq hyperlatex-label-strings
		(cons (cons (cons number hyperlatex-node-number)
			    label)
		      hyperlatex-label-strings))))))

(defun hyperlatex-format-Label ()
  "The `Label' environment surrounds a piece of text that becomes 
the anchor of the label."
  (hyperlatex-format-label t))

(defun hyperlatex-end-Label ()
  (hyperlatex-gen "/a"))

(defun hyperlatex-format-link-1 (is-url)
  (hyperlatex-starred-p)
  (let* ((text (hyperlatex-parse-required-argument))
	 (latex-text (hyperlatex-parse-optional-argument))
	 (url (if is-url
		  (hyperlatex-parse-required-argument)
		(if hyperlatex-final-pass
		    (hyperlatex-label-to-url
		     (hyperlatex-parse-evaluated-argument
		      (concat "[\\\\" hyperlatex-meta-| "]"))
		     hyperlatex-node-number)
		  ""))))
    (hyperlatex-gen (format hyperlatex-a-href-format
			    (hyperlatex-get-attributes "a")
			    url))
    (insert text)
    (hyperlatex-gen "/a")
    (goto-char hyperlatex-command-start)))

(defun hyperlatex-format-link ()
  (hyperlatex-format-link-1 nil))
  
(defun hyperlatex-format-xlink ()
  (hyperlatex-format-link-1 t))

(defun hyperlatex-format-htmlref ()
  (let ((deflt (hyperlatex-parse-optional-argument))
	(label (hyperlatex-parse-evaluated-argument
		(concat "[\\\\" hyperlatex-meta-| "]"))))
    (if hyperlatex-final-pass
	(let ((match (assoc label hyperlatex-labels)))
	  (if match
	      (let ((str (nth 3 match)))
		(if (string= str "")
		    (insert (if deflt deflt "X"))
		  (insert str)))
	    (hyperlatex-warning "WARNING: Unknown label %s " label)
	    label)))))

;;;
;;; ----------------------------------------------------------------------
;;;
;;; word breaking
;;;

(put 'mbox	  'hyperlatex	'hyperlatex-format-mbox)

(defun hyperlatex-format-mbox ()
  (let ((arg (hyperlatex-parse-required-argument)))
    (insert arg)
    (let ((end (point-marker)))
      (goto-char hyperlatex-command-start)
      (while (re-search-forward "[ \t\n]+" end t)
	(replace-match (concat hyperlatex-meta-& "nbsp;")))
      (goto-char hyperlatex-command-start)
      (set-marker end nil))))

;;;
;;; ----------------------------------------------------------------------
;;;
;;; The tabular environment
;;;

(put 'tabular	  'hyperlatex 'hyperlatex-format-tabular)
(put 'endtabular  'hyperlatex 'hyperlatex-end-tabular)
(put 'htmltab	  'hyperlatex 'hyperlatex-format-tab)
(put 'hline	  'hyperlatex 'hyperlatex-format-hline)
(put 'htmlcaption 'hyperlatex 'hyperlatex-format-htmlcaption)
(put 'multicolumn 'hyperlatex 'hyperlatex-format-multicolumn)
(put 'newcolumntype 'hyperlatex 'hyperlatex-format-newcolumntype)

;; RK's
(put 'beginsectionarg 'hyperlatex 'hyperlatex-format-beginsectionarg)
(put 'endsectionarg 'hyperlatex 'hyperlatex-format-endsectionarg)
(put 'endsectionassuch 'hyperlatex 'hyperlatex-format-endsectionassuch)
;;


(defun hyperlatex-tabular-posn (str)
  "Check the tabular column descriptor and generate a list of
align tags CENTER, LEFT, RIGHT."
  (let ((result nil)
	(prev nil))
    (while (not (string= str ""))
      (let ((chr (elt str 0)))
	(setq str (substring str 1))
	(cond
	 ((= chr ?>)
	  (let ((n (hyperlatex-tabular-parse-argument str chr)))
	    (setq prev (substring str 1 (1- n)))
	    (setq str (substring str n))))
	 ((= chr ?<)
	  (let* ((n (hyperlatex-tabular-parse-argument str chr))
		 (next (substring str 1 (1- n))))
	    (setq str (substring str n))
	    (setcdr (cdr (car result)) (list next))))
	 ((= chr ?l)
	  (setq result (cons (list "left" prev) result))
	  (setq prev nil))
	 ((= chr ?c)
	  (setq result (cons (list "center" prev) result))
	  (setq prev nil))
	 ((= chr ?r)
	  (setq result (cons (list "right" prev) result))
	  (setq prev nil))
	 (t
	  ;; look into user declared column types
	  (let* ((match (assoc chr hyperlatex-tabular-column-types))
		 (narg (elt match 1))
		 (arglist ())
		 (decl (elt match 2))
		 (hook (elt match 3)))
	    (if (not match)
		(error (format "unknown column type: %c" chr))
	      (if hook
		  (setq str (funcall hook str match))
		(while (> narg 0)
		  (let ((n (hyperlatex-tabular-parse-argument str chr)))
		    (setq arglist (cons (substring str 1 (1- n)) arglist))
		    (setq str (substring str n))
		    (setq narg (1- narg))
		    )
		  )
		(setq arglist (cons nil (nreverse arglist)))
		(while (string-match "##\\([1-9]\\)" decl)
		  (setq decl
			(replace-match
			 (elt arglist (string-to-number (match-string 1 decl)))
			 t t decl)))
		(setq str (concat decl str)))))))))
    (nreverse result)))

(defun hyperlatex-tabular-parse-argument (str help)
  (let ((chr (elt str 0))
	(lvl 1)
	(len 0))
    (if (not (= chr ?{)) ;}
	(error (format "tabular: argument required for %c" help))
      (setq str (substring str 1))
      (setq len (1+ len))
      (while (> lvl 0)
	(if (eq (string-match "^[^{}]*" str) 0)
	    (progn
	      (setq len (+ len (match-end 0)))
	      (setq str (substring str (match-end 0)))))
	(setq chr (elt str 0))
	(if (= chr ?{) ;}
	    (setq lvl (1+ lvl))
	  (setq lvl (1- lvl)))
	(setq str (substring str 1))
	(setq len (1+ len))))
    len))

(defun hyperlatex-format-tabular ()
  (hyperlatex-parse-optional-argument)
  (setq hyperlatex-tabular-column-descr
	(cons (cons 0 (hyperlatex-tabular-posn
		       (hyperlatex-parse-required-argument)))
	      hyperlatex-tabular-column-descr))
  (hyperlatex-format-endpar)
  (hyperlatex-blk)
  (hyperlatex-gen (hyperlatex-get-attributes "table"))
  (hyperlatex-gen (hyperlatex-get-attributes "tbody"))
  (hyperlatex-gen "tr")
  (hyperlatex-gen
   (format (concat "%s colspan=" hyperlatex-meta-dq "1" hyperlatex-meta-dq
		   " align=" hyperlatex-meta-dq "%s" hyperlatex-meta-dq)
	   (hyperlatex-get-attributes "td")
	   (hyperlatex-tabular-cell-align)) "\n")
  ;; put cell text into a group to restore attributes like \bf at its end
  (hyperlatex-begin-group)
  ;; put contents of >{...} in front of the cell
  (hyperlatex-tabular-cell-front))

(defun hyperlatex-end-tabular ()
  (hyperlatex-tabular-cell-end)
  (hyperlatex-end-group)
  (setq hyperlatex-tabular-column-descr
	(cdr hyperlatex-tabular-column-descr))
  (hyperlatex-blk)
  (hyperlatex-gen "/td")
  (hyperlatex-gen "/tr")
  (hyperlatex-gen "/tbody")
  (hyperlatex-gen "/table" "\n"))

(defun hyperlatex-format-tab ()
  (if (hyperlatex-in-stack 'tabular)
      ()
    (error "Used Tab character `&' outside of tabular environment."))
  (hyperlatex-tabular-cell-end)
  (hyperlatex-end-group)
  (hyperlatex-blk)
  (setcar (car hyperlatex-tabular-column-descr)
	  (1+ (car (car hyperlatex-tabular-column-descr))))
  (hyperlatex-gen "/td")
  (hyperlatex-gen
   (format (concat "%s colspan=" hyperlatex-meta-dq "1" hyperlatex-meta-dq
		     " align=" hyperlatex-meta-dq "%s" hyperlatex-meta-dq)
	   (hyperlatex-get-attributes "td")
	   (hyperlatex-tabular-cell-align)))
  (hyperlatex-begin-group)
  (hyperlatex-tabular-cell-front))

(defun hyperlatex-tabular-cell-align ()
  (car (nth (car (car hyperlatex-tabular-column-descr))
	    (cdr (car hyperlatex-tabular-column-descr)))))

(defun hyperlatex-tabular-cell-front ()
  (let ((decl (nth 1 (nth (car (car hyperlatex-tabular-column-descr))
			  (cdr (car hyperlatex-tabular-column-descr))))))
    (if decl
	(insert (hyperlatex-evaluate-string decl)))))

(defun hyperlatex-tabular-cell-end ()
  (let ((decl (nth 2 (nth (car (car hyperlatex-tabular-column-descr))
			  (cdr (car hyperlatex-tabular-column-descr))))))
    (if decl
	(insert (hyperlatex-evaluate-string decl)))))

(defun hyperlatex-format-tab-\\ ()
  (hyperlatex-tabular-cell-end)
  (hyperlatex-end-group)
  (hyperlatex-blk)
  (hyperlatex-gen "/td")
  (hyperlatex-gen "/tr" "\n")
  (setcar (car hyperlatex-tabular-column-descr) 0)
  (hyperlatex-gen "tr")
  (hyperlatex-gen
   (format (concat "%s colspan=" hyperlatex-meta-dq "1" hyperlatex-meta-dq
		   " align=" hyperlatex-meta-dq "%s" hyperlatex-meta-dq)
	   (hyperlatex-get-attributes "td")
	   (hyperlatex-tabular-cell-align)) "\n")
  (hyperlatex-begin-group)
  (hyperlatex-tabular-cell-front))

(defun hyperlatex-format-hline ()
  ())

(defun hyperlatex-format-htmlcaption ()
  (let ((caption (hyperlatex-parse-required-argument)))
    (search-backward (concat hyperlatex-meta-< "tr" hyperlatex-meta->))
    ;; Make sure we're not inside a tbody.
    (search-backward (concat hyperlatex-meta-< "tbody" hyperlatex-meta->)
		     (- (point) 25) t)
    (let ((here (point)))
      (hyperlatex-blk)
      (hyperlatex-gen (hyperlatex-get-attributes "caption"))
      (insert caption)
      (hyperlatex-blk)
      (hyperlatex-gen "/caption")
      (goto-char here))))

(defun hyperlatex-format-multicolumn ()
  (let* ((cols (hyperlatex-parse-required-argument))
	 (posn (car (hyperlatex-tabular-posn
		     (hyperlatex-parse-required-argument))))
	 (item (hyperlatex-parse-required-argument))
	 (here (point-marker)))
    (re-search-backward
     (concat "colspan=" hyperlatex-meta-dq "1" hyperlatex-meta-dq
	     " align=" hyperlatex-meta-dq "[A-Za-z]+" hyperlatex-meta-dq))
    (replace-match 
     (format (concat "colspan=" hyperlatex-meta-dq "%s" hyperlatex-meta-dq
		     " align=" hyperlatex-meta-dq "%s" hyperlatex-meta-dq)
	     cols (car posn)))
    (goto-char here)
    (if (nth 1 posn)
	(insert (nth 1 posn) "{}"))
    (insert item)
    (if (nth 2 posn)
	(insert (nth 2 posn) "{}"))
    (goto-char here)
    (set-marker here nil)))

(defun hyperlatex-format-newcolumntype ()
  (let* ((col (string-to-char (hyperlatex-parse-required-argument)))
	 (narg (hyperlatex-parse-optional-argument))
	 (decl (hyperlatex-parse-required-argument)))
    (setq narg (if narg (string-to-number narg) 0))
    (hyperlatex-tabular-add-columntype col narg decl)))

(defun hyperlatex-tabular-add-columntype (col narg decl &optional hook)
  (let* ((match (assoc col hyperlatex-tabular-column-types)))
    (if match
	(setcdr match (list narg decl hook))
      (setq hyperlatex-tabular-column-types
	    (cons (list col narg decl hook)
		  hyperlatex-tabular-column-types)))))

;;;
;;; ----------------------------------------------------------------------
;;;
;;; Tabbing environment
;;;

(put 'tabbing	  'hyperlatex 'hyperlatex-format-tabbing)
(put 'endtabbing  'hyperlatex 'hyperlatex-end-tabbing)
(put '>           'hyperlatex 'hyperlatex-format-tab-adv)
(put '=           'hyperlatex 'hyperlatex-format-tab-adv)
(put 'kill        'hyperlatex 'hyperlatex-format-kill)

(defun hyperlatex-format-tabbing ()
  (hyperlatex-format-endpar)
;; RK's
  (hyperlatex-mode-level-up)
;; end of RK's
  (hyperlatex-blk)
  (hyperlatex-gen "table cellspacing=\"1\" cellpadding=\"0\"")
  (hyperlatex-gen "tr" "\n")
  (hyperlatex-gen "td nowrap colspan=\"1\" align=\"left\""))

(defun hyperlatex-end-tabbing ()
  (hyperlatex-blk)
  (hyperlatex-adjust-colspan)
  (hyperlatex-gen "/td")
  (hyperlatex-gen "/tr")
  (hyperlatex-gen "/table" "\n")
;; RK's
  (hyperlatex-mode-level-up)
;; end of RK's
)

(defun hyperlatex-format-tab-adv ()
  (if (not (hyperlatex-in-stack 'tabbing))
      (error "Used `\\>' or `\\=' outside of tabbing environment."))
  (hyperlatex-blk)
  (hyperlatex-gen "/td")
  (hyperlatex-gen "td nowrap colspan=\"1\" align=\"left\""))

(defun hyperlatex-adjust-colspan ()
  (let ((here (point-marker)))
    (search-backward "td nowrap colspan=\"1\" align=\"left\"")
    (replace-match "td nowrap colspan=\"99\" align=\"left\"")
    (goto-char here)
    (set-marker here nil)))

(defun hyperlatex-format-tabbing-\\ ()
  (hyperlatex-adjust-colspan)
  (hyperlatex-gen "/td")
  (hyperlatex-gen "/tr" "\n")
  (hyperlatex-gen "tr" "\n")
  (hyperlatex-gen "td nowrap colspan=\"1\" align=\"left\""))

(defun hyperlatex-format-kill ()
  (let ((here (point-marker)))
    (re-search-backward(concat hyperlatex-meta-< "tr" hyperlatex-meta->))
    (delete-region (match-beginning 0) here))
  (hyperlatex-gen "tr" "\n")
  (hyperlatex-gen "td nowrap colspan=\"1\" align=\"left\""))

;;;
;;; ----------------------------------------------------------------------
;;;
;;; quotations, example's and verbatim environments
;;;

(put '\\	    'hyperlatex	'hyperlatex-format-\\)
(put 'example	    'hyperlatex	'hyperlatex-format-example)
(put 'endexample    'hyperlatex	'hyperlatex-end-recursion)
(put 'verbatim	    'hyperlatex	'hyperlatex-format-verbatim)
(put 'endverbatim   'hyperlatex	'hyperlatex-end-verbatim)
(put 'verb	    'hyperlatex	'hyperlatex-format-verb)

(defvar hyperlatex-verbatim-need-pars nil "If paragraphs are already suspended, then they don't need to be suspended again.  This flag is used to signal to the verbatim-end function that once is enough.")

(defun hyperlatex-end-recursion ()
  (setq hyperlatex-continue-scan hyperlatex-example-depth))

(defun hyperlatex-format-\\ ()
  "Insert a <BR> tag, except in example, where it does nothing,
and in tabular, where it does something else."
  (hyperlatex-starred-p)
  (hyperlatex-parse-optional-argument)
  (if hyperlatex-active-space
      ()
    (if (hyperlatex-in-stack 'tabular)
	(hyperlatex-format-tab-\\)
      (if (hyperlatex-in-stack 'tabbing)
	  (hyperlatex-format-tabbing-\\)
	(hyperlatex-gen "br /")))))
  
(defun hyperlatex-format-example ()
  (hyperlatex-format-endpar)
;; RK's
  (hyperlatex-mode-level-up "example")
;;
  (if hyperlatex-in-body 
      (progn
	(hyperlatex-format-suspendpars)
	(setq hyperlatex-verbatim-need-pars t))
    (setq hyperlatex-verbatim-need-pars nil))
  (hyperlatex-blk)
  (hyperlatex-gen "pre")
  (let ((hyperlatex-special-chars-regexp
	 (concat "[\\\\{}%" hyperlatex-meta-| "]"))
	(hyperlatex-example-depth hyperlatex-recursion-depth)
	(hyperlatex-active-space t))
    ;; recursive call returns after processing \end{example}
    (hyperlatex-format-region (point) (point-max) t))
  (goto-char hyperlatex-command-start)
;  (hyperlatex-delete-whitespace)
  (hyperlatex-gen "/pre")
;; RK's
  (hyperlatex-mode-level-down "example")
;;
  (if hyperlatex-verbatim-need-pars
      (hyperlatex-format-resumepars)))


(defun hyperlatex-format-verb ()
  "Handle the LaTeX \\verb command."
  (hyperlatex-delete-|)
  (hyperlatex-gen "code")
  (let ((the-char (following-char)))
    (delete-char 1)
    (hyperlatex-delete-|)
    (search-forward (char-to-string the-char))
    (delete-char -1))
  (hyperlatex-gen "/code"))

(defun hyperlatex-format-verbatim ()
  (hyperlatex-format-endpar)
;; RK's
  (hyperlatex-mode-level-up)
;; end-of-RK's
  (if hyperlatex-in-body 
      (progn
	(hyperlatex-format-suspendpars)
	(setq hyperlatex-verbatim-need-pars t))
    (setq hyperlatex-verbatim-need-pars nil))
  (hyperlatex-delete-|)
  (let ((env-name (symbol-name (car hyperlatex-stack))))
    (hyperlatex-blk)
    (hyperlatex-gen "pre")
    (search-forward  (concat "\\end{" env-name "}"))
    (goto-char (match-beginning 0))))

(defun hyperlatex-end-verbatim ()
  (hyperlatex-gen "/pre")
;; RK's
  (hyperlatex-mode-level-down "verbatim")
;; end-of-RK's
  (if hyperlatex-verbatim-need-pars
      (hyperlatex-format-resumepars)))

;;;
;;; ----------------------------------------------------------------------
;;;
;;; Some little macros
;;;

(put 'back	'hyperlatex 'hyperlatex-format-backslash)
(put 'textsc	'hyperlatex 'hyperlatex-format-textsc)
(put 'protect	'hyperlatex 'hyperlatex-format-ignore)
(put 'noindent	'hyperlatex 'hyperlatex-format-ignore)
(put 'xspace	'hyperlatex 'hyperlatex-format-xspace)

(defun hyperlatex-format-backslash ()
  "replace \\back by \\"
  (insert "\\"))

(defun hyperlatex-format-textsc ()
  (insert (upcase (hyperlatex-parse-required-argument)))
  (goto-char hyperlatex-command-start))

(defun hyperlatex-format-xspace ()
  (hyperlatex-delete-|)
  (hyperlatex-delete-whitespace)
  (if (looking-at "[{}/ ~.,:;^_?')-]")
      ()
    (insert " ")))

;;;
;;; ----------------------------------------------------------------------
;;;
;;; Math mode
;;;

(put 'math		'hyperlatex 'hyperlatex-format-math)
(put (intern "(")	'hyperlatex 'hyperlatex-math-on)
(put (intern ")")	'hyperlatex 'hyperlatex-math-off)
(put 'sqrt		'hyperlatex 'hyperlatex-format-sqrt)
(put 'htmlmathitalic	'hyperlatex 'hyperlatex-format-mathitalic)

(defun hyperlatex-format-mathitalic ()
  (setq hyperlatex-math-italic
	(string= (hyperlatex-parse-required-argument) "1")))

(defun hyperlatex-math-mode ()
  (if hyperlatex-math-mode (hyperlatex-math-off) (hyperlatex-math-on)))

(defun hyperlatex-math-on ()
  (if hyperlatex-math-mode
      ()
;; RK's
    (hyperlatex-enter-par)
;;    
    (if hyperlatex-math-italic (hyperlatex-gen "i")))
  (setq hyperlatex-math-mode t))

(defun hyperlatex-math-off ()
  (if (not hyperlatex-math-mode)
      ()
    (if hyperlatex-math-italic (hyperlatex-gen "/i")))
  (setq hyperlatex-math-mode nil))

(defun hyperlatex-subscript ()
  (hyperlatex-sub-super "sub" "_"))

(defun hyperlatex-superscript ()
  (hyperlatex-sub-super "sup" "^"))

(defun hyperlatex-sub-super (where char)
  (if (null hyperlatex-math-mode)
      (insert char)
    (setq hyperlatex-command-start (point))
    (let ((arg (hyperlatex-parse-required-argument))
	  (here (point)))
      (hyperlatex-gen where)
      (insert arg)
      (hyperlatex-gen (concat "/" where))
      (goto-char here))))

(defun hyperlatex-format-math ()
  "Format \\math{} and \\math[]{}."
  (if hyperlatex-math-mode
      (error "Cannot use \\math in math mode!"))
  (let ((opt (hyperlatex-parse-optional-argument))
	(req (hyperlatex-parse-required-argument)))
    (hyperlatex-math-on)
    (insert (if opt opt req))
    (hyperlatex-format-region hyperlatex-command-start (point))
    (hyperlatex-math-off)))

(defun hyperlatex-format-sqrt ()
  (let ((opt (hyperlatex-parse-optional-argument))
	(req (hyperlatex-parse-required-argument)))
    (insert
     (if opt
	 (format "\\htmlroot{%s}{%s}" opt req)
       (format "\\htmlsqrt{%s}" req)))
    (goto-char hyperlatex-command-start)))

;;;
;;; ----------------------------------------------------------------------
;;;
;;; Index generation
;;;

(put 'index		'hyperlatex 'hyperlatex-format-index)
(put 'cindex		'hyperlatex 'hyperlatex-format-index)
(put 'htmlprintindex	'hyperlatex 'hyperlatex-format-printindex)

(defun hyperlatex-single-line (str)
  "Replaces newlines in STRING by spaces."
  (if str
      (let ((mystr (copy-sequence str)))
	(while (string-match "\n" mystr)
	  (aset mystr (string-match "\n" mystr) 32))
	mystr)
    nil))
  
(defun hyperlatex-format-index ()
  "Adds an index entry."
  (let ((opt (hyperlatex-single-line (hyperlatex-parse-optional-argument)))
	(arg (hyperlatex-single-line (hyperlatex-parse-required-argument)))
	(label (hyperlatex-drop-label)))
    (if hyperlatex-final-pass
	()
      (if (string-match "^\\(.*\\)@\\(.*\\)$" arg)
	  (progn
	    (setq opt (substring arg (match-beginning 1) (match-end 1)))
	    (setq arg (substring arg (match-beginning 2) (match-end 2)))))
      (setq hyperlatex-index
	    (cons (list (if opt opt arg) arg hyperlatex-node-number label)
		  hyperlatex-index)))))

(defun hyperlatex-format-printindex ()
  (if (not hyperlatex-final-pass)
      ()
    (setq hyperlatex-index
	  (sort hyperlatex-index
		(function
		 (lambda (a b)
		   (string< (upcase (car a))
			    (upcase (car b)))))))
    (insert "\\begin{theindex}\n")
    (let ((indexelts hyperlatex-index))
      (while indexelts
	(insert (format "\\item\\xlink{%s}{%s}\n"
			(nth 1 (car indexelts))
			(hyperlatex-gen-url (nth 2 (car indexelts))
					    (nth 3 (car indexelts)))))
	(setq indexelts (cdr indexelts))))
    (insert "\\end{theindex}\n")
    (goto-char hyperlatex-command-start)))
  
;;;
;;; ----------------------------------------------------------------------
;;;
;;; iftex, ifhtml, tex, ifset, ifclear
;;;

(put 'ifset      'hyperlatex 'hyperlatex-if-set)
(put 'endifset   'hyperlatex 'hyperlatex-format-ignore)
(put 'ifclear    'hyperlatex 'hyperlatex-if-clear)
(put 'endifclear 'hyperlatex 'hyperlatex-format-ignore)
(put 'ifoption   'hyperlatex 'hyperlatex-if-option)
(put 'endifoption 'hyperlatex 'hyperlatex-format-ignore)
(put 'ifequal    'hyperlatex 'hyperlatex-if-equal)
(put 'endifequal 'hyperlatex 'hyperlatex-format-ignore)
(put 'ifhtml     'hyperlatex 'hyperlatex-format-ignore)
(put 'endifhtml  'hyperlatex 'hyperlatex-format-ignore)
(put 'comment    'hyperlatex 'hyperlatex-format-comment)
(put 'iftex      'hyperlatex 'hyperlatex-format-iftex)
(put 'tex        'hyperlatex 'hyperlatex-format-tex)
(put 'latexonly  'hyperlatex 'hyperlatex-format-latexonly)
(put 'HlxSkip	 'hyperlatex 'hyperlatex-format-hlxskip)

(defun hyperlatex-format-hlxskip ()
  (let ((str (hyperlatex-parse-required-argument)))
    (delete-region hyperlatex-command-start
		   (progn (search-forward str)
			  (match-beginning 0)))))

(defun hyperlatex-ifset-flag ()
  (let* ((arg (hyperlatex-parse-required-argument))
	 (match (assoc arg hyperlatex-new-commands)))
    (if (null match)
	nil
      (let ((expansion (car (cdr (cdr match)))))
	(and (not (string= expansion ""))
	     (not (string= expansion "0")))))))

(defun hyperlatex-if-set ()
  "If set, continue formatting; else do not format region up to \\end{ifset}"
  (if (hyperlatex-ifset-flag)
      ;; flag is set, don't do anything
      () 
    (delete-region hyperlatex-command-start
		   (progn (search-forward "\\end{ifset}") (point)))
    (hyperlatex-delete-whitespace)
    (hyperlatex-pop-stacks)))

(defun hyperlatex-if-clear ()
  "If clear, continue formatting; else do not format region up
 to \\end{ifclear}."
  (if (not (hyperlatex-ifset-flag))
      ;; flag is clear, don't do anything
      () 
    (delete-region hyperlatex-command-start
		   (progn (search-forward "\\end{ifclear}") (point)))
    (hyperlatex-delete-whitespace)
    (hyperlatex-pop-stacks)))

(defun hyperlatex-if-equal ()
  (let ((arg1 (hyperlatex-parse-evaluated-argument
	       (concat "[\\\\" hyperlatex-meta-| "]")))
	(arg2 (hyperlatex-parse-evaluated-argument
	       (concat "[\\\\" hyperlatex-meta-| "]"))))
    (if (string= arg1 arg2)
	;; process environment
	()
      ;; else skip it
      (delete-region hyperlatex-command-start
		     (progn (search-forward "\\end{ifequal}") (point)))
      (hyperlatex-delete-whitespace)
      (hyperlatex-pop-stacks))))

(defun hyperlatex-if-option ()
  (let ((arg1 (hyperlatex-parse-evaluated-argument
	       (concat "[\\\\" hyperlatex-meta-| "]"))))
    (if (or (and (string= arg1 "")
	      (not hyperlatex-document-options)
	      (not hyperlatex-options))
	  (member arg1 hyperlatex-document-options)
	  (member arg1 hyperlatex-options))
	;; process environment
	()
      ;; else skip it
      (delete-region hyperlatex-command-start
		     (progn (search-forward "\\end{ifoption}") (point)))
      (hyperlatex-delete-whitespace)
      (hyperlatex-pop-stacks))))

(defun hyperlatex-format-iftex ()
  (hyperlatex-format-iftex-1 "\\end{iftex}"))

(defun hyperlatex-format-tex ()
  (hyperlatex-format-iftex-1 "\\end{tex}"))

(defun hyperlatex-format-latexonly ()
  (hyperlatex-format-iftex-1 "\\end{latexonly}"))

(defun hyperlatex-format-comment ()
  (hyperlatex-format-iftex-1 "\\end{comment}"))

(defun hyperlatex-format-iftex-1 (str)
  (delete-region hyperlatex-command-start
		 (progn (search-forward str) (point)))
  (hyperlatex-delete-whitespace)
  (hyperlatex-pop-stacks))

;;;
;;; ----------------------------------------------------------------------
;;;
;;; Footnotes
;;;

(put 'footnote		'hyperlatex 'hyperlatex-format-footnote)
(put 'htmlfootnotes	'hyperlatex 'hyperlatex-format-htmlfootnotes)

(defun hyperlatex-format-footnote ()
  (let ((fn (hyperlatex-parse-required-argument)))
    (setq hyperlatex-footnote-number (1+ hyperlatex-footnote-number))
    (setq hyperlatex-footnotes (cons fn hyperlatex-footnotes))
    (insert (format "\\htmlfootnotemark{%d}" hyperlatex-footnote-number))
    (goto-char hyperlatex-command-start)))

(defun hyperlatex-format-htmlfootnotes ()
  (if (null hyperlatex-footnotes)
      ()
    (let ((here (point))
	  (fn (nreverse hyperlatex-footnotes))
	  (num 1))
      (insert "\n\\begin{thefootnotes}\n")
      (while fn
	(insert (format "\\htmlfootnoteitem{%d}{%s}\n" num (car fn)))
	(setq num (1+ num))
	(setq fn (cdr fn)))
      (insert "\\end{thefootnotes}\n")
      (setq hyperlatex-footnotes nil)
      (goto-char here))))
      
;;;
;;; ----------------------------------------------------------------------
;;;
;;; Bibliography support, for included .bbl files
;;;

(put 'bibliography	'hyperlatex 'hyperlatex-format-bibliography)
(put 'bibitem		'hyperlatex 'hyperlatex-format-bibitem)
(put 'Hlxcite		'hyperlatex 'hyperlatex-format-hlxcite)
(put 'bibliographystyle 'hyperlatex 'hyperlatex-parse-required-argument)

(defun hyperlatex-format-bibliography ()
  (let* ((tex-name (buffer-file-name hyperlatex-input-buffer))
	 (base-name (progn
		      (if (string-match "^.*\\(\\.[a-zA-Z0-9]+\\)$" tex-name)
			  (substring tex-name 0 (match-beginning 1))
			tex-name)))
	 (hyperlatex-bbl-filename (concat base-name ".bbl")))
    (hyperlatex-parse-required-argument)
    (if (file-exists-p hyperlatex-bbl-filename)
	(progn
	  (hyperlatex-insert-file hyperlatex-bbl-filename)
	  (goto-char hyperlatex-command-start))
      (hyperlatex-message "Formatted bibliography file not found: %s"
	       hyperlatex-bbl-filename))))

(defun hyperlatex-format-bibitem ()
  (let ((mnemonic (hyperlatex-parse-optional-argument))
	(label (hyperlatex-parse-required-argument)))
    (setq hyperlatex-bibitem-number (1+ hyperlatex-bibitem-number))
    (if mnemonic
	()
      (setq mnemonic (int-to-string hyperlatex-bibitem-number)))
    (insert (format "\\htmlbibitem{%s}{%s}" mnemonic label))
    (if hyperlatex-final-pass
	()
      (setq hyperlatex-cite-names
	    (cons (cons label mnemonic) hyperlatex-cite-names)))
    (goto-char hyperlatex-command-start)))

(defun hyperlatex-format-hlxcite ()
  (let ((optarg (hyperlatex-parse-optional-argument))
        (label (hyperlatex-parse-required-argument)))
    (if hyperlatex-final-pass
        (let ((match (assoc label hyperlatex-cite-names)))
          (if (null match)
              (hyperlatex-warning "WARNING: Unknown cite key %s" label)
            (insert (cdr match))
	    (if (not (string= "" optarg))
		(insert ", " optarg))
            (goto-char hyperlatex-command-start))))))

;;;
;;; ----------------------------------------------------------------------
;;;
;;; Direct XML --- \xml, \xmlent, bitmaps etc.
;;;

(put 'xml		'hyperlatex 'hyperlatex-format-xml)
(put 'xmlent		'hyperlatex 'hyperlatex-format-xmlent)
(put 'rawxml		'hyperlatex 'hyperlatex-format-rawxml)
(put 'xmlinclude	'hyperlatex 'hyperlatex-format-xmlinclude)
(put 'htmlimg		'hyperlatex 'hyperlatex-format-img)
(put 'gif		'hyperlatex 'hyperlatex-format-gif)
(put 'image     	'hyperlatex 'hyperlatex-format-image)
(put 'xmlattributes	'hyperlatex 'hyperlatex-format-xmlattributes)

;;;
;;; \xml{TAG attr}  --> <TAG attr>
;;; \xml*{TAG attr}  --> <TAG attr>
;;; The non-starred version does lookup in xmlattributes
;;;

(defun hyperlatex-format-xml ()
  (let ((starp (hyperlatex-starred-p))
	(arg (hyperlatex-parse-required-argument)))
    (string-match "^\\([^ ]*\\)\\( \\|$\\)" arg)
    (if starp
	(hyperlatex-gen arg)
      (let ((tag (substring arg 0 (match-end 1)))
	    (attr (substring arg (match-beginning 2))))
	(hyperlatex-gen (concat (hyperlatex-get-attributes tag) attr))))))

(defun hyperlatex-format-xmlent ()
  (let ((arg (hyperlatex-parse-required-argument)))
    (hyperlatex-gensym arg)))

(defun hyperlatex-format-rawxml ()
  (search-forward "\\end{rawxml}")
  (goto-char (match-beginning 0))
  (replace-match "")
  (let ((end (point-marker)))
    (goto-char hyperlatex-command-start)
    (while (re-search-forward "[<>&]" end t)
      (replace-match
       (char-to-string (+ (preceding-char) hyperlatex-meta-offset))))
    (goto-char end)
    (set-marker end nil)
    (hyperlatex-delete-whitespace)
    (hyperlatex-pop-stacks)))

(defun hyperlatex-format-xmlinclude ()
  (let ((file-name (hyperlatex-parse-required-argument)))
    (hyperlatex-message "Inserting XML file %s..." file-name)
    (let ((beginning-of-include (point))
	  (text-length (cadr (insert-file-contents file-name))))
      (save-restriction
	(narrow-to-region beginning-of-include 
			  (+ beginning-of-include text-length))
	(while (re-search-forward "[<>&]" nil t)
	  (replace-match
	   (char-to-string (+ (preceding-char) hyperlatex-meta-offset))))
	(goto-char (point-max)))
      (hyperlatex-message "Inserting XML file %s...done" file-name))))


(defun hyperlatex-format-img ()
  (let ((url (hyperlatex-parse-required-argument))
	(alt (hyperlatex-purify (hyperlatex-parse-evaluated-argument
				 hyperlatex-special-chars-regexp))))
    (hyperlatex-gen (concat (hyperlatex-get-attributes "img")
			    " alt=" hyperlatex-meta-dq
			    alt hyperlatex-meta-dq 
			    " src=" hyperlatex-meta-dq 
			    url hyperlatex-meta-dq "/"))
    (goto-char hyperlatex-command-start)))

(defun hyperlatex-format-gif ()
  (let* ((opt (hyperlatex-parse-optional-argument))
	 (tags (if opt opt ""))
	 (resolution (hyperlatex-parse-optional-argument))
	 (dpi (hyperlatex-parse-optional-argument))
	 (url (hyperlatex-parse-required-argument))
         (hyperlatex-imagetype "gif"))
    (delete-region hyperlatex-command-start
		   (progn (search-forward "\\end{gif}") (point)))
    (hyperlatex-delete-whitespace)
    (hyperlatex-pop-stacks)
    (hyperlatex-gen
     (format (concat "img src=" hyperlatex-meta-dq "%s." 
                     hyperlatex-imagetype hyperlatex-meta-dq " %s /")
	     url tags))))

(defun hyperlatex-format-image ()
  (let* ((opt (hyperlatex-parse-optional-argument))
	 (tags (if opt opt ""))
	 (resolution (hyperlatex-parse-optional-argument))
	 (dpi (hyperlatex-parse-optional-argument))
	 (url (hyperlatex-parse-required-argument)))
    (delete-region hyperlatex-command-start
		   (progn (search-forward "\\end{image}") (point)))
    (hyperlatex-delete-whitespace)
    (hyperlatex-pop-stacks)
    (hyperlatex-gen
     (format (concat "img src=" hyperlatex-meta-dq "%s." 
                     hyperlatex-imagetype hyperlatex-meta-dq " %s /")
	     url tags))))

(defun hyperlatex-format-xmlattributes ()
  (let* ((starp (hyperlatex-starred-p))
	 (tag (hyperlatex-parse-required-argument))
	 (attr (hyperlatex-parse-required-argument))
	 (match (assoc tag hyperlatex-attributes)))
    ;; Remove literal quotes and replace with magic quotes.
    (let ((marker 0))
      (while (string-match "\"" attr marker)
	(setq attr (replace-match hyperlatex-meta-dq t t attr))
	(setq marker (match-end 0))))
    (if (or (null match)
	    starp)
	(setq hyperlatex-attributes
	      (cons (list tag starp attr)
		    hyperlatex-attributes))
      (setcdr match (list starp attr)))))

(defun hyperlatex-get-attributes (tag)
  (let ((match (assoc tag hyperlatex-attributes)))
    (if (null match)
	tag
      (let ((remove (nth 1 match))
	    (atr (nth 2 match)))
	(if remove
	    (setq hyperlatex-attributes
		  (delq match hyperlatex-attributes)))
	(if (string= atr "")
	    tag
	  (concat tag " " atr))))))

;;;
;;; ----------------------------------------------------------------------
;;;
;;; Commands in the preamble
;;;

(put 'documentclass	'hyperlatex 'hyperlatex-format-documentclass)
(put 'documentstyle	'hyperlatex 'hyperlatex-format-documentclass)
(put 'usepackage	'hyperlatex 'hyperlatex-format-usepackage)
(put 'htmltitle		'hyperlatex 'hyperlatex-format-htmltitle)
(put 'htmldirectory	'hyperlatex 'hyperlatex-format-htmldirectory)
(put 'htmlname		'hyperlatex 'hyperlatex-format-htmlname)
(put 'imagetype         'hyperlatex 'hyperlatex-format-imagetype)
(put 'NotSpecial	'hyperlatex 'hyperlatex-format-notspecial)
(put 'HlxOptions	'hyperlatex 'hyperlatex-format-hlxoptions)
(put 'htmltopname	'hyperlatex 'hyperlatex-format-htmltopname)

(put 'document		'hyperlatex 'hyperlatex-format-document)
(put 'enddocument	'hyperlatex 'hyperlatex-end-document)

(defun hyperlatex-format-documentclass ()
  (setq hyperlatex-document-options (hyperlatex-parse-optional-arguments))
  (let ((class (hyperlatex-parse-required-argument)))
    (hyperlatex-package "siteinit")
    (hyperlatex-package "init")
    (hyperlatex-package class))
  (goto-char hyperlatex-command-start))

(defun hyperlatex-format-usepackage ()
  (setq hyperlatex-options (hyperlatex-parse-optional-arguments))
  (let ((package (hyperlatex-parse-required-argument)))
    (cond ((string= package "hyperlatex")
	   (if hyperlatex-options
	       (mapcar (function (lambda (pkg) (hyperlatex-package pkg)))
		 hyperlatex-options)))
	  ((memq (intern package) hyperlatex-known-packages))
	  (t
	   (hyperlatex-package package)))
    (goto-char hyperlatex-command-start)))

(defun hyperlatex-format-hlxoptions ()
  (if (and hyperlatex-options (not (cdr hyperlatex-options)))
      (insert (car hyperlatex-options))
    (error "backward compatibility: \\HlxOptions cannot be used with more than one package option")))

(defun hyperlatex-format-htmltitle ()
  (setq hyperlatex-title
	(hyperlatex-parse-evaluated-argument
	 (concat "[\\\\%{}" hyperlatex-meta-| "]"))))

(defun hyperlatex-format-htmldirectory ()
  (setq hyperlatex-html-directory (hyperlatex-parse-required-argument))
  (if (not (file-exists-p hyperlatex-html-directory))
      (progn
	(hyperlatex-message "Making directory %s" hyperlatex-html-directory)
	(make-directory hyperlatex-html-directory t))))

(defun hyperlatex-format-htmlname ()
  (setq hyperlatex-basename (hyperlatex-parse-required-argument)))

(defun hyperlatex-format-imagetype ()
  (setq hyperlatex-imagetype (hyperlatex-parse-required-argument)))

(defun hyperlatex-format-notspecial ()
  (let ((str (hyperlatex-parse-required-argument)))
    (setq hyperlatex-special-characters
	  (concat 
	   (if (string-match "\\\\do\\\\~" str) "" "~")
	   (if (string-match "\\\\do\\\\\\$" str) "" "$")
	   (if (string-match "\\\\do\\\\\\^" str) "" "^")
	   (if (string-match "\\\\do\\\\_" str) "" "_")
	   (if (string-match "\\\\do\\\\&" str) "" "&")))
    (hyperlatex-update-special-chars)))

(defun hyperlatex-format-htmltopname ()
  (setq hyperlatex-topnode-name (hyperlatex-parse-required-argument)))

(defun hyperlatex-format-document ()
  "Begin document environment."
;; RK's
  (setq hyperlatex-in-b t)
  (setq hyperlatex-mode-stack nil)
  (hyperlatex-mode-level-up "document")
;; end of RK's
  (hyperlatex-message "Title of work is \"%s\"" hyperlatex-title)
  (hyperlatex-message "Using filename \"%s/%s%s\"" hyperlatex-html-directory
	   hyperlatex-basename (hyperlatex-html-ext))
  (setcar hyperlatex-group-stack "\\htmlfootnotes{}\\HlxFramesNavigation{}")
  (setq hyperlatex-node-number 0)
  (setq hyperlatex-sect-number 0)
  (setq hyperlatex-menu-in-section nil)
  (setq hyperlatex-in-paragraph nil) ;; added pf
  (delete-region (point-min) (point))
  ;; check for XML mode
  (setq hyperlatex-xml (assoc "HlxXmlIntro" hyperlatex-new-commands))
  ;; verify whether or not frames are enabled (not in XML mode)
  (if hyperlatex-xml
      (setq hyperlatex-making-frames nil)
    (setq hyperlatex-making-frames (assoc "HlxFramesDescription"
					  hyperlatex-new-commands))
    (if (and hyperlatex-making-frames
	     hyperlatex-final-pass)
	(hyperlatex-make-frames-headers)))
  ;; start with top node
  (hyperlatex-make-node-header nil)
  (if hyperlatex-final-pass
      ()
    (setq hyperlatex-sections
	  (cons (list 0 0 hyperlatex-topnode-name 0 0) hyperlatex-sections))))

(defun hyperlatex-end-document ()
  (delete-region (point) (point-max))
  (hyperlatex-finish-node)
;; RK's
  (hyperlatex-mode-level-down "document"))
;;

(defun hyperlatex-package (package)
  "Find support for a Latex package and load it.
For Latex package PACKAGE, look for `PACKAGE.hlx' in the directories in 
`hyperlatex-extension-dirs', and insert it if found."
  (let ((file-coding-system-for-read '*iso-8859-1*)
	(fname (hyperlatex-search-file (concat package ".hlx"))))
    (if (not fname)
	(hyperlatex-message "Package \"%s\" not found..." package)
      (goto-char (+ (point)
		    (car (cdr (insert-file-contents-literally fname)))))
      (hyperlatex-message "Package \"%s\" inserted" package))))

(defun hyperlatex-search-file (fname)
  "Search for FILE in `hyperlatex-extension-dirs' and return absolute
filename if found."
  (if (file-name-absolute-p fname)
      fname
    (catch 'found
      (mapcar
       (function (lambda (x)
		   (let ((f (expand-file-name (concat x fname))))
		     (if (file-readable-p f)
			 (throw 'found f)))))
       hyperlatex-extension-dirs)
      nil)))

;;; ----------------------------------------------------------------------
;;;
;;; Counters
;;;

(put 'newcounter	'hyperlatex 'hyperlatex-format-newcounter)
(put 'setcounter	'hyperlatex 'hyperlatex-format-setcounter)
(put 'addtocounter	'hyperlatex 'hyperlatex-format-addtocounter)
(put 'stepcounter	'hyperlatex 'hyperlatex-format-stepcounter)
(put 'refstepcounter	'hyperlatex 'hyperlatex-format-refstepcounter)
(put 'arabic		'hyperlatex 'hyperlatex-format-arabic)
(put 'value		'hyperlatex 'hyperlatex-format-arabic)
(put 'alph		'hyperlatex 'hyperlatex-format-alph)
(put 'Alph		'hyperlatex 'hyperlatex-format-Alph)
(put 'newtheorem	'hyperlatex 'hyperlatex-format-newtheorem)

(defun hyperlatex-stepcounter (counter)
  "Step the COUNTER."
  (let* ((match  (assoc counter hyperlatex-counters)))
    (if (null match)
	(error "Unknown counter %s" counter)
      (setcar (cdr match) (1+ (car (cdr match))))
      (let ((within (cdr (cdr match))))
	(while within
	  (hyperlatex-setcounter (car within) 0)
	  (setq within (cdr within)))))))

(defun hyperlatex-refstepcounter (counter)
  "Refstep the COUNTER."
  (hyperlatex-stepcounter counter)
  (setq hyperlatex-current-ref
	(hyperlatex-evaluate-string (concat "\\the" counter))))

(defun hyperlatex-setcounter (counter value)
  "Set the COUNTER to VALUE."
  (let* ((match  (assoc counter hyperlatex-counters)))
    (if (null match)
	(error "Unknown counter %s" counter)
      (setcar (cdr match) value))))

(defun hyperlatex-counter-value (counter)
  "Return the value of COUNTER."
  (let* ((match  (assoc counter hyperlatex-counters)))
    (if (null match)
	(error "Unknown counter %s" counter)
      (car (cdr match)))))

(defun hyperlatex-format-newcounter ()
  "\\newcounter{counter}"
  (let ((counter (hyperlatex-parse-required-argument))
	(within  (hyperlatex-parse-optional-argument)))
    (setq hyperlatex-counters
	  (cons (list counter 0) hyperlatex-counters))
    (if within
	(let ((match (assoc within hyperlatex-counters)))
	  (if (null match)
	      (error "Unknown counter %s" within)
	    (setcdr (cdr match) (cons counter (cdr (cdr match)))))))
    (hyperlatex-define-macro (concat "the" counter) 0
			     (concat "\\arabic{" counter "}")
			     "")))

(defun hyperlatex-format-setcounter ()
  "\\setcounter{counter}{value}"
  (let ((counter (hyperlatex-parse-required-argument))
	(value  (string-to-int (hyperlatex-parse-evaluated-argument
				hyperlatex-special-chars-regexp))))
    (hyperlatex-setcounter counter value)))

(defun hyperlatex-format-stepcounter ()
  "\\stepcounter{counter}"
  (let ((counter (hyperlatex-parse-required-argument)))
    (hyperlatex-stepcounter counter)))

(defun hyperlatex-format-refstepcounter ()
  "\\refstepcounter{counter}"
  (let ((counter (hyperlatex-parse-required-argument)))
    (hyperlatex-refstepcounter counter)))

(defun hyperlatex-format-addtocounter ()
  "\\addtocounter{counter}{value}"
  (let ((counter (hyperlatex-parse-required-argument))
	(value  (string-to-int (hyperlatex-parse-evaluated-argument
				hyperlatex-special-chars-regexp))))
    (hyperlatex-setcounter counter (+ (hyperlatex-counter-value counter)
				      value))))

(defun hyperlatex-format-arabic ()
  "\\arabic{counter}"
  (let ((counter (hyperlatex-parse-required-argument)))
    (insert (int-to-string (hyperlatex-counter-value counter)))))

(defun hyperlatex-format-alph ()
  "\\alph{counter}"
  (let ((counter (hyperlatex-parse-required-argument)))
    (insert (char-to-string (+ ?a (1- (hyperlatex-counter-value counter)))))))

(defun hyperlatex-format-Alph ()
  "\\Alph{counter}"
  (let ((counter (hyperlatex-parse-required-argument)))
    (insert (char-to-string (+ ?A (1- (hyperlatex-counter-value counter)))))))

(defun hyperlatex-format-newtheorem ()
  (let ((env (hyperlatex-parse-required-argument))
	(counter (hyperlatex-parse-optional-argument))
	(head (hyperlatex-parse-required-argument))
	(within (hyperlatex-parse-optional-argument)))
    (if (null counter)
	()
      (insert "\\newcounter{" counter "}")
      (if within
	  (insert "[" within "]")))
    (insert "\\Hlxnewtheorem{" env "}{" head "}{"
	    (if counter counter env) "}")
    (goto-char hyperlatex-command-start)))
    
;;; ----------------------------------------------------------------------
;;;
;;; Commands meant for the *.hlx files
;;;

(put 'HlxEval		'hyperlatex 'hyperlatex-format-hlxeval)
(put 'htmlaccent	'hyperlatex 'hyperlatex-format-htmlaccent)
(put 'HlxAccent		'hyperlatex 'hyperlatex-format-hlxaccent)
(put 'EmptyP		'hyperlatex 'hyperlatex-format-emptyp)
(put 'HlxError		'hyperlatex 'hyperlatex-format-error)
(put 'typeout		'hyperlatex 'hyperlatex-format-typeout)
(put 'HlxSplit		'hyperlatex 'hyperlatex-format-hlxsplit)

(defun hyperlatex-format-hlxsplit ()
  "\\HlxSplit{arg}{regexp}{command}."
  (let ((arg (hyperlatex-parse-required-argument))
	(regexp (hyperlatex-parse-required-argument))
	(com (hyperlatex-parse-required-argument))
	(end (point-marker)))
    (insert-before-markers "\\" com "{")
    (let ((start (point)))
      (insert-before-markers arg)
      (goto-char start)
      (while (re-search-forward regexp end t)
	(replace-match (concat "}\\\\" com "{")))
      (goto-char end)
      (insert "}")
      (set-marker end nil))
    (goto-char hyperlatex-command-start)))

(defun hyperlatex-format-hlxeval ()
  "\\HlxEval{expr} evaluates the expression."
  (let ((begin (point))
	(expr (hyperlatex-parse-required-argument)))
    (insert expr)
    (eval-region begin (point))
    (delete-region begin (point))
    (goto-char begin)))

(defun hyperlatex-format-typeout ()
  (let ((arg (hyperlatex-parse-required-argument)))
    (hyperlatex-message "%s" arg)))

(defun hyperlatex-format-error ()
  (let ((arg (hyperlatex-parse-required-argument)))
    (error "%s" arg)))

(defun hyperlatex-format-htmlaccent ()
  (let ((acc (hyperlatex-parse-required-argument))
	(arg (hyperlatex-parse-required-argument)))
    (if (string= arg "")
	(insert acc)
      (let ((match (assoc (concat acc arg) hyperlatex-html-accents)))
	(insert 
	 (if match
	     (cdr match)
	   (concat "\\HlxIllegalAccent{" acc "}{" arg "}")))
	(goto-char hyperlatex-command-start)))))

(defun hyperlatex-format-hlxaccent ()
  (let ((acc (hyperlatex-parse-required-argument))
	(def (hyperlatex-parse-required-argument)))
    (setq hyperlatex-html-accents
	  (cons (cons acc def) hyperlatex-html-accents))))

(defun hyperlatex-format-emptyp ()
  (let ((start hyperlatex-command-start)
	(arg (hyperlatex-parse-required-argument))
	(exists (hyperlatex-parse-required-argument))
	(void  (hyperlatex-parse-required-argument)))
;; RK's
    (hyperlatex-mode-level-up "emptyp")
    (hyperlatex-enter-h-mode)
;;
    (insert arg)
    (hyperlatex-format-region start (point))
    (setq arg (if (string= "" (buffer-substring start (point))) void exists))
    (delete-region start (point))
    (insert arg)
    (goto-char start))
;; RK's
    (hyperlatex-mode-level-down "emptyp")
;;
)

;;;
;;; ----------------------------------------------------------------------
;;;

(defun hyperlatex-insert-hyperlatex ()
  (interactive)
  (insert "hyperlatex-"))
;;; (local-set-key "\C-s\C-h" 'hyperlatex-insert-hyperlatex)

(defun hyperlatex-compile ()
  "Byte compile Hyperlatex. 
Unix usage:
     emacs -batch -no-init-file -no-site-file \
           -l hyperlatex.el -f hyperlatex-compile."
  (setq byte-compile-verbose nil)
  (if (not noninteractive)
      (error "This command must be used in batch mode."))
  (byte-compile-file "hyperlatex.el"))

;;;
;;; ----------------------------------------------------------------------
;;;
;;; Local Variables:
;;; update-last-edit-date: t
;;; End:
;;;
