;;;; -*- Lisp -*-
;;;; above sets emacs major mode to Lisp
;;;;
;;;; Use this to compile:
;;;;  (asdf:operate 'asdf:load-op 'andes)
;;;; or use command (rkb) if it is defined.
;;;  To turn on solver logging:
#|
:cd /home/bvds/Andes2/ 
(solve-do-log "t") 
|#


;;;; The following was stolen from maxima.asd
;;;; See http://www.math.utexas.edu/pipermail/maxima/2003/005630.html
#+(or sbcl openmcl)
(or (find-package "USER")
    (rename-package "COMMON-LISP-USER" "COMMON-LISP-USER" '("USER")))
(in-package :user)
(in-package :asdf)

;;;;   Load the source file, without compiling
;;;;   asdf:load-op reloads all files, whether they have been
;;;;   changed or not.
(defclass load-only-andes-source-file (source-file) ())
(defmethod output-files ((o compile-op) (s load-only-andes-source-file))
  (list (component-pathname s)))
(defmethod perform ((o compile-op) (s load-only-andes-source-file))
  nil)
(defmethod perform ((o load-op) (s load-only-andes-source-file))
  (load (component-pathname s)))
(defmethod source-file-type ((s load-only-andes-source-file) y)
  "cl")


(defsystem :andes
  :name "Andes"
  :description "Andes physics tutor system"
  :components (
;;;    this should eventually be removed
	       (:file "andes-path")
	       (:module "Base"
;;;			:description "Common Utilities"
			:components ((:file "Htime")
				     (:file "Unification")
				     (:file "Utility")))
	       (:module "Solver_Release"
			:depends-on ("andes-path")
			:components ((:file "solver")))
	       (:module "HelpStructs"
			:depends-on ("Base")
			:components ((:file "PsmGraph")
				     (:file "SystemEntry"
					    :depends-on ("PsmGraph"))
				     ))
	       (:module "Knowledge"
			:depends-on ("Base" "Solver_Release" "HelpStructs")
			:components ((:file "eqn")         
				     (:file "Nogood")    
				     (:file "Operators")  
				     (:file "qvar")
				     (:file "BubbleGraph" 
				     ;; also depends on HelpStructs
					    :depends-on ("qvar" "eqn"))  
				     (:file "ErrorClass")  
				     (:file "Ontology")  
				     (:file "Problem") ;depends on HelpStructs
				     (:file "Solution")))	       
	       (:module "KB"
;;;	    	:description "Knowledge Base"
			;; These are not compiled
			:default-component-class load-only-andes-source-file
			:depends-on ("Knowledge" "Base" "SGG")
			:serial t  ;real dependancies would be better...
			:components ((:file "reset-KB")
				     (:file "Physics-Funcs")
				     (:file "Ontology" )        
				     (:file "circuit-ontology")  
				     (:file "Newtons2")        
				     (:file "NewtonsNogoods")  
				     (:file "Problems")
				     (:file "impulse-problems") 
				     (:file "waves")
				     (:file "waves-problems")
				     (:file "oscillations-problems") 
				     ;;      ^ depends on "waves"
				     (:file "errors")
				     (:file "force-problems")  
;;; Hey, these are the wrong mountains
				     ;; (:file "PyreneesProblems")
				     (:file "forces")          
				     (:file "optics")          
				     (:file "vectors")
				     (:file "makeprob")        
				     (:file "vectors-problems")
				     (:file "circuits")
				     ))
	       (:module "SGG"
;;;			:description "Solution Graph Generator" 
			:depends-on ("Base" "Knowledge" "HelpStructs")
			:components ((:file "Qsolver") ;depends on HelpStructs
				     (:file "Exec" 
					    :depends-on ("Qsolver"))
				     (:file "Macros")         
				     (:file "SolutionPoint")
				     (:file "GraphGenerator") 
				     (:file "ProblemSolver")
				     (:file "SolutionSets")))
))

;;;  make source file extension "cl"  See asdf manual

(defmethod source-file-type ((c cl-source-file) (s (eql (find-system :andes))))
   "cl")

;;;;
;;;;  install command
;;;;

(defun rkb ()
  "Reset the lists in KB and reload all files using asdf"
  (asdf:operate 'asdf:load-op 'andes))
