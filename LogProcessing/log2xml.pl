# log2xml -- convert ANDES log file into PSLC Datashop XML format
#
# USAGE:
# Reads one log file argument; generates one event file.  
# USAGE:  perl log2xml.pl filename.log
#       => filename.xml
#
# Uses the following files from its working directory:
#   class.xml -- class element to copy into logs
#   dataset.txt -- contains dataset name
######################################################################

# set the following variable to include only learning-curve related
# events. For Adaeze's program.
$lc_events_only = 0;

# globals for current log line
my ($timestamp, $event, $argstr); 

# hashes used to check set membership and also
# map log event-name to type code 

%checkrequests = ( # helpsys calls returning status for feedback
	"assert-object", "Body",
	"assert-compound-object", "Body",
	"assert-x-axis", "Axes",
	"lookup-vector", "Vector", 
	"lookup-force", "Vector",
	"lookup-torque", "Vector",
	"label-angle", "Angle",
	"define-variable", "Variable",
	"lookup-eqn-string", "Equation",
	"check-answer", "Answer",
	"lookup-mc-answer", "Answer",
);
%helprequests = (	# 
	"Get-Proc-Help", "NextStepHelp",
	"Explain-More", "Explain-Further",
	"Why-wrong-object", "Whats-Wrong",
	"Why-wrong-equation", "Whats-Wrong",
);
%calcrequests = (
	"solve-for-var", "Solve",
	"calculate-equation-string", "Simplify",
);
%queries = (
	"Q", "Sought",   # used Query-Sought etc when we used major event type HINT_MSG
	"P", "Principle", # Query prefix unneeded when use event type QUERY
	"E", "Equation",
);
%idmap = ();

$call_counter = 0;			# counter for unique event ids

# for date manipulation:
use Time::Local;
%month2num = ( # map 3-letter month names to 0-based month numbers
  "Jan"=>0, "Feb"=>1, "Mar"=>2, "Apr"=>3, "May"=>4, "Jun"=>5, 
  "Jul"=>6, "Aug"=>7, "Sep"=>8, "Oct"=>9, "Nov"=>10, "Dec"=>11); 

$time_zone = "US/Eastern";	# fixed, hardcoded time_zone for now

############################################################################
# Processing begins here:
############################################################################

# Process command line args:
# for now, require exactly one filename argument. 
$srcfile = $ARGV[0];
$outfile = substr($srcfile, 0, rindex($srcfile, ".")) . ".xml";
open(OUT, ">$outfile") || die "Couldn't open $outfile for writing. $!";
select(OUT);

# print "Source Log: $srcfile\n\n"; 

# print header information
print <<END_HEADER;
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE tutor_related_message_sequence SYSTEM 
"http://learnlab.web.cmu.edu/dtd/tutor_message_v4.dtd">

<tutor_related_message_sequence version_number="4">
END_HEADER

# main loop over each line 
while (<>) {
    next if /^#/;  # skip log header lines 
    chomp($_); 
    s/\r$//;   # delete dangling CR's remaining from Unix to DOS conversion

    # use flag to ignore calls within Check-Entries block 
    if (/Check-Entries ([01])/) { $rechecking = $1; }
    next if ($rechecking);

    # skip a line before start of each new helpsys "transaction"
    if ((/DDE /) or (/DDE-POST /)) { print "\n"; } # remote function or procedure call

    # for debugging, list ALL DDE-related source lines as comments. Includes commands from helpsys to
    # workbench marked DDE-COMMAND, and also DDE-FAILED notifications. 
    if (/DDE/) { print "<!-- $_ -->\n"; }
 
   # for convenience, split line into global timestamp, event name, and event argument string
   ($timestamp, $event, $argstr) = split("[\t ]", $_, 3); 

   # pick up the Andes-generated session id from appropriate call. Extract start time from it.
   if (/set-session-id "([^"]*)"/) {
	      $session_id = $1;
              # id is of form m081122-Sep27-13-21-48
	      ($user, $monthdate, $hours, $min, $sec) = split('-', $session_id);
	      ($monthabbr, $mday) = ($monthdate =~ m/([A-Z][a-z]+)([\d]+)/); 
	      #print STDERR "$session_id => $user, $monthabbr, $day_of_month, $hour, $min, $sec\n";
	      # get start time in time() format seconds since the epoch
	      $year = 2005; # !!! need to get log year, perhaps from header line
	      # treat this as a local time zone spec and canonicalize to epoch seconds GMT.
	      # NOTE: any variable named *_time is in this canonical format.
	      $start_time = timelocal($sec,$min,$hours,$mday,$month2num{$monthabbr},$year-1900);
              # datashop wants "yyyy-MM-dd HH:mm:ss z". We format it in the local time zone.
	      $start_date = sprintf("%d-%02d-%02d %02d:%02d:%02d", 
		                    $year, $month2num{$monthabbr}+1, $mday, $hours, $min, $sec);
	      print STDERR "start time: " . localtime($start_time) . " = $start_date\n";
   }

   # pick up the problem name from the read-problem-info call
   if (/read-problem-info "([^"]*)"/) {
       # Standalone Andes can have multiple problems in a single Andes session log
       # Looks like we need a new context message id for each of these, since context message 
       # includes problem [check if this is correct?]. 
       if ($problem)     # have already opened a problem this session
       {
	   $context_id = "$session_id-$timestamp"; # new context id appends time offset within session
	   print STDERR "new context id = $context_id\n";
       } else {
	   $context_id = $session_id;
       }
       $problem = $1;

       # OK, we now have enough to put out the context (formerly "dataset") message. 
       # We can also include the class information, which we have to get from an external file.
       # !!! time_zone is hardcoded
       print <<END_CONTEXT_HDR;
  <context_message context_message_id="$context_id" name="START_PROBLEM">
      <meta> <user_id>$user</user_id> <session_id>$session_id</session_id> 
             <time>$start_date</time> <time_zone>$time_zone</time_zone></meta>
END_CONTEXT_HDR
      # copy course information element from external file, if it exists
      if ( open (CLASSINFO, "class.xml")) {
	   while ($line = <CLASSINFO>) {
			 # for consistent Unix style output, change DOS CRLF to LF alone
			 $line =~ s/\r//;   
			 print OUT "        $line";
	   }
           close CLASSINFO;
      }
      # copy dataset element from external file
      open (DATASET, '<', 'dataset.txt') or die "Could not open dataset.txt: $!";
      $DataSet= <DATASET>;      
      chomp($DataSet);
      $DataSet =~ s/\r//;   
      print <<END_DATASET;
      <dataset> <name>$DataSet</name>
	   <level><name>Problem</name>
	       <problem><name>$problem</name></problem>
	    </level>
      </dataset>
END_DATASET
      close DATASET;
      print "    </context_message>\n";
   }
   # end of log header cases.

  # following switches on log event. Not really necessary to code it this way. 
  for ($event)    # binds $_ to event name only for matching. NB want exact matches
  {

   # there are two types of calls to the help system: DDE is a function call which expects a return value, 
   # DDE-POST is like a procedure call, for which no value is returned. We keep a counter on all calls to
   # generate unique ids.  We save id into $transaction_id on DDE's so we can find it when result arrives,
   # because occassionally a DDE-POST can intervene between call and result.
   if (/^DDE$/ or /^DDE-POST$/) {
	$call_counter += 1;
   }
  
   ####################################################################
   #  Any DDE call to help system starts a transaction
   #  record transaction info for later classification and printing
   #  once the response comes back
   ####################################################################
   if (/^DDE$/)   # process call to the help system which starts a transaction
   {
	    # split functionname and parameter list from argstr of form "(functionname arg1 arg2 arg3)". 
	    # Note individual args can contain spaces.
	    $terms = substr($argstr, 1, rindex($argstr, ")")-1); #extract text between ()'s
	    ($api_call, $params) = split(" ", $terms, 2);

	    # classify the Helpsys call and remember.
            $helpreq = $helprequests{$api_call};
	    $checkreq = $checkrequests{$api_call};
	    $calcreq = $calcrequests{$api_call};
	    if ($api_call eq "handle-student-response") {
	        $cancel_response = $params =~ /Cancel/;
	        $query_response =  not $cancel_response;
	    } else { $cancel_response = $query_response = ""; }
	    # must save query type (sought, principle, equation) for which this student submission is a response at time of submssion event, 
	    # since help sys reply to this may contain a new query of different type, e.g. principle, overwriting $last_query_type. We are
	    # printing this transaction after both request and reply are complete, so need the original. 
	    $responses_query_type = $query_response ? $last_query_type : "";

	    # clear records for current transaction
	    %assocs = ();  # hash in which we collect tagged assocs, plus other attributes
	    $hint = "";    # hint associated with this call
	    # anything other than explain more command resets the hint sequence counter
	    # !!! what about responses to next step help prompts? handle-student-response
	    if ($api_call ne "Explain-More") {
		    # print "event=$api_call so hint_number=0\n";
		    $hint_number = 0;
	    }
	    # Save id of call currently pending result
	    $transaction_id = $call_counter;
	    # calculate event time stamp from start time plus session offset
	    if ($timestamp =~ m/^([\d]+):([\d]+)$/) {
		    $session_secs = 60*$1 + $2;
	    } elsif ($timestamp =~ m/^([\d]+):([\d]+):([\d]+)$/) {
	            $session_secs = 3600*$1 + 60*$2 + $3;
	    } else {print STDERR "Couldn't parse time stamp string: |$timestamp|!\n"; }
	    $event_time = $start_time + $session_secs;
            # datashop wants "yyyy-MM-dd HH:mm:ss z". We format it in the local time zone.
	    # !!! possible dst issue? We don't log whether dst is in effect. 
            ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday) = localtime($event_time);
	    $date = sprintf("%d-%02d-%02d %02d:%02d:%02d", $year+1900, $mon+1, $mday, $hour, $min, $sec);

	    # parse API call arguments, extracting element $id (for use as "selection") 
	    # and leaving remaining arguments in $input
	    &ParseAPICall();
   } # end if DDE Helpsys command

   ####################################################################
   #  Command from helpsys to workbench. Contains assocs within transaction
   ####################################################################
   elsif (/DDE-COMMAND/) {
	# in DDE commands, collect assocs for current call
	# Correct entries have: 
	# DDE-COMMAND assoc step (VECTOR (AT (DISPLACEMENT KANGAROO) (DURING 1 2)) (DNUM 90 deg))
        # DDE-COMMAND assoc op DRAW-DISPLACEMENT-STRAIGHT
	# Incorrect entries also have:
	# DDE-COMMAND assoc entry (VECTOR (AT (DISPLACEMENT KANGAROO) 1) (DNUM 90 deg))
	# DDE-COMMAND assoc error VECTOR-TIME-INSIDE-CORRECT-TIME
	# Equation entries:
        # DDE-COMMAND assoc parse (= foo bar)
	# assocs for hint ids have no tag, but simply
	#         assoc (NSH PROMPT-GIVENS ...)
	#         assoc (IEA PLATONIC PROMPT) 
	#         assoc DEFAULT-SIGN-ERROR
	   if ($argstr =~ /assoc ([a-z]+) (.+$)/) {	# tagged assoc: index by tag
		$assocs{$1} = $2;
	   } elsif  ($argstr =~ /assoc (.+$)/) {		# untagged assoc
		$assocs{"hint_id"} = $1; 
		# strip quotes which occur in minilesson operator hint ids (only place??)
		# since hint ids go into quoted xml attribute values
		$assocs{"hint_id"} =~ s/\"//g;	
		# for operator hints, pull out rule name if we can find it in form like
                # assoc (OPHINT POINT STRING (COMPO-PERPENDICULAR Y 90 (ACCEL BLOCK) 1))
		if ($assocs{"hint_id"} =~ /^\(OPHINT [A-Z-]+ [A-Z-]+ \(([A-Z-]+) /) {
		    $assocs{"hint_op"} = $1;
		    # print STDERR "Found ophint for '$1'\n";
		}
	   } elsif  ($argstr =~ /set-score (.+$)/) {	# set score command
		$assocs{"score"} = $1;
	   } else {
	       print STDERR "Unprocessed helpsys command: $argstr\n";
	   }
    }

    ####################################################################
    #  Response to entry or help request -- end of a transaction
    #  which may contain hint 
    ####################################################################
    elsif (/^DDE-RESULT$/ and ($checkreq or $helpreq or $query_response)) 
    {
	# extract from vertical bar delimiters and split
	$argstr =~ s/\|([^|]*)\|.*$/$1/;
	($result, $cmdmsg) = split(/!/, $argstr, 2);
	# translate status result to feedback and show
	# may need to split result from semi-colon-delimited list of flag fields
	($status, $error_fields) = split(/;/, $result);
	if ($status eq "T") {
		$evaluation = "CORRECT";
	} elsif ($status eq "NIL") {
		$evaluation = "INCORRECT";
	} elsif ($cmdmsg =~ /^show-hint/) {
		$evaluation = "HINT";
	} else { $evaluation = "" };
	# set event type for tutor reply based on type of initiating student request
	if ($helpreq) { 
		$event_type = "HINT_MSG";
		$evaluation = "HINT";
	} elsif ($query_response) { # treat non-cancel query response like Explain-More
		$event_type = "HINT_MSG";
		$evaluation = "HINT";
	}
	else { $event_type = "RESULT"; }

	# check for hint message in result. Note hint may be attached to submission result, OR the
	# result of an explicit hint request.
	$hint = $followups = $last_query_type = $subtype_attr = ""; # clear defaults until hint found
	if ($cmdmsg) { 
	    ($cmd, $cmdargstr) = split(' ', $cmdmsg, 2);
	    if ($cmd eq "show-hint") {  	# response contains a hint
	    	if (($tilde = rindex($cmdargstr, '~')) eq -1) {
		    $hint = $cmdargstr;
		    $followups = "";
		} else { 
		    $hint = (substr($cmdargstr, 0, $tilde)); 
		    $followups = (substr($cmdargstr, $tilde+1)); 
	            if ($followups =~ /[QPE]/) {
			# hint is a query, for sought quantity (Q), first principle (P) or
			# intended equation (E).  Indicate in subtype
			$last_query_type = $queries{$followups};
			$subtype_attr = "subtype=\"Ask-" . $last_query_type . "\"";
			# Do we want major type to be HINT_MSG or new type QUERY?
			# $event_type = "QUERY";
		    } 
		    # !!!! a few responses have custom menus with OK or Yes/No choice in it. 
		}
		fixhint();
	    } elsif ($cmd eq "show-lesson") {
		$event_type = "MINILESSON";
		$hint = $cmdargstr;
	    } else { print "<!-- WARNING! $timestamp: unprocessed result cmd: $cmd $cmdargstr-->\n"; }
        }
        if ($hint) { # hint info must be attached to the "evaluation" element, even if no other evaluation.
	    $hint_number += 1;
	    $hint_attrs = "current_hint_number=\"$hint_number\"";
	    if ($assocs{"hint_id"}) { 
	        $hint_attrs .= ' hint_id="' . $assocs{"hint_id"} . '"'; 
	    }
	    # if no followups, then indicate terminal hint by setting hints_available to hint_number.
	    # NOTE: not all terminal hints are giveaway hints, only those in response to help requests are.
	    if (! $followups) { $hint_attrs .= " total_hints_available=\"$hint_number\""; }
	} else { $hint_attrs = ""; }

	# OK ready to print 

        # now that we have the reply, print the tool message that initiated the transaction. 
	# However: may set the selection and possibly input to semantic events
        &print_tool_msg();	

        # now print the tutor message showing the tutor's response with evaluation and/or hint
	&print_context_hdr("tutor_message");
	print "        <semantic_event transaction_id=\"$transaction_id\" name=\"$event_type\" $subtype_attr/>\n";
	# repeat the input event descriptor(s). !!! For hints and errors, we are supposed to show 
	# the "desired" input event, not the actual input event here. 
	# We are just repeating the input event here for all entries, even incorrect ones.
	# And we don't show desired events at all for hints, even in cases like whatswrong help 
	# messages where it could be known. 
	# Now leave this out since the "desired" stuff is specified in the interpretation and
	# Alida can't handle both.
	# if ($checkreq) { &print_entry_event(); }
	# show evaluation and possible hint text
	print "        <action_evaluation $hint_attrs>$evaluation</action_evaluation>\n";
	if ($hint) {print "        <tutor_advice>$hint</tutor_advice>\n"; }

	# list the skills used if we know them
	if ($assocs{"op"}) {
	    @ops = split(',',  $assocs{"op"});
	    for ($i = 0; $i < @ops; $i++) {
		$skill = $ops[$i];
		print "        <skill><name>$skill</name></skill>\n";
	    }
	} elsif ($assocs{"hint_op"}) { # list operator for hint if known
	    $skill = $assocs{"hint_op"};
	    print "        <skill><name>$skill</name></skill>\n";
	} 

	    # for entries dump the interpretation info if we have it. 
	    # we have an interpretation if have target step (correct or incorrect entry)
	    # or have an error handler with possibly no target step.
	    if ($assocs{"step"} or $assocs{"error"})    # have target step or error id.
	    {		
		print "        <interpretation chosen=\"true\">\n";
		$interp_started = 1;
	    }

	    if ($assocs{"step"} and $assocs{"op"}) # have a correct target step for entry
	    {
		print "          <correct_step_sequence>\n";
		@steps = split(',', $assocs{"step"});
		@rules = split(',',  $assocs{"op"});
		for ($i = 0; $i < @steps; $i++) {
		    $step = $steps[$i];
		    $rule = $rules[$i];
		    print "            <step>\n";
		    print "                 <step_info>$step</step_info>\n";
		    print "                 <rule>$rule</rule>\n";
		    print "            </step>\n";
		}
		    print "          </correct_step_sequence>\n";
	    } 
	    # take out unknown
	    #elsif ($checkreq)  # still must print something for all entries.
	    #{
	    #	print "          <correct_step_sequence>\n";
	    #	print "            <step>\n";
	    #	print "                 <step_info>Unknown</step_info>\n";
	    #	print "                 <rule></rule>\n";
	    #	print "            </step>\n";
	    #	print "          </correct_step_sequence>\n";  
	    #}
	    if ($assocs{"error"}) # have an error handler, at least.
	    {
		    print "          <incorrect_step_sequence>\n";
		    @rules = split(',',  $assocs{"error"}); # error id
		    @steps = split(',', $assocs{"entry"});  # actual step representation
                    # "step" in this case codes user's incorrect entry. "rule" is 
		    # the error handler that matched it (~= buggy rule). 
		    # Unparseable input may get error tag (syntax error, undefined vars)
		    # but no step, so iterate over rules in this case.
		    # !!! Think there should be one element at most in these.
		    for ($i = 0; $i < @rules; $i++) {
			$step = $steps[$i];
			$rule = $rules[$i];
		        # if we don't have any actual step representation, must generate
		        # one. Use parse for equations if we have it, else raw.
			# Note can't get rule sequence without a matching step sequence, so
			# there should always be exactly one rule [=error id] in this case
		        if (! $step) {
			     if ($assocs{"parse"}) {
				   $step = "(EQN " . $assocs{"parse"} . ")";
			     } else {
				   $step = $input; # last raw input we recorded
			     }
		        }

			print "            <step>\n";
			print "                 <step_info>$step</step_info>\n";
			print "                 <rule>$rule</rule>\n";
			print "            </step>\n";
		    }
		    print "          </incorrect_step_sequence>\n";
	    }
	    if ($interp_started) {
		print "        </interpretation>\n";
		$interp_started = 0;
	    }

	    # add custom fields for parse and score, if we have them.
	    if ($assocs{"parse"}) {
	       $value = $assocs{"parse"};
	       print "        <custom_field> <name>parse</name>\n";
	       print "                       <value>$value</value>\n";
	       print "        </custom_field>\n";
	    }
	    if ($assocs{"score"}) {
	       $value = $assocs{"score"};
	       print "        <custom_field> <name>score</name> <value>$value</value> </custom_field>\n"
	    }
	    print "    </tutor_message>\n";      # close the message

	    # transaction completed: reset event type flags
	    $helpreq = "";
	    $checkreq = "";
	    $calcreq = "";
	    $query_response = "";
	    $cancel_response = "";
    }
    ####################################################################
    #  Empty helpsys response to Cancel transaction
    ####################################################################
    elsif (/DDE-RESULT$/ and $cancel_response) {
	# print the tool message that initiated the transaction
        &print_tool_msg();
	# transaction completed: reset event type flags
	$helpreq = "";
	$checkreq = "";
	$calcreq = "";
	$query_response = "";
	$cancel_response = "";
    }
    ####################################################################
    #  Response to a calc request -- ends a transaction
    ####################################################################
    elsif (/^DDE-RESULT$/ and $calcreq)  # response to calc request
    {
	# print the tool message that initiated the transaction
        &print_tool_msg();

	# result is of form equation!hint where each part is optional.
	$argstr =~ s/\|([^|]*)\|.*$/$1/;
	($result, $hint) = split(/!/, $argstr, 2);
	if ($hint) # set hint variables just as for help request
	{
	    	$hint_number += 1;
	    	$hint_attrs = "current_hint_number=\"$hint_number\"";
	    	if ($assocs{"hint_id"}) { $hint_attrs .= ' hint_id="' . $assocs{"hint_id"} . '"'; }
	        # if no followups, then indicate terminal hint by setting hints_available to hint_number.
	        if (! $followups) { $hint_attrs .= " total_hints_available=\"$hint_number\""; }
	} 
	else { $hint_attrs = ""; }
                                                                                                      
	&print_context_hdr("tutor_message");
	print <<CALC_RESULT_HDR;
	<semantic_event transaction_id="$transaction_id" name="CALC_RESULT"/>
CALC_RESULT_HDR
	if ($result) {
		# leave off the result selection, it may confuse things
		#print "        <event_descriptor> <selection>$calcdst</selection>\n";
		print "        <event_descriptor> "; 
		print "               <input>$result</input>\n";
		print "         </event_descriptor>\n";
                print "        <action_evaluation $hint_attrs>CORRECT</action_evaluation>\n";    
	}
	else {
                print "        <action_evaluation $hint_attrs>INCORRECT</action_evaluation>\n";    
	}

	if ($hint) {
		print "        <tutor_advice>$hint</tutor_advice>\n"; 
	}
	# !!! some place to log success/failure difference.
	print "    </tutor_message>";
    }
    ####################################################################
    #  Deletions. Normally sent as DDE-POST -> No helpsys response.
    ####################################################################
    elsif (/^DDE-POST$/ and $argstr =~ m/\(delete-object ([^ ]*) (.*)\)/) {
 	($label, $id) = ($1, $2);
	if (! $lc_events_only) {
 		&print_context_hdr("tool_message");
 		print <<END_DELETION;
 	<semantic_event transaction_id="$call_counter" name="DELETION"/>
         <event_descriptor><selection>$id</selection>
 	   <action>Delete</action><input>label=$label</input>
 	 </event_descriptor>
     </tool_message>
END_DELETION
	}
	#&remove_step_entry($id);
     }
     # equation deletions sent as post of empty string. Note we are not sure this is
     # really a deletion of anything, i.e. we don't know if there was any text there before.
     elsif (/^DDE-POST$/ and $argstr =~ m/\(lookup-eqn-string "" ([\d]+)\)/) {
 	$id = $1;
	if (! $lc_events_only) {
 		&print_context_hdr("tool_message");
 		print <<END_EQ_DELETION;
 	<semantic_event transaction_id="$call_counter" name="DELETION"/>
         <event_descriptor><selection>$id</selection><action>Delete</action></event_descriptor>
     </tool_message>
END_EQ_DELETION
	}
 	# &remove_step_entry($id);
     }
    ####################################################################
    #  Hint dismissals. No helpsys response
    ####################################################################
    elsif (/Hint-Hide/) {	       
	# log this UI event somehow?
    }
    # note empty help sys response to a Cancel is just being ignored.
  } # end for event
} # end loop for each input line

# end of file processing 
print "</tutor_related_message_sequence>\n";
close(OUT);

#--------------------------------------------------------------
# print message header with context info boilerplate
# arg is "tutor_message" or "tool_message"
# Takes values from globals, incluiding $date for msg time
# -------------------------------------------------------------
sub print_context_hdr
{
    my $msgtype = $_[0];
    print <<END_TOOL_MSG_HDR;
    <$msgtype context_message_id="$context_id"> 
        <meta> <user_id>$user</user_id> <session_id>$session_id</session_id> 
               <time>$date</time> <time_zone>$time_zone</time_zone></meta>
	<problem><name>$problem</name></problem>
END_TOOL_MSG_HDR
}


#--------------------------------------------------------------
# print semantic event descriptors for an entry ("ATTEMPT")
#
# Notes: 
# -Can generate a list of events
# -if target step is unknown, we just print "unknown"
# Could also fall back to using the UI selection in this case
# -This is currently used to fill in the "desired" event in the
# tutor message -- even if the input listed is incorrect!
#
# This uses "fake" selection method.
# -------------------------------------------------------------
sub print_entry_event_fake
{
	# answer submissions are special in that we can use the selection id directly
	if ($checkreq eq "Answer") {
		print <<END_OF_ANSWER
	<event_descriptor>
		<selection>$id</selection>
		<input>$input</input>
	</event_descriptor>
END_OF_ANSWER
	} else {
            # extend input to include id, since we are not showing it in selection 
            $InputXML = "<input>id=$id;$input</input>";

            # if correct: we have step and op lists
	    # if incorrect: we have error tag and may have entry or parse as actual input
	    #               and may have step and op lists for target entries if known.
	    # Either way, "step" is target step so log that as "Selection".
	    @steps = split(',', $assocs{"step"});
	    if (@steps) {
	      	for ($i = 0; $i < @steps; $i++) { # list one event descriptor per step
		    $step = $steps[$i];
		    # only want to show newly entered cognitive steps
		    # if (! @stepentries{$step}) 
		     {
		         print <<END_OF_ENTRY;
        <event_descriptor> 
	        <selection>$step</selection>
		$InputXML
        </event_descriptor>
END_OF_ENTRY
		    } 
		    # add current entry to step's entry list
		    # push(@stepentries{$step}, $id);
              	} 
	    } else {      # no target step list on this entry
		print <<END_OF_ENTRY2;
        <event_descriptor> 
	        <selection>Unknown</selection>
		$InputXML
        </event_descriptor>
END_OF_ENTRY2
	     }
	}
}

sub print_entry_event_real
{
	print <<END_OF_ENTRY;
        <event_descriptor> 
	        <selection>$id</selection>
		$InputXML
        </event_descriptor>
END_OF_ENTRY
}

sub print_entry_event
{
	# comment in or out to choose behavior
	&print_entry_event_real();
	#& print_entry_event_fake();
}

#--------------------------------------------------------------
#  print the tool message initiating the current transaction
#
#  uses global vars set on transaction initiation, esp
#  $id, $input
#--------------------------------------------------------------
sub print_tool_msg
{	    
        if ($id ne "") { $SelectionXML = "<selection>$id</selection>"; } 
	else { $SelectionXML = ""; }
	if ($input ne "") { $InputXML = "<input>$input</input>"; }
	else {$InputXML = ""; }

	# all tool messages begin with the context header:
	&print_context_hdr("tool_message"); 
        
	# semantic event and event descriptor depend on message type:
	if ($checkreq)      # entry submission
        { 
	    print <<END_OF_ENTRY_START;
	<semantic_event transaction_id="$transaction_id" name="ATTEMPT" subtype="$checkreq"/>
END_OF_ENTRY_START
	    &print_entry_event_real();
	}
	elsif ($helpreq)    	# help-request generating command 
	{
	    # include selection on Whats-Wrong help.
	    # !!! should we use semantic selection id on whatswrong help? Could be multiple.
	    $SelectionXML = "";
	    if ($helpreq eq "Whats-Wrong") {
		$SelectionXML = "<selection>$id</selection>";
	    } 
	    print <<END_HINT_REQUEST
        <semantic_event transaction_id="$transaction_id" name="HINT_REQUEST" subtype="$helpreq"/>
        <event_descriptor>$SelectionXML$InputXML</event_descriptor>
END_HINT_REQUEST
        } 
	elsif ($calcreq) 	# calculate request
	{	
	    # Note "selection" here is destination box. For simplify command, source box
	    # might be better, but we never logged it!
	    ($input, $selection) = split(' ', $params);
	    # save destination for use on return value
            $calcdst = $selection;
	    print <<END_OF_CALC_MESSAGE;
	<semantic_event transaction_id="$transaction_id" name="CALC_REQUEST" subtype="$calcreq"/>
        <event_descriptor><selection>$selection</selection>
	        <input>$input</input> 
	</event_descriptor>
END_OF_CALC_MESSAGE
	}
	elsif ($query_response)  # response to helpsys query 
	{       
		print <<END_QUERY_RESPONSE;
	<semantic_event transaction_id="$transaction_id" name="HINT_REQUEST" subtype="Choose-$responses_query_type"/>
       <event_descriptor><input>$params</input></event_descriptor>
END_QUERY_RESPONSE
	} 
	elsif ($cancel_response) 	# cancel dialog at a help sys query
	{
		if (! $lc_events_only) { # for lc-only, ignore CANCEL events
			print "	<semantic_event transaction_id=\"$call_counter\" name=\"CANCEL\"/>";
		} else {
			# !!! tool-message containing empty event will be printed around this
		}
	} # end case response to helpsys query

    	# close the tool message
    	print "    </tool_message>\n";
} # end print_tool_msg

sub remove_step_entry {
	my $entryid = $_[0];
	my @new_elist;

        foreach $step (keys(%stepentries)) {
	    @old_elist = @$stepentries{$step};
	    # assemble new entry list for this step
	    foreach $entry (@old_elist) {
	      if ($entry ne $entryid) {
		push(@new_elist, $entry);
	      }
	    }
	    $stepentries{$step} = \@new_elist;
	}
}

# remove hypertext tags from string in $hint
sub fixhint() {
	# get text from "{\d text...}{\v junk...}"; or \l in place of \d
	# lbrace bslash tag sp (text) till rbrace (min) bracketed stuff (min)
	$hint =~ s/\{\\[dl] ([^}]*?)\}\{[^}]*?\}/$1/g;
	# for legal xml:
	$hint =~ s/&/&amp;/g;
	$hint =~ s/</&lt;/g;
	$hint =~ s/>/&gt;/g;
}

sub SplitLispArgs # parse a lisp arg str into array 
{
	my $argstr = $_[0];
	my @args = ();		
	while ($argstr =~ /  (\"[^"]*?\")  #" # quoted string. 
	                   | (\([^)]*?\))  # paren'ed sublist 1-level only
			   | \|([^|]*)?\|  # vbar-delimited symbol, no delims
			   | (\S+)	    # non-space token
	                 /gx) {
		push (@args, $+);
	}
	#print "Lispargs: ", join(", ", @args), "\n";	
	return @args;
}

# parse helpsys API call parameters from $params, 
# setting $id and $input to "Selection" id and
# remaining argument string, respectively
sub ParseAPICall {
	my(@args) = &SplitLispArgs($params);
   
	# use $t to avoid conflicts w/global $timestamp.
  for ($api_call) {
   if (/^define-variable$/) {
		($label, $subtype, $quant, $body, $t, $agent, $id) = @args;
		if ($quant eq "Force") {
			$type =~ s/\s+$//;  # trailing white space due to bug
		} 
		$input = "label=$label;quant=$quant;subtype=$subtype;body=$body;agent=$agent";
   } elsif (/^assert-object$/ or /^assert-compound-object$/){
		($label, $body, $t, $id) = @args;
		$input = "label=$label;body=$body;time=$t";
   } elsif (/^assert-x-axis$/) {
        ($body, $dir, $id, $x_label, $y_label, $z_label) = @args;
	$input = "body=$body;dir=$dir;x_label=$x_label;y_label=$y_label;z_label=$z_label";
   } elsif (/^lookup-vector$/) {
        ($label, $agent, $type, $object, $dir, $mag, $t, $id) = @args;
	$input = "label=$label;type=$type;body=$object;agent=$agent;time=$t;dir=$dir;mag=$mag";
   } elsif (/^lookup-force$/) {
       ($label, $type, $object, $agent, $dir, $mag, $t, $id) = @args;
	$input = "label=$label;type=Force;body=$object;agent=$agent;forcetype=$type;time=$t;dir=$dir;mag=$mag";
   } elsif (/^lookup-torque$/) {
       ($label, $type, $object, $axis, $dir, $mag, $t, $id) = @args;
       $input = "label=$label;type=$type;body=$object;axis=$axis;time=$t;dir=$dir;mag=$mag"; 
   } elsif (/^label-angle$/) {
	($label, $degrees, $id_side1, $id_side2, $id, $axis_part) = @args;
	$input = "label=$label;degrees=$degrees;id_side1=$id_side1;id_side2=$id_side2;axis_part=$axis_part";
   } elsif (/^define-angle-variable$/) { 
	 ($label, $degrees, $label1, $label2, $id) = @args;
	 $input = "label=$label;degrees=$degrees;side1=$label1;side2=$label2";
   } elsif (/^check-answer$/) {
        ($input, $id) = @args;
   } elsif (/^lookup-eqn-string$/) {
	($input, $id) = @args;
   } elsif (/^Why-wrong-object$/) {
	($label, $id) = @args;
	#$input = "";  # no "input" for a help request
	$input = "label=$label";
   } elsif (/^Why-wrong-equation$/) {
         ($id) = @args;
	 $input = ""; # no "input" for a help request
   } else { # any other help system call
	 #print STDERR "Unparsed API call: $timestamp $api_call $params\n";
	 $id = "";
	 $input = $params;
   }
 }# end for binding $_
}
