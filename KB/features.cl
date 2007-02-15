;;;
;;;    List of quantities associated with various "features"
;;;
;;; The routine building the featuresets allows inheritance.
;;; A featureset is "eligible" if it contains no members equal to itself.
;;; If f1 is a feature in featureset A and f1 is also the name of an 
;;; eligible featureset B=f1, then the features in B are appended to A.
;;;
;;; Routines for generating features.tsv appear at the end.
;;;
;;; The following features enable custom dialog boxes on the workbench:
;;;   speed, angle, energy, current, voltage, resistance, capacitance,
;;;   duration, probablity, time-constant

;; global features
(setq *Ontology-features-ignore*  
      '(mag dir compo ;match all vector quantities
	    test-var ;dummy variable for ensuring positivity
	    ))

;;  Use inheretance to always associate certain features
(def-feature-set angle (angle-between))
(def-feature-set energy-set ;dummy name
  (energy total-energy kinetic-energy grav-energy rotational-energy 
	  spring-energy electric-energy))
(def-feature-set potential (net-potential)) ;generated by from-workbench
(def-feature-set voltage (voltage-across))
(def-feature-set work-set ;dummy name
  (work net-work work-nc))

(def-feature-set dipole (dipole-energy))
(def-feature-set kinematics 
    (distance speed duration angle 
	      gravitational-acceleration ;sometimes predefined constant
	      ))
(def-feature-set statics 
  (mass angle coef-friction duration spring-constant compression 
	gravitational-acceleration))
(def-feature-set dynamics 
  (mass angle coef-friction coef-drag-turbulent duration 
	gravitational-acceleration))
(def-feature-set changing-mass (mass mass-change-magnitude))
(def-feature-set circular (mass revolution-radius period duration angle)) 
(def-feature-set energy 
  (energy-set work-set mass duration power compression 
		   spring-constant height gravitational-acceleration))
(def-feature-set work (work-set power net-power duration angle))
(def-feature-set work-quants 
  (work-set power net-power duration angle intensity db-intensity area))
(def-feature-set work-quants-out 
  (work-set net-power-out duration angle intensity net-intensity
	    db-intensity net-db-intensity))
(def-feature-set linmom (energy-set mass duration))
(def-feature-set rotkin 
  (mass revolution-radius period duration angle moment-of-inertia))
(def-feature-set angmom 
  (mass period duration angle moment-of-inertia))
(def-feature-set torque 
  (mass period duration angle moment-of-inertia))
(def-feature-set circuits 
  (electric-power current voltage resistance capacitance charge-on 
		  stored-energy self-inductance mutual-inductance 
		  current-change time-constant duration))
(def-feature-set E&M-quantities 
  (charge-on current potential duration length turns turns-per-length angle 
	     electric-flux magnetic-flux electric-flux-change 
	     magnetic-flux-change mass-per-length))
(def-feature-set number-of-particles
  (charge-on mass number-of))
(def-feature-set gauss
  (charge-in electric-flux angle))
(def-feature-set gauss-sum
  (charge-on electric-flux angle))
(def-feature-set ampere
  (current magnetic-line-integral))
(def-feature-set EM-waves 
  (amplitude-electric amplitude-magnetic))
(def-feature-set simple-work
  (intensity-at))
(def-feature-set optics 
  (object-distance image-distance distance-between
		   slit-separation focal-length 
		   magnification radius-of-curvature index-of-refraction 
		   angle resolution-angle)) 
(def-feature-set fluids 
  (mass duration height mass-density pressure area-at area volume
	gravitational-acceleration	;sometimes predefined constant
	atmosphere ;predefined constant
	))
(def-feature-set rectangle-geometry 
  (area area-change length width length-change))
(def-feature-set circle-geometry 
  (area radius-of-circle diameter-of-circle circumference-of-circle))
(def-feature-set waves 
  (frequency distance duration mass length mass-per-length wavelength 
	     wavenumber period angular-frequency wave-speed 
	     index-of-refraction string-tension))
(def-feature-set observed-frequency (observed-frequency))
(def-feature-set oscillations 
  (mass length spring-constant compression wavelength wavenumber period 
	frequency angular-frequency amplitude amplitude-max-speed 
	amplitude-max-abs-acceleration gravitational-acceleration))
(def-feature-set probability (probability))

;;;  ============================================================
;;;  Make sure that problem features allow all quantities to be
;;;  defined on the workbench.

(post-process test-quants-against-features (Problem)
  "test that all quantities can be found in the problem features"
  (dolist (quant (problem-varindex problem))
    (let ((exptype-struct (lookup-expression-struct (qvar-exp quant))))
      (when (null exptype-struct) 
	(error "The quantity ~A does not match anything in ontology." 
	       (qvar-exp quant)))
      (when (not (quant-allowed-by-features (exptype-type exptype-struct) 
				    (problem-features Problem)))
	(error "Problem features do not enable ~A." 
	       (exptype-type exptype-struct))))))


;;;             Utilities for constructing features file

(defun print-features (str)
 "express features in the format needed for KB/features.tsv"
  (dolist (f *Ontology-features*)
  (format str "~A~C~(~{~A;~}~)~%"  ;lower case, see Bug #788 
	  (first f) #\tab (second f))))

(defun features-file ()
 "construct file KB/features.tsv"
    (let ((str (open (merge-pathnames  "KB/features.tsv" *Andes-Path*)
		     :direction :output :if-exists :supersede
		     ;; The workbench uses an older windows-specific 
		     ;; character encoding
		     :external-format #+sbcl :windows-1252 #+allegro :1252)))
		   (print-features str) (close str)))
