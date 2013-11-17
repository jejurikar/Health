package DayActivity;

use strict;
use Exporter;

use Interval;

# Below variables are similar to private vars in the class 
# More like a "singleton class", cannot have two objects.
# We can use "real class" to address this
#
my $glbIndex=0;

sub initDayActivity()
{
	my $aref_intervalList= [];
	my $href_initInt = Interval::newInitInterval();
	push (@$aref_intervalList, $href_initInt);

	return $aref_intervalList;
}



# Function: addIntervalAtIndex
#       Add the new interval to the existing list of intervals. The index in the original list is passed. The process can result in the addition of new intervals to the list (i.e. can result in many other intervals or just updation of existing intervals).
# Arguments:
#   $aref_intervalList: the list of all intervals 
#   $index: The index in the intervals where the new interval falls and should be added. 
#   $href_newInt: The new interval with all the params 
#           



sub addIntervalAtIndex($$$)
{
	my ($aref_intervalList, $index, $href_newInt) = @_;

	my $done=0;
	do{
# If the start times are not aligned, align the new interval by splitting the current interval
		my $href_currInt = $aref_intervalList->[$index];
		if($href_currInt->{"time"} < $href_newInt->{"time"}){
			my $leftSize = $href_newInt->{"time"} - $href_currInt->{"time"}; 
# Aligns start time of two intervals
			my $href_newSplitInt = Interval::splitInterval($aref_intervalList->[$index], $leftSize); 
			$index++; 
	                splice(@$aref_intervalList, $index, 0, $href_newSplitInt);
		}

#Now the new Interval and current interval is aligned 
		$href_currInt = $aref_intervalList->[$index];
		if($href_currInt->{"size"} == $href_newInt->{"size"}){
			$href_currInt->{"slope"} += $href_newInt->{"slope"};
			$done=1;
		}
		elsif($href_currInt->{"size"} > $href_newInt->{"size"}){
			my $leftSize = $href_newInt->{"size"} ; 
			my $href_newSplitInt = Interval::splitInterval($aref_intervalList->[$index], $leftSize);
			splice(@$aref_intervalList, $index+1,0, $href_newSplitInt);
			$href_currInt->{"slope"} += $href_newInt->{"slope"}; # combine the interval contributions (slope)
			$done=1;
		}
		else{ # the new interval is longer than the current interval: 
# split the new interval and add contribution to current interval

			$href_currInt->{"slope"} += $href_newInt->{"slope"}; # add contribution to existing interval
			$href_newInt->{"time"} -=  $href_currInt->{"size"};  # reduce the new interval size
			$href_newInt->{"size"} -=  $href_currInt->{"size"};
			$index++; #continue on adding the reamining portion of new interval to the list
		}

	}while(!$done)

}


# function: addInterval
# 	Adds the interval to the daily activity. 
# 	Note: the $glbIndex upto which the day activity is stores (i.e. $glbIndex) is stored.
# 	      This improves the efficiency of the algorithm and we do NOT have to start searching from glbIndex=0
# 	      So no initailization to $glbIndex is seen in this routine.

sub addInterval($$)
{
	my ($aref_intervalList, $href_inputInterval) = @_;

	while($glbIndex < scalar(@$aref_intervalList)){
		my $href_currInt = $aref_intervalList->[$glbIndex];  #$glbIndex is a class member 
# if the input Interval is intersecting the current window,
		if($href_currInt->{"time"} + $href_currInt->{"size"} <= $href_inputInterval->{"time"}){
			$glbIndex++;
		}
		else{
			DayActivity::addIntervalAtIndex($aref_intervalList, $glbIndex, $href_inputInterval);
			last; # break from the while loop;
		}
	}
}



# some test code 
sub incIndex{
    my $OKindex=0;
    print " Ind $OKindex \n" ;
    $OKindex++;
}

1;

