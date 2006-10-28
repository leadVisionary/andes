#!/usr/bin/perl -w
#
# onelog --- analyze a concatonated sequence of Andes log files
# as retrieved from OLI database query
#
# Usage:     onelog.pl access.csv
#
# OLI's data extraction tool returns the logs as database records in comma 
# separated values form. Which columns are included depends on the query.
# The entire contents of each andes session log file will be included as 
# the last column in one of these database records.  The log file text itself 
# includes CRLFs delimiting lines within it.
#
# So if we asked for date and info fields from the database, the
# combined log file will start with a header column line:
#
# 	time,info
# 
# followed by record lines which look like this:
#
#    	2006-05-04 11:30:04.0,# Log of Andes session begun Thursday, May 04, 2006 11:11:46 by m094530 on 09MOORE-CJ30A
# 	# Version 1
# 	# Help-flags 01f Procedural Conceptual Example
# 	0:00	Andes-Version 10.1.3
# 	0:00	FBD-Version 04 05 06^M
#         ... rest of log1 ...
# 	18:19	END-LOG 
#	
# 	2006-05-04 11:31:34.0,# Log of Andes session begun Thursday, May 04, 2006 11:30:13 by m094530 on 09MOORE-CJ30A
#         ... rest of log2 ...
#        4:40 END-LOG
#
# We pull out contents between the Andes header line and the END-LOG line.

#
#  Impose cutoffs on accepted data points.
#
$score_cut_off=10;  # minimum score to count a problem as attempted
# doesn't contribute
$minimum_problem_attempts=0.5;   # cutoff on list of students
# there is a significant number of problems (not assigned)
# that were only attempted by a few students.  Including these
# might introduce a selection bias.
$minimum_student_attempts=20.5;  # cutoff on list of problems

while (<>) { # loop over andes sessions
    # find (and discard) database header
    if (/^time,info/) {$last_header="";}  # beginning of new file
    next unless /^.* Log of Andes session begun/;  

    # Test that sessions have been sorted by date
    # If the beginning of the file was not marked, could have a
    # false error.
    # use sort-by-time.pl to create a sorted version of the log file.
    $last_header lt $_ or die "Sessions in log file are not sorted.\n";
    $last_header = $_;

    $last_time=0;
    $score=0;
    $loss_of_focus=0;  #accumulate pauses associated with loss of focus
    $intervening_errors=0;
    $intervening_hints=0;
    $last_adjusted_time=0;
    while (<>) {   # loop over lines in Andes session
	last if /\tEND-LOG/;  # end of Andes session
	
	if(/^(\d+):(\d+)\t/ or /^(\d+):(\d+):(\d+)\t/) {
           # total time in seconds
	    $this_time = $3 ? $1*3600+$2*60+$3 : $1*60+$2; 
	    $dt = $this_time - $last_time;
	    $last_time = $this_time;

            # in pause histogram, might ignore pauses associated with 
	    # loss of focus:
	    # next if /\tApp-activate/ or /\tApp-deactivate/;  
	    $dt_histogram{$dt}++;
	    if (/\tApp-activate/ or /\tApp-deactivate/) {
		$loss_of_focus += $dt;
	    }
	} else {
            # silently ignore header lines
	    warn "Time stamp missing for $_\n" unless /^#/;
	    next;
	}

	next unless /\tDDE/;  # skip non DDE lines
	# reset operator list and record time
	if (/\tDDE /) { # student action sent to help system
	    $#operator_list = -1;
	    $adjusted_time = $this_time - $loss_of_focus;
	}
	if (/read-student-info .(\w+)/) {
	    $student = $1;  # session label should start with student id
	}
	elsif (/set-session-id .(\w+)-([a-zA-Z0-9-]+)/) {
	    $session_userid = $1;
	    $date = $2;
	}
	elsif (/read-problem-info .(\w+)/) {
	    $problem = $1;
	    $problem  =~ tr/A-Z/a-z/;  #set to lower case
	}
	elsif (/\tDDE .close-problem/) {
	    $time_used = $this_time;   # calculated above
	    $final_score = $score;     # want most recent score
	}
	elsif (/\tDDE-COMMAND set-score (\d+)/) {
	    $score = $1; 
	}
	# use \S so we don't include newline in names
	elsif (/\tDDE-COMMAND assoc op (\S+)/) {
	  @operator_list = split /,/,$1;
	}
	# This way of doing things does not address the case where 
	# a student tries one thing, fails, and then does (successfully)
	# something else.
	elsif (/\tDDE-RESULT \|NIL\|/) {
	    $intervening_errors++;
	}
	elsif (/\tDDE-RESULT \|!show-hint .*\|/) {
	    $intervening_hints++;
	}
	elsif (/\tDDE-RESULT \|T\|/) {
	    foreach $operator (@operator_list) {
		# this would more naturally be a hash table
		@facts=($intervening_errors,$intervening_hints,
			$adjusted_time-$last_adjusted_time,$problem);
		push @{$mastery{$operator}{$student}}, [ @facts ];
	    }
	    $intervening_errors=0;
	    $intervening_hints=0;
	    $last_adjusted_time = $adjusted_time;
	}	    
    }

    unless ($_) {
	warn "End of file encountered during Andes session\n";
	last;
    }
    # next unless $time_used and $final_score and $student and $problem;
    if ($student ne $session_userid) {
	warn "warning: session label $session_userid doesn't match $student\n";
    }

    # Can't do too much analysis here since a problem might
    # be solved over multiple sessions.
    # Accumulate time used, throwing out time where Andes is not in focus.
    $times{$student}{$problem} += $time_used-$loss_of_focus; 
    $scores{$student}{$problem} = $final_score;
    # problems attempted. Don't bother counting here because
    # a problem might be solved over multiple sessions.
    if($final_score > $score_cut_off) {$problems{$problem}=1}; 
    push @{ $sessions{$student}{$problem}}, $date; # accumulate sessions
}

#
#          Analysis of accumulated data
#
#


# print out score histogram in Mathematica notation
# This is not affected by any of the cutoffs
if(0) {
    foreach $student (keys %times) {
	foreach $problem (keys %{$times{$student}}) {
	    $score_histogram{$scores{$student}{$problem}}++;
	}
    }
    print "\nscorehistogram={";
    foreach $score (sort {$a <=> $b} (keys %score_histogram)) {
	print "{$score,$score_histogram{$score}}",$score<100?",":"";
    }
    print "};\n";
}    
 
# printout histogram of pauses
# This is not affected by any of the cutoffs

if(0) {
    print "pausehistogram={";
    foreach $delay (sort {$a <=> $b} (keys %dt_histogram)) {
	print "{$delay,$dt_histogram{$delay}},";
    }
    print "};\n";
    
    # make a log-log histogram of the pauses
    $step = 10;  #number of steps per decade
    foreach $delay (keys %dt_histogram) {
	next if $delay<1;
	$log_dt_hist{int (0.5 + log($delay)*$step/log(10.0))} += 
	    $dt_histogram{$delay};
    }
    # find bin centers and renormalize to compensate for bin widths
    foreach $i (keys %log_dt_hist) {
	$log_dt_bin{$i}=exp($i*log(10.0)/$step);
	# calculate the number of bins that have been merged.
	$log_dt_hist{$i} /= int(exp(($i+0.5)*log(10.0)/$step))-
	    int(exp(($i-0.5)*log(10.0)/$step));
    }
    # print out log binned pause histogram in Mathematica notation
    print "\nlogpausehistogram={";
    foreach $i (sort {$a <=> $b} (keys %log_dt_hist)) {
	print "{$log_dt_bin{$i},$log_dt_hist{$i}},";
    }
    print "};\n";
}

#    
#  Remove students that solved only a few problems.
#  This should be done semester-wise
foreach $student (sort keys %times) {
    $i=0;
    foreach $problem (sort keys %problems) {
	 if ($times{$student}{$problem} and 
	     $scores{$student}{$problem} > $score_cut_off) {$i++;}
     }
    $problem_attempts{$i}++;
    if($i<=$minimum_problem_attempts) {delete $times{$student};}
}
#  Print number of students that attempted to solve a given number of problems.
if (0) {
    print "problemattempts={";
    foreach $i (sort {$a <=> $b} keys %problem_attempts) {
	print "{$i,$problem_attempts{$i}},";}
    print "};\n";
}
#
#     Remove problems that were solved by only a few students
#  This should be done semester-wise
foreach $problem (sort keys %problems) {
    $i=0;
    foreach $student (sort keys %times) {
	 if ($times{$student}{$problem} and 
	     $scores{$student}{$problem} > $score_cut_off) {$i++;}
     }
    $student_attempts{$i}++;
    if($i<=$minimum_student_attempts) {delete $problems{$problem};}
}
#  Print number of problems solved by a given number of students
if (0) {
    print "studentattempts={";
    foreach $i (sort {$a <=> $b} keys %student_attempts) {
	print "{$i,$student_attempts{$i}},";}
    print "};\n";
}
#
#                        Problem times
#
# print out problem time matrix in CSV format
#
# I used:
#   onelog.pl Fall2005-treacy.dat Fall2005-wintersgill.dat > times-Fall2005.csv
#   onelog.pl Spring2006-treacy.dat Spring2006-wintersgill.dat > times-Spring2006.csv
#
if (0) {
    print " ";
    foreach $problem (sort keys %problems) {print ",$problem";}
    print "\n";
    foreach $student (sort keys %times) {
	print "$student";
	foreach $problem (sort keys %problems) {
	    if ($times{$student}{$problem} and 
		$scores{$student}{$problem} > $score_cut_off) {
		print ",$times{$student}{$problem}";
	    } else {
		print ",";
	    } 
	}
	print "\n";
    }
}

# Print out time, errors, hints for each application of a principle.

if(1) {
    foreach $operator (sort keys %mastery) {
	print "$operator\n";
	@op_time=();
	@op_hints=();
	@op_errors=();
	@op_error_free=();
	@op_students=();
	# using %times includes any cutoff in students
	foreach $student (keys %times) {
	    next unless $mastery{$operator}{$student};

	    # Debug print of raw data
	    if(0) {
		print "  $student\n";
		for $application (@{$mastery{$operator}{$student}}) {
		    print "    @$application\n";
		}
	    }

	    for ($i=0; $i<@{$mastery{$operator}{$student}}; $i++) {
                # include any cutoff on set of allowed problems
		# removing certain problems can cause a "hole" in the arrays.
		# next unless $problems{$mastery{$operator}{$student}[$i][3]};
		$op_errors[$i]+=$mastery{$operator}{$student}[$i][0];
		$op_hints[$i]+=$mastery{$operator}{$student}[$i][1];
		# make sure there are no "holes" in the array
		$op_error_free[$i] or $op_error_free[$i]=0;
		if($mastery{$operator}{$student}[$i][0] == 0 and
		   $mastery{$operator}{$student}[$i][1] == 0) {
		    $op_error_free[$i]++;
		} 
		$op_time[$i]+=$mastery{$operator}{$student}[$i][2];
		$op_students[$i]+= 1;
	    }
	}
	for ($i=0; $i<scalar(@op_students); $i++) {
	    $op_errors[$i] /= $op_students[$i];
	    $op_hints[$i] /= $op_students[$i];
	    $op_error_free[$i] /= $op_students[$i]; 
	    $op_time[$i] /= $op_students[$i]; 
	}
	local $"=",";
	print " avgerrors={@op_errors};\n";
	print " avghints={@op_hints};\n";
	print " avgtime={@op_time};\n";
	print " noassistance={@op_error_free};\n";
	print " nostudents={@op_students};\n";
    }
}
