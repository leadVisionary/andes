
;;;  Tree from for list of principles to show
;;;   This is used to generate KB/principles.tsv

(defparameter *principle-tree* '(
(group "Write a Principle"
  (group "Kinematics" 
	  (group "Translational"			
		  (leaf sdd :short-name "average speed" 
			 :tutorial "Average speed")
		  (leaf avg-velocity :short-name "average velocity" :bindings ((?axis . x)) :tutorial "Average velocity")
		  (leaf avg-velocity :short-name "average velocity" :bindings ((?axis .y)) :tutorial "Average velocity")
		  (leaf lk-no-s :short-name "average acceleration" :bindings ((?axis . x)) :tutorial "Average acceleration")
		  (leaf lk-no-s :short-name "average acceleration" :bindings ((?axis . y)) :tutorial "Average acceleration")
		  (leaf lk-no-vf :short-name "[a_x is constant]" :bindings ((?axis . x)) :tutorial "Constant acceleration")
		  (leaf lk-no-vf :short-name "[a_y is constant]" :bindings ((?axis . y)) :tutorial "Constant acceleration")
		  (leaf lk-no-s :short-name "[a_x is time average]" :bindings ((?axis . x)) :tutorial "Constant acceleration")
		  (leaf lk-no-s :short-name "[a_y is time average]" :bindings ((?axis . y)) :tutorial "Constant acceleration")
		  (leaf lk-no-t :short-name "[a_x is constant]" :bindings ((?axis . x)) :tutorial "Constant acceleration")
		  (leaf lk-no-t :short-name "[a_y is constant]" :bindings ((?axis . y)) :tutorial "Constant acceleration")
		  (leaf sdd-constvel :short-name "[a_x=0; v_x is constant]" :bindings ((?axis . x)) :tutorial "Constant velocity component")
		  (leaf sdd-constvel :short-name "[a_y=0; v_y is constant]" :bindings ((?axis . y)) :tutorial "Constant velocity component")
		  (leaf centripetal-accel :short-name "Centripetal acceleration (instantaneous)" :tutorial "Centripetal acceleration")
		  (leaf centripetal-accel-compo :short-name "Centripetal acceleration (x component)" :bindings ((?axis . x)) :tutorial "Centripetal acceleration")
		  (leaf centripetal-accel-compo :short-name "Centripetal acceleration (y component)" :bindings ((?axis . y)) :tutorial "Centripetal acceleration")
		  (leaf relative-vel :short-name "Relative velocity" :bindings ((?axis . x)) :tutorial "Relative Velocity")
		  (leaf relative-vel :short-name "Relative velocity" :bindings ((?axis . y)) :tutorial "Relative Velocity")
		  )
	  (group "Rotational" 
		  (leaf ang-sdd :short-name "average angular velocity" :tutorial "Angular velocity")
		  (leaf rk-no-vf :short-name "average angular acceleration" :tutorial "Angular acceleration")
		  (leaf rk-no-vf :short-name "[$a_z is constant]" :tutorial "Constant angular acceleration")
		  (leaf rk-no-s :short-name "[$a_z is time average]" :tutorial "Constant angular acceleration")
		  (leaf rk-no-t :short-name "[$a_z is constant]" :tutorial "Constant angular acceleration")
		  (leaf linear-vel :short-name "Linear velocity at a certain radius" :tutorial "Linear velocity")
		  (leaf rolling-vel :short-name "Linear velocity of rolling object" :tutorial "Linear velocity")
		  )
	  )
  (group "Newton's Laws" 
	  (group "Translational" 
		  (leaf NSL :short-name "Newton's Second Law" :bindings ((?axis . x)) :tutorial "Newton's Second Law")
		  (leaf NSL :short-name "Newton's Second Law" :bindings ((?axis . y)) :tutorial "Newton's Second Law")
		  (leaf NTL :short-name "Newton's Third Law (magnitudes)" :tutorial "Newton's Third Law")
		  (leaf NTL-vector :short-name "Newton's Third Law (components)" :bindings ((?axis . x)) :tutorial "Newton's Third Law")
		  (leaf NTL-vector :short-name "Newton's Third Law (components)" :bindings ((?axis . y)) :tutorial "Newton's Third Law")
		  (leaf ug :short-name "Universal gravitation" :tutorial "Universal Gravitation")
		  )
	  (group "Rotational" 
		  (leaf NL-rot :short-name "rotational form of Newton's 2nd Law" :tutorial "Newton's Law for rotation")
		  (leaf mag-torque :short-name "torque defined (magnitude)" :tutorial "Individual torque magnitude")
		  (leaf torque-zc :short-name "torque defined (z component)" :tutorial "Individual torque magnitude")
		  (leaf net-torque-zc :short-name "Net torque defined" :tutorial "Net torque")
		  )
	  )
  (group "Work Energy and Power" 
	  (leaf work :short-name "work defined" :tutorial "Work done by a force")
	  (leaf net-work :short-name "Net work defined" :tutorial "Net work")
	  (leaf work-energy :short-name "work-energy theorem" :tutorial "Work-Energy")
	  (leaf cons-energy :short-name "[Wnc=0] conservation of mechanical energy" :tutorial "Conservation of Energy")
	  (leaf change-me :short-name "change in mechanical energy" :tutorial "Conservation of Energy")
	  (leaf kinetic-energy :short-name "kinetic energy defined" :tutorial "Conservation of Energy")
	  (leaf rotational-energy :short-name "rotational kinetic energy defined" :tutorial "Conservation of Energy")
	  (leaf grav-energy :short-name "gravitational potential energy [near Earth]" :tutorial "Conservation of Energy")
	  (leaf spring-energy :short-name "spring potential energy" :tutorial "Conservation of Energy")
	  (leaf electric-energy :short-name "electric potential energy" :tutorial "Electric Potential")
	  (leaf power :short-name "average power defined" :tutorial "Power")
	  (leaf net-power :short-name "average net power defined" :tutorial "Power")
	  (leaf inst-power :short-name "instantaneous power" :tutorial "Power")
	  (leaf intensity-to-power :short-name "relation of power and intensity (spherical emitter)" :tutorial "Intensity")
	  (leaf uniform-intensity-to-power :short-name "relation of power and intensity (uniform over surface)" :tutorial "Intensity")
	  (leaf intensity-to-decibels :short-name "intensity to decibels" :tutorial "Intensity")
	  (leaf intensity-to-decibels :short-name "decibels to intensity" :tutorial "Intensity")
	  (leaf intensity-to-poynting-vector-magnitude :short-name "relation of intensity and the magnitude of the Poynting vector" :tutorial "Intensity")
	  (leaf net-intensity :short-name "Net intensity" :tutorial "Intensity")
	  )
  (group "Momentum and Impulse" 
	  (group "Translational" 
		  (leaf momentum-compo :short-name "momentum defined (x component)" :bindings ((?axis . x)) :tutorial "Conservation of Momentum")
		  (leaf momentum-compo :short-name "momentum defined (y component)" :bindings ((?axis . y)) :tutorial "Conservation of Momentum")
		  (leaf cons-linmom :short-name "Conservation of momentum" :bindings ((?axis . x)) :tutorial "Conservation of Momentum")
		  (leaf cons-linmom :short-name "Conservation of momentum" :bindings ((?axis . y)) :tutorial "Conservation of Momentum")
		  (leaf cons-ke-elastic :short-name "Elastic collision defined" :tutorial "Elastic collisions")
		  (leaf impulse-force :short-name "Impulse and force" :bindings ((?axis . x)) :tutorial "Impulse")
		  (leaf impulse-force :short-name "Impulse and force" :bindings ((?axis . y)) :tutorial "Impulse")
		  (leaf impulse-momentum :short-name "Newton's second law" :bindings ((?axis . x)) :tutorial "Impulse")
		  (leaf impulse-momentum :short-name "Newton's second law" :bindings ((?axis . y)) :tutorial "Impulse")
		  (leaf NTL-impulse :short-name "Newton's third law (magnitude)" :tutorial "Impulse")
		  (leaf NTL-impulse-vector :short-name "Newton's third law (x component)" :bindings ((?axis . x)) :tutorial "Impulse")
		  (leaf NTL-impulse-vector :short-name "Newton's third law (y component)" :bindings ((?axis . y)) :tutorial "Impulse")
		  (leaf center-of-mass-compo :short-name "center of mass" :bindings ((?axis . x)) :tutorial "Center of Mass")
		  (leaf center-of-mass-compo :short-name "center of mass" :bindings ((?axis . y)) :tutorial "Center of Mass")
		  )
	  (group "Rotational" 
		  (leaf ang-momentum :short-name "Angular momentum defined" :tutorial "Angular momentum definition")
		  (leaf cons-angmom :short-name "Conservation of Angular momentum" :tutorial "Conservation of Angular momentum")
		  )
	  )
  (group "Fluids"
	  (leaf pressure-height-fluid :short-name "Pressure in fluid" :tutorial "Pressure Height")
	  (leaf bernoulli :short-name "Bernoulli Equation" :tutorial "Bernoulli's Principle")
	  (leaf equation-of-continuity :short-name "Equation of continuity" :tutorial "Bernoulli's Principle")
	  (leaf pressure-force :short-name "Pressure defined" :tutorial "Pressure")
	  (leaf density :short-name "Mass density defined" :tutorial "Mass Density")
	  (leaf archimedes :short-name "Archimedes principle (buoyant force)" :tutorial "Buoyant Force")
	  )
  (group "Electricity and Magnetism" 
	  (leaf coulomb :short-name "Coulomb's law (magnitude)" :tutorial "Electric Field")
	  (leaf coulomb-compo :short-name "Coulomb's law (x component)" :bindings ((?axis . x)) :tutorial "Electric Field")
	  (leaf coulomb-compo :short-name "Coulomb's law (y component)" :bindings ((?axis . y)) :tutorial "Electric Field")
	  (leaf charge-force-Efield-mag :short-name "Electric field (magnitude)" :tutorial "Electric Field")
	  (leaf charge-force-Efield :short-name "Electric field" :bindings ((?axis . x)) :tutorial "Electric Field")
	  (leaf charge-force-Efield :short-name "Electric field" :bindings ((?axis . y)) :tutorial "Electric Field")
	  (leaf point-charge-Efield-mag :short-name "point charge field (magnitude)" :tutorial "Point Charge Field")
	  (leaf point-charge-Efield :short-name "point charge field (x component)" :bindings ((?axis . x)) :tutorial "Point Charge Field")
	  (leaf point-charge-Efield :short-name "point charge field (y component)" :bindings ((?axis . y)) :tutorial "Point Charge Field")
	  (leaf net-Efield :short-name "Net Electric Field (x component)" :bindings ((?axis . x)) :tutorial "Electric Field")
	  (leaf net-Efield :short-name "Net Electric Field (y component)" :bindings ((?axis . y)) :tutorial "Electric Field")
	  (leaf electric-flux-constant-field :short-name "electric flux (constant field)" :tutorial "Electric Field")
	  (leaf point-charge-potential :short-name "point charge potential" :tutorial "Electric Potential")
	  (leaf net-potential :short-name "Net potential" :tutorial "Electric Potential")
	  (leaf electric-energy :short-name "electric potential energy" :tutorial "Electric Potential")
	  (leaf gauss-law :short-name "Gauss' law")
	  (leaf electric-dipole-moment-mag :short-name "electric dipole moment (magnitude)" :tutorial "Dipoles")
	  (leaf electric-dipole-moment :short-name "electric dipole moment (x component)" :bindings ((?axis . x)) :tutorial "Dipoles")
	  (leaf electric-dipole-moment :short-name "electric dipole moment (y component)" :bindings ((?axis . y)) :tutorial "Dipoles")
	  (leaf electric-dipole-torque-mag :short-name "torque for electric dipole (magnitude)" :tutorial "Dipoles")
	  (leaf electric-dipole-torque :short-name "torque for electric dipole (z component)" :bindings ((?axis . z)) :tutorial "Dipoles")
	  (leaf electric-dipole-energy :short-name "potential energy of electric dipole" :tutorial "Dipoles")
	  (leaf charge-force-Bfield-mag :short-name "Magnetic force (magnitude)" :tutorial "Magnetic Field")
	  (leaf charge-force-Bfield-x :short-name "F_x = q*(v_y*B_z - v_z*B_y) Magnetic force (x component)" :tutorial "Magnetic Field")
	  (leaf charge-force-Bfield-y :short-name "F_y = q*(v_z*B_x - v_x*B_z) Magnetic force (y component)" :tutorial "Magnetic Field")
	  (leaf charge-force-Bfield-z :short-name "F_z = q*(v_x*B_y - v_y*B_x) Magnetic force (z component)" :tutorial "Magnetic Field")
	  (leaf current-force-Bfield-mag :short-name "Magnetic force on a wire (magnitude)")
	  (leaf straight-wire-Bfield :short-name "Magnetic field of a straight wire")
	  (leaf center-coil-Bfield :short-name "Magnetic field at center of a coil")
	  (leaf inside-solenoid-Bfield :short-name "Magnetic field inside a long solenoid")
	  (leaf net-Bfield :short-name "Net Magnetic Field (x component)" :bindings ((?axis . x)) )
	  (leaf net-Bfield :short-name "Net Magnetic Field (y component)" :bindings ((?axis . y)) )
	  (leaf magnetic-flux-constant-field :short-name "magnetic flux (constant field)")
	  (leaf magnetic-flux-constant-field-change :short-name "rate of change in magnetic flux (constant field)")
	  (leaf faradays-law :short-name "Faraday's law")
	  (leaf magnetic-dipole-moment-mag :short-name "magnetic dipole moment (magnitude)" :tutorial "Dipoles")
	  (leaf magnetic-dipole-moment :short-name "agnetic dipole moment (x component)" :bindings ((?axis . x)) :tutorial "Dipoles")
	  (leaf magnetic-dipole-moment :short-name "magnetic dipole moment (y component)" :bindings ((?axis . y)) :tutorial "Dipoles")
	  (leaf magnetic-dipole-torque-mag :short-name "torque for magnetic dipole (magnitude)" :tutorial "Dipoles")
	  (leaf magnetic-dipole-torque :short-name "torque for magnetic dipole (x component)" :bindings ((?axis . x)) :tutorial "Dipoles")
	  (leaf magnetic-dipole-torque :short-name "torque for magnetic dipole (y component)" :bindings ((?axis . y)) :tutorial "Dipoles")
	  (leaf magnetic-dipole-torque :short-name "torque for magnetic dipole (z component)" :bindings ((?axis . z)) :tutorial "Dipoles")
	  (leaf magnetic-dipole-energy :short-name "potential energy of magnetic dipole" :tutorial "Dipoles")
	  (leaf electromagnetic-wave-field-amplitude :short-name "ratio of fields in electromagnetic wave")
	  )
  (group "DC Circuits" 
	  (leaf loop-rule :short-name "Kirchoff's Loop rule" :tutorial "Loop Rule")
	  (leaf junction-rule :short-name "Kirchoff's junction rule" :tutorial "Junction Rule")
	  (leaf electric-power :short-name "Electric power" :tutorial "Electric Power")
	  (group "Resistance" 
		  (leaf equiv-resistance-series :short-name "Equivalent resistance series" :tutorial "Series Resistors")
		  (leaf equiv-resistance-parallel :short-name "Equivalent resistance parallel" :tutorial "Parallel Resistors")
		  (leaf ohms-law :short-name "Ohm's Law" :tutorial "Ohm's Law")
		  )
	  (group "Capacitance" 
		  (leaf cap-defn :short-name "Capacitance defined" :tutorial "Capacitance")
		  (leaf equiv-capacitance-parallel :short-name "Equivalent capacitance parallel" :tutorial "Parallel Capacitors")
		  (leaf equiv-capacitance-series :short-name "Equivalent capacitance series" :tutorial "Series Capacitors")
		  (leaf charge-same-caps-in-branch :short-name "Charge on series capacitors" :tutorial "Series Capacitors")
		  (leaf cap-energy :short-name "Energy stored in a capacitor" :tutorial "Capacitor Energy")
		  (leaf RC-time-constant :short-name "RC time constant" :tutorial "RC Circuits")
		  (leaf charging-capacitor-at-time :short-name "Charge on capacitor in RC circuit with battery" :tutorial "RC Circuits")
		  (leaf discharging-capacitor-at-time :short-name "Charge on capacitor in RC circuit" :tutorial "RC Circuits")
		  (leaf current-in-RC-at-time :short-name "Current in RC circuit" :tutorial "RC Circuits")
		  (leaf charge-on-capacitor-percent-max :short-name "RC charge as fraction of max" :tutorial "RC Circuits")
		  )
	  (group "Inductance" 
		  (leaf inductor-emf :short-name "Inductor EMF" :tutorial "Inductance")
		  (leaf mutual-inductor-emf :short-name "Mutual Inductor EMF" :tutorial "Inductance")
		  (leaf avg-rate-current-change :short-name "Constant rate of change (or avg)" :tutorial "Inductance")
		  (leaf inductor-energy :short-name "Energy stored in inductor" :tutorial "Inductance")
		  (leaf solenoid-self-inductance :short-name "Self-inductance of a long uniform solenoid" :tutorial "Inductance")
		  (leaf LR-time-constant :short-name "LR time constant" :tutorial "LR Circuits")
		  (leaf LR-current-growth :short-name "LR current growth" :tutorial "LR Circuits")
		  (leaf LR-growth-Imax :short-name "LR growth final current" :tutorial "LR Circuits")
		  (leaf LR-current-decay :short-name "LR current decay" :tutorial "LR Circuits")
		  (leaf LR-decay-Imax :short-name "LR decay initial current" :tutorial "LR Circuits")
		  (leaf LC-angular-frequency :short-name "LC angular frequency" :tutorial "LC Circuits")
		  (leaf RLC-time-constant :short-name "RLC time constant" :tutorial "RLC Circuits")
		  (leaf RLC-angular-frequency :short-name "RLC angular frequency" :tutorial "RLC Circuits")
		  (leaf transformer-voltage :short-name "transformer voltage relation")
		  (leaf transformer-power :short-name "transformer power relation")
		  )
	  )
  (group "Optics" 
	  (leaf lens-eqn :short-name "Thin Lens/Mirror equation" :tutorial "Lens Equation")
	  (leaf magnification-eqn :short-name "(Lateral) Magnification" :tutorial "Magnification")
	  (leaf focal-length-mirror :short-name "Focal Length of Mirror" :tutorial "Spherical Mirror")
	  (leaf lens-combo :short-name "Combination of Lenses" :tutorial "Combined Lenses")
	  (leaf combo-magnification :short-name "Combined Magnification" :tutorial "Magnification")
	  (leaf compound-focal-length :short-name "Compound Lens (Touching Lenses)" :tutorial "Touching Lenses")
	  (leaf wave-speed-refraction :short-name "Index of refraction")
	  (leaf refraction-vacuum :short-name "Index of refraction of vacuum")
	  (leaf snells-law :short-name "Snell's law")
	  (leaf total-internal-reflection :short-name "Total internal reflection (minimum angle)")
	  )
  (group "Waves and Oscillations" 
	  (leaf wavenumber-lambda-wave :short-name "Wavenumber")
	  (leaf frequency-of-wave :short-name "Frequency")
	  (leaf period-of-wave :short-name "Period of oscillation")
	  (leaf speed-of-wave :short-name "Speed of a wave")
	  (leaf wave-speeds-equal :short-name "All waves in a system have same speed")
	  (leaf speed-equals-wave-speed :short-name "Speed of pulse is wave speed")
	  (leaf wave-speed-string :short-name "Speed of waves on a string")
	  (leaf max-transverse-speed-wave :short-name "Maximum speed of oscillation")
	  (leaf max-transverse-abs-acceleration-wave :short-name "Maximum acceleration of oscillation")
	  (leaf spring-mass-oscillation :short-name "Period of a spring-mass system   ")
	  (leaf pendulum-oscillation :short-name "Period of a simple pendulum  ")
	  (leaf doppler-frequency :short-name "requency shift from doppler effect")
	  (leaf harmonic-of :short-name "n-th harmonic")
	  (leaf beat-frequency :short-name "Beat Frequency")
	  (leaf energy-decay :short-name "energy decay")
	  (leaf wave-speed-light :short-name "Speed of Light")
	  )
  )
(group "Apply a Definition or Auxiliary Law"
  (group "Kinematics"
	  (group"Translational"
		 (leaf net-disp :short-name "net displacement" :bindings ((?axis . x)) :tutorial "Net Displacement")
		 (leaf net-disp :short-name "net displacement" :bindings ((?axis . y)) :tutorial "Net Displacement")
		 (leaf avg-velocity :short-name "average velocity" :bindings ((?axis . x)) :tutorial "Average velocity")
		 (leaf avg-velocity :short-name "average velocity" :bindings ((?axis . y)) :tutorial "Average velocity")
		 (leaf lk-no-s :short-name "average acceleration" :bindings ((?axis . x)) :tutorial "Average acceleration")
		 (leaf lk-no-s :short-name "average acceleration" :bindings ((?axis . y)) :tutorial "Average acceleration")
		 (leaf free-fall-accel :short-name "accel in free-fall" :tutorial "Free fall acceleration")
		 (leaf std-constant-g :short-name "g near Earth" :tutorial "Value of g near Earth")
		 (leaf const-vx :short-name "[v_x is constant (a_x =0)]" :tutorial "Constant velocity component")
		 (leaf period-circle :short-name "period of uniform circular motion" :tutorial "Period Circular")
		 )
	  (group "Rotational" 
		  (leaf ang-sdd :short-name "average angular velocity" :tutorial "Angular velocity")
		  (leaf rk-no-vf :short-name "average angular acceleration" :tutorial "Angular acceleration")
		  )
	  )
  (group	 "Newton's Laws" 
		 (group	 "Translational" 
			 (group"Force Laws" 
			  (leaf wt-law :short-name "Weight Law" :tutorial "Weight Law")
			  (leaf kinetic-friction :short-name "Kinetic Friction" :tutorial "Kinetic Friction")
			  (leaf static-friction :short-name "Static Friction (at max)" :tutorial "Static Friction max")
			  (leaf spring-law :short-name "Hooke's Law" :tutorial "Hooke's Law")
			  (leaf tensions-equal :short-name "Equal tensions at both ends" :tutorial "Equal tensions at both ends")
			  (leaf thrust-definition :short-name "Thrust force (magnitudes)" :tutorial "thrust force")
			  (leaf thrust :short-name "Thrust force (components)" :bindings ((?axis . x)) :tutorial "thrust force")
			  (leaf thrust :short-name "Thrust force (components)" :bindings ((?axis . y)) :tutorial "thrust force")
			  )
			 (group "Compound Bodies" 
				(leaf mass-compound :short-name "Mass of compound" :tutorial "Mass of a compound body")
				(leaf kine-compound :short-name "Velocity of compound" :bindings ((?vec-type . velocity)) :tutorial "Kinematics of compound same as part")
				(leaf kine-compound :short-name "Acceleration of compound" :bindings ((?vec-type . acceleration)) :tutorial "Kinematics of compound same as part")
				(leaf force-compound :short-name "Force on compound" :tutorial "Force on a compound body")
				)
			 )
		 (group "Rotational" 
			(leaf net-torque-zc :short-name "Net torque defined" :tutorial "Net torque")
			(leaf torque-zc :short-name "torque defined" :tutorial "Individual torque magnitude")
			(leaf mag-torque :short-name "torque magnitude" :tutorial "Individual torque magnitude")
			(group "Moment of Inertia" 
			  (leaf I-disk-cm :short-name "disk about center" :tutorial "disk about center of mass")
			  (leaf I-rod-cm :short-name "rod about center" :tutorial "Long thin rod about center of mass")
			  (leaf I-rod-end :short-name "rod about end" :tutorial "Long thin rod about end")
			  (leaf I-hoop-cm :short-name "hoop" :tutorial "Hoop about center of mass")
			  (leaf I-cylinder :short-name "cylinder" :tutorial "Cylinder")
			  (leaf I-rect-cm :short-name "rectangular plate" :tutorial "Rectangle about center of mass")
			  (leaf I-compound :short-name "compound body" :tutorial "Compound body")
			  )
			)
		 )
  (group "Work and Energy" 
	  (leaf net-work :short-name "Net work defined" :tutorial "Net work")
	  (leaf work-nc :short-name "work by non-conservative" :tutorial "Conservation of Energy")
	  (leaf mechanical-energy :short-name "mechanical energy defined" :tutorial "Conservation of Energy")
	  (leaf kinetic-energy :short-name "kinetic energy defined" :tutorial "Conservation of Energy")
	  (leaf rotational-energy :short-name "rotational kinetic energy defined" :tutorial "Conservation of Energy")
	  (leaf grav-energy :short-name "gravitational potential energy [near Earth]" :tutorial "Conservation of Energy")
	  (leaf spring-energy :short-name "spring potential energy" :tutorial "Conservation of Energy")
	  (leaf electric-energy :short-name "electric potential energy" :tutorial "Electric Potential")
	  (leaf height-dy :short-name "change in height" :tutorial "Height and Displacement")
	  (leaf power :short-name "average power defined" :tutorial "Power")
	  (leaf net-power :short-name "avg. net power defined" :tutorial "Power")
	  )
  (group "Fluids" 
	  (leaf pressure-at-open-to-atmosphere :short-name "Point 1 open to atmosphere" :tutorial "Atmospheric Pressure")
	  (leaf std-constant-Pr0 :short-name "Atmospheric pressure" :bindings 0 :tutorial "Atmospheric Pressure")
	  )
  )
(group "Calculate a vector component" 
  (group "Displacement" 
	  (leaf projection :short-name "on x-axis" :bindings ((?axis . x) (?vector . (displacement ?body))) :tutorial "Projection Equations")
	  (leaf projection :short-name "on y-axis" :bindings ((?axis . y) (?vector . (displacement ?body))) :tutorial "Projection Equations")
	  )
  (group "Velocity" 
	  (leaf projection :short-name "on x-axis" :bindings ((?axis . x) (?vector . (velocity ?body))) :tutorial "Projection Equations")
	  (leaf projection :short-name "on y-axis" :bindings ((?axis . y) (?vector . (velocity ?body))) :tutorial "Projection Equations")
	  )
  (group "Acceleration" 
	  (leaf projection :short-name "on x-axis" :bindings ((?axis . x) (?vector . (acceleration ?body))) :tutorial "Projection Equations")
	  (leaf projection :short-name "on y-axis" :bindings ((?axis . y) (?vector . (acceleration ?body))) :tutorial "Projection Equations")
	  )
  (group "Force" 
	  (leaf projection :short-name "on x-axis" :bindings ((?axis . x) (?vector . (force . ?args))) :tutorial "Projection Equations")
	  (leaf projection :short-name "on y-axis" :bindings ((?axis . y) (?vector . (force . ?args))) :tutorial "Projection Equations")
	  )
  (group "Relative Position"
	  (leaf projection :short-name "on x-axis" :bindings ((?axis . x) (?vector . (relative-position ?body ?origin))) :tutorial "Projection Equations")
	  (leaf projection :short-name "on y-axis" :bindings ((?axis . y) (?vector . (relative-position ?body ?origin))) :tutorial "Projection Equations")
)
  (group "Momentum"
	  (leaf projection :short-name "on x-axis" :bindings ((?axis . x) (?vector . (momentum ?body))) :tutorial "Projection Equations")
	  (leaf projection :short-name "on y-axis" :bindings ((?axis . y) (?vector . (momentum ?body))) :tutorial "Projection Equations")
	  )
  )
(group "Use information specific to this problem"
  (leaf equals :short-name "Equivalent distances" :bindings ((?quant1 . (distance ?body :time ?time))) :tutorial "Equivalent quantities")
  (leaf given-fraction :short-name "Fraction of" :tutorial "Fraction of")
  (leaf sum-times :short-name "Sum of times" :tutorial "Sum of times")
  (leaf sum-distances :short-name "Sum of distances" :tutorial "Sum of distances")
  (leaf pyth-thm :short-name "Pythagorean Thm" :tutorial "Pythagorean Theorem")
  (leaf unit-vector-mag :short-name "length of unit vector") 
  (leaf connected-accels :short-name "Connected accelerations" :tutorial "Equal accelerations")
  (leaf connected-velocities :short-name "Connected velocities" :tutorial "Equal velocities")
  (leaf complimentary-angles :short-name "Complimentary angles")
  (leaf supplementary-angles :short-name "Supplementary angles")
  (leaf tensions-equal :short-name "Equal tensions at both ends" :tutorial "Equal tensions at both ends")
  (leaf rmag-pyth :short-name "Position mag from components" :tutorial "Pythagorean Theorem")
  (leaf rdiff :short-name "Relative Position from coordinates" :bindings ((axis . ?x)))
  (leaf rdiff :short-name "Relative Position from coordinates" :bindings ((axis . ?y)))
  (leaf area-of-rectangle :short-name "Area of a rectangle")
  (leaf area-of-rectangle-change :short-name "time derivative of formula for area of rectangle (constant width)"	)
  (leaf area-of-circle :short-name "Area of a circle")
  (leaf circumference-of-circle-r :short-name "Circumference of a circle")
  (leaf circumference-of-circle-d :short-name "Circumference of a circle")
  (leaf volume-of-cylinder :short-name "Volume of a cylinder")
  (leaf mass-per-length-eqn :short-name "mass per unit length defined")
  (leaf turns-per-length-definition :short-name "turns per unit length defined")
  (leaf average-rate-of-change :short-name "Average rate of change")
  )
))

#|
(defun principles-leaf-string (name &keys short-name bindings tutorial)
 (format nil "LEAF~C~A ~A~C~A~C~@[~A~]" \#tab 
(psmclass-eqnformat (lookup-psmclass name)) short-name
(if bindings (list name bindings) name) tutorial

(defun chomp (x)
 (if (eq (first x) 'group)
  (mapcar #'chomp (cddr x))
 (format t "~(~A~%  ~S~) \"~A\"~%" (second x) (third x) (fourth x))))
 
(mapcar #'chomp *principle-tree*)
|#