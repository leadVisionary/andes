;;;; -*- Lisp -*-

;;;; The following was stolen from maxima.asd
;;;; See http://www.math.utexas.edu/pipermail/maxima/2003/005630.html
#+(or sbcl openmcl)
(or (find-package "USER")
    (rename-package "COMMON-LISP-USER" "COMMON-LISP-USER" '("USER")))
(in-package :user)
(in-package :asdf)


(defsystem :andes-help
  :name "Andes help"
  :description "Andes physics tutor system: helpsystem"
  :depends-on (andes)
  :components (
	       (:module "HelpStructs"
			;; PSMgraph and SystemEntry are defined in "andes"
			:components ((:file "StudentEntry")
				     (:file "TutorTurn")
				     (:file "Error-Interp")
				     (:file "StudentAction"
					    :depends-on ("TutorTurn"))
				     (:file "CMD")
				     (:file "RuntimeTestScore")
				     (:file "RuntimeTest")
				     ))
	       (:module "Help"
			:depends-on ("HelpStructs")
			:components (
 				     ;; Solution graph
	 			     (:file "SolutionGraph")
				     
                                     (:file "utilities" 
					    :depends-on ("tell"))
				     (:file "lrdc-errors")
				     (:file "History")
				     (:file "StudentFile"
					     :depends-on ("tell"))
				     (:file "tell") ;tracing tool
				     				     
				     ;; Entry Intepreter: generic + non-eq
				     (:file "symbols"
					     :depends-on ("tell"))
				     (:file "State")
				     (:file "clips-vars")
				     (:file "Entry-API")
				     
				     ;; Equation parser/interpreter
				     (:file "grammar"
					    :depends-on ("tell"))
				     (:file "physics-algebra-rules"
					     :depends-on ("tell"))
				     (:file "parse"
					     :depends-on ("tell"))
				     (:file "pre2in"
					     :depends-on ("tell"))
				     (:file "in2pre" :depends-on ("tell"))
				     (:file "parse-andes"
					     :depends-on ("tell"))
				     (:file "interpret-equation"
					     :depends-on ("tell"))
				     
				     ;;  Help
				     (:file "HelpMessages")
				     (:file "whatswrong"
					     :depends-on ("tell"))
				     (:file "NextStepHelp")
				     (:file "IEA")
				     (:file "nlg" ;Natural language.
					     :depends-on ("tell")) 
				     
				     ;; Automatic statistics code.
				     (:file "Statistics")
				     
				     ;; Top-level manager
		 		     (:file "Interface" ;The interface api.
					    :depends-on ("tell")) 
	 			     (:file "Commands")
 				     (:file "API")
				     (:file "Andes2-Main")))
	       (:module "Testcode"
			:depends-on ("Help" "HelpStructs")
			:components (
				     (:file "StackProcessing")
				     (:file "CMDTests")
				     (:file "StackTests")
				     (:file "EntryPair")
				     (:file "ProcDepth")
				     (:file "UtilFuncs")
				     (:file "Tests")
				     ))
	       ))

;;;  make source file extension "cl"  See asdf manual

(defmethod source-file-type ((c cl-source-file) (s (eql (find-system :andes-help))))
   "cl")

;;;;
;;;;  install command
;;;;

(defun rhelp ()
  "Reset the lists in KB and reload all files using asdf"
  (asdf:operate 'asdf:load-op 'andes-help))
