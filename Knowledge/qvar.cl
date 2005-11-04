;;
;; Qvar.cl.cl
;; Collin Lynch
;; 4/23/2001
;;
;; This file defines the Bubblegraph data structures for the 
;; Andes2 help system.  The structures themselves are generated by the
;; code located in sgg/GraphGenerator.cl  This code has been located
;; here to facilitate its use by other parts of the help system.
;;
;; A bubblegraph itself is a list of the form 
;; (<Qnodes> <Enodes> <Vars> <Eqns>) where: 
;; 
;; -----------------------------------------------------------------
;; Changelog:
;;  6/6/2003:  Removed duplicate definition of match-var->qvar.


;;=========================================================================
;; Variable code.
;; For the purposes of the help and algebra system it is necessary
;; to collect the equations and variables from the graph.
;;
;; Variables are typically stored either as Qnodes or as lists of 
;; the form (variable <Var> <Expression>)
;;
;; for index purposes we will need to store the quantity vars
;; which are of the form (Qvar <Var> <Expression> <Units> <resrictions>)
;; 
;; The Algebra solver system makes use of variables of the form 
;; ((Svar <Var> <Units) <Restrictions-list>)
;; where <Restrictions-list> is a list of the form 
;; (<Restriction> <Var>) and <Restriction can be 'parameter
;; 'nonnegative, etc.  This code draws heavily on the ontology facility.
;;
;; Index vars are qvars with an additional value slot.


(defstruct (qvar (:print-function print-qvar))
  Index
  Var
  Exp
  Value
  Units
  Marks
  Nodes
  )

(defun print-qvar (Qvar &optional (Stream t) (Level 0))
  (pprint-indent :block Level)
  (format Stream "~A" (Qvar->pqvar Qvar)))

(defun qvar->pqvar (Qvar)
  (list 'Qvar (Qvar-Index Qvar) (Qvar-Var Qvar) 
	(Qvar-Exp Qvar) (Qvar-Value Qvar)
	(Qvar-Units Qvar) (Qvar-Marks Qvar) 
	(Qvar-Nodes Qvar)))

(defun print-mreadable-qvar (Qvar &optional (Stream t) (Level 0))
  (pprint-indent :block Level)
  (format Stream "(Qvar ~W" (Qvar-Index Qvar))
  (format Stream " ~W" (Qvar-Var Qvar)) 
  (format Stream " ~W" (Qvar-Exp Qvar)) 
  (format Stream " ~W" (Qvar-Value Qvar))
  (format Stream " ~W" (Qvar-Units Qvar)) 
  (format Stream " ~W" (Qvar-Marks Qvar)) 
  (format Stream " ~W)~%" (collect-nodes->gindicies (qvar-Nodes Qvar))))

(defun qvlist->qvar (Q G)
  "Convert the list form of qvar qvlist L to a Qvar."
  (make-qvar :index (nth 1 Q)
	     :var (nth 2 Q)
	     :exp (nth 3 Q)
	     :value (nth 4 Q)
	     :units (nth 5 Q)
	     :marks (nth 6 Q)
	     :nodes (collect-gindicies->nodes (nth 7 Q) G)))


(defun print-mreadable-qvars (V S)
  "Print the specified Eindex E in mreadable form."
  (format S "(")
  (dolist (Q V)
    (print-mreadable-qvar Q S))
  (format S ")~%"))
  

(defun read-mreadable-qvars (S G)
  "Read in an Mreadable vindex associated with Bubblegraph G."
  (loop for V in (read S "Malformed qvars file.")
      collect (qvlist->qvar V G)))


;;----------------------------------------------------------------
;; Use code

(defun Index-qvar-list (Vars)
  "Set the equation indivies in the list."
  (dotimes (N (length Vars))
    (setf (Qvar-Index (nth N Vars)) N))
  Vars)


(defun vars->qvars (Vars &key (ExpMarks Nil))
  "Given a list of vars convert it to a list of qvars."
  (loop for N below (length Vars)
      collect (var->qvar (nth N Vars) :ExpMarks ExpMarks)))

(defun var->qvar (V &key (ExpMarks Nil))
  "Convert a var to a qvar."
  (valid-expression-p (caddr V))
  (make-qvar 
   :var (cadr V) 
   :exp (caddr V)
   :units (lookup-expression-units (caddr V))
   :marks (remove-duplicates
	   (append (lookup-expression-restrictions (caddr V))
		   (mappend #'cdr (collect-unifiers ExpMarks (caddr V) :key #'car))))))


;;; Note:  This code should not be called if there are no vars or 
;;;   if there is only one var in the list.  In the former case it
;;;   will return the value with unnecessary overhead.  In the second
;;;   it will throw an error.  
(defun merge-duplicate-qvars (Vars)
  "Merge the duplicate Qvars"
  (let ((R (list (car Vars))) (tmp))
    (dolist (V (cdr Vars))
      (if (setq tmp (find (Qvar-Exp V) R
			  :key #'Qvar-Exp 
			  :test #'unify))
	  (setf (Qvar-Nodes tmp)
	    (union (Qvar-Nodes tmp) (Qvar-Nodes V)))
	(push V R)))
    R))


(defun qvars->svars (Vars)
  "Iterate over the set of supplied vars feeding them to qvar-to-solver-form."
  (loop for V in Vars 
      nconc (qvar->svar V)))


(defun qvar->svar (Qvar)
  "Return a list containing the eqn-file entries for the qvar. will later include units."
  (cons (list 'svar (Qvar-Var Qvar) (Qvar-Units Qvar))
	(collect-svar-marks qvar)))


(defun collect-qvars->marks (qvars)
  "Collect the markings from the qvars."
  (loop for Q in Qvars
      append (collect-svar-marks q)))
  

(defun collect-svar-marks (qvar)
  (mapcar #'(lambda (m) (list M (Qvar-Var Qvar)))
	  (intersection **Solver-Variable-Marks** 
			(Qvar-Marks Qvar))))

(defun qvars->indyVars (Qvars)
  "Given a list of qvars generate the indyVars for the independence system."
  (loop for Q in Qvars
      when (not (null (Qvar-Value Q)))
      collect (qvar->indyvar Q)))

(defun qvar->indyvar (Qvar)
  (list (Qvar-Var Qvar)
	(Qvar-Value Qvar)
	(Qvar-units Qvar)))
			 



;;; Given a list of vars of the form (svar <Varname> <Value> <Units>)
;;; match their values with the Qvars in Vars setting all others
;;; to a value of NULL.
(defun set-qvar-values (Values Vars)
  "Match the values to the specified Qvars."
  (loop for V in Vars
      with Q = NiL
      when (setq Q (find (string (Qvar-Var V)) Values
			 :test #'equalp ;matching different cases 
			 :key #'(lambda (v) (string (cadr v)))))
      do (setf (Qvar-Value V) (caddr Q))
      else do (setf (Qvar-Value V) NIL))
  Vars)
      

(defun collect-vars->qvars (Vars Qvars)
  (loop for V in Vars
      when (match-var->qvar (cadr V) Qvars)
      collect it
      else do (error "Unrecognized variable ~A supplied." V)))

(defun collect-indicies->qvars (Indicies Vars)
  "Given a list of indicies and a list of vars collect the specified vars."
  (loop for I in Indicies
      collect (collect-index->qvar I Vars)))

	      
(defun collect-index->qvar (I Vars)
  "Given a list of indicies and a list of vars collect the specified vars."
  (when (not (= I (Qvar-Index (nth I Vars))))
    (error "Incompatible variable index ~A ~A" I Vars))
  (nth I Vars))






;;; make-qsolver-var
;;; Given a qsolver var form define a qvar 
;;; struct for it.  Or a list if vars is called.
(defun make-qsolver-var (QV)
  "Make a qsolver var from QV."
  (make-qvar :Var (nth 1 QV)
	     :exp (nth 2 QV)))

(defun make-qsolver-vars (QVars)
  "Collect the vars for the qsolver qvars."
  (let ((Vars))
    (dolist (Q Qvars)
      (push (make-qsolver-var Q) Vars))))



;;----------------------------------------------------
;; compare var indicies

(defun diff-var-indicies (V1 V2)
  "Are the two indicies equalp?"
  (list (set-difference V1 V2 :test #'qvars-ni-equalp)
	(set-difference V2 V1 :test #'qvars-ni-equalp)))

(defun qvars-ni-equalp (q1 q2)
  "Are the two qvars equal but for their index."
  (and (unify (qvar-var q1) (qvar-var q2))
       (unify (qvar-exp q1) (qvar-exp q2))
       (unify (qvar-value q1) (qvar-value q2))
       (unify (qvar-units q1) (qvar-units q2))
       (equal-sets (qvar-Marks q1) (qvar-Marks q2))
       (equal-sets (mapcar #'bgnode-exp (qvar-Nodes q1))
		    (mapcar #'bgnode-exp (qvar-Nodes q2)))))



;;;===================================================================
;;; At help time it is necessary to test whether a given canonical
;;; var (qvar) is a parameter, answer-var etc.  The functions in this
;;; section provide predicated to answer trhat information.

(defun qvar-parameterp (Q)
  (member 'Parameter (Qvar-Marks Q)))

(defun qvar-answer-varp (Q)
  (member 'answer-var (Qvar-Marks Q)))

(defun qvar-cancelling-varp (Q)
  (and (qvar-parameterp Q)
       (not (qvar-answer-varp Q))))


;;; Are the specified vars answer vars or other 
;;; elements as necessary.
(defun answer-varp (V Qvars)
  (let ((Q (match-var->Qvar V Qvars)))
    (if Q (qvar-answer-varp Q))))

(defun cancelling-varp (V Qvars)
  (let ((Q (match-var->Qvar V Qvars)))
    (if Q (qvar-cancelling-varp Q))))

	   
	    

;;;===================================================
;;; lookup and searching functions.

(defun match-var->Qvar (Var Qvars)
  "Given a list of qvars look for one that matches var."
  (find Var Qvars :key #'Qvar-Var :test #'unify)) ;could use "equal"

(defun match-qexps->qvars (Exps Vars)
  "Collect the qvars for the specified quantity exp's."
  (loop for E in exps
      with var = nil
      do (setq Var (find E Vars :key #'qvar-exp :test #'unify))
      when Var
      collect var
	      
      else do (error "Undefined or Non quantity expression supplied ~%~A" E)))

(defun collect-solved-qvars (Vars)
  "Collect all solved qvars in the list."
  (loop for V in Vars
      when (Qvar-Value V)
      collect V))


(defun collect-unsolved-qvars (Vars)
  "Collect all the unsolved qvars in the set."
  (loop for V in Vars
      unless (Qvar-Value V)
      collect V))


(defun match-exp->qvar (Exp Vars)
  "Given a kb expression look up the qvar that matches it from List."
  (find Exp Vars :test #'unify :key #'Qvar-Exp)) ;could use "equal"


(defun qvars-solvedp (Vars)
  (not (loop for V in Vars
	   unless (qvar-value V)
	   return t)))

