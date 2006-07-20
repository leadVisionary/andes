;;; script for regenerating all problem files
;;; grep minutes make-prbs.log | sort -g -k7
;;;  ls Problems/*.prb | sed "s/Problems\/\(.*\).prb/\1/"
;;; sbcl < make-prbs.cl >& make-prbs.log &
 (rkb)
 (defvar t0 (get-internal-run-time))
 (make-prbs '(
COUL1A
EFIELD1E
ELEC1A
ELEC1B
ELEC2
ELEC3A
ELEC3B
ELEC4A
ELEC4B
ELEC5A
ELEC5B
ELEC6A
ELEC6B
FOR11A
FOR11B
FOR11C
FOR4A
FOR4B
FOR4C
MAG4A
))
;; time to do this is:
(format t "~F hours~%" (/ (- (get-internal-run-time) t0) 
			  (* 3600 internal-time-units-per-second)))
(quit)

