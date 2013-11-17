package DayActivity;

use strict;
use Exporter;

use Interval;

# TODO: Have a common place and "export" the value to other PM files 
my $NORM_SUGAR = 80;
my $NORM_RATE = 60;
my $GLYCATION_LEVEL = 150;
my $MINS_IN_HOUR = 60;


# Below variables are similar to private vars in the class 
# More like a "singleton class", cannot have two objects.
# We can use "real class" to address this
#
my $glbIndex=0;

sub initDayActivity()
{
	my $aref_dayActList= [];
	my $href_initInt = Interval::newInitInterval();
	push (@$aref_dayActList, $href_initInt);

	return $aref_dayActList;
}



# Function: addIntervalAtIndex
#       Add the new interval to the existing list of intervals. The index in the original list is passed. The process can result in the addition of new intervals to the list (i.e. can result in many other intervals or just updation of existing intervals).
# Arguments:
#   $aref_dayActList: the list of all intervals 
#   $index: The index in the intervals where the new interval falls and should be added. 
#   $href_newInt: The new interval with all the params 
#           



sub addIntervalAtIndex($$$)
{
	my ($aref_dayActList, $index, $href_newInt) = @_;

	my $done=0;
	do{
# If the start times are not aligned, align the new interval by splitting the current interval
		my $href_currInt = $aref_dayActList->[$index];
		if($href_currInt->{"time"} < $href_newInt->{"time"}){
			my $leftSize = $href_newInt->{"time"} - $href_currInt->{"time"}; 
# Aligns start time of two intervals
			my $href_newSplitInt = Interval::splitInterval($aref_dayActList->[$index], $leftSize); 
			$index++; 
	                splice(@$aref_dayActList, $index, 0, $href_newSplitInt);
		}

#Now the new Interval and current interval is aligned 
		$href_currInt = $aref_dayActList->[$index];
		if($href_currInt->{"size"} == $href_newInt->{"size"}){
			$href_currInt->{"slope"} += $href_newInt->{"slope"};
			$done=1;
		}
		elsif($href_currInt->{"size"} > $href_newInt->{"size"}){
			my $leftSize = $href_newInt->{"size"} ; 
			my $href_newSplitInt = Interval::splitInterval($aref_dayActList->[$index], $leftSize);
			splice(@$aref_dayActList, $index+1,0, $href_newSplitInt);
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
	my ($aref_dayActList, $href_inputInterval) = @_;

	while($glbIndex < scalar(@$aref_dayActList)){
		my $href_currInt = $aref_dayActList->[$glbIndex];  #$glbIndex is a class member 
# if the input Interval is intersecting the current window,
		if($href_currInt->{"time"} + $href_currInt->{"size"} <= $href_inputInterval->{"time"}){
			$glbIndex++;
		}
		else{
			DayActivity::addIntervalAtIndex($aref_dayActList, $glbIndex, $href_inputInterval);
			last; # break from the while loop;
		}
	}
}


sub printIntervalList($)
{
	my ($aref_dayActList) = @_;

	print "Final list of all intervals: [time, duration, rate] \n";
#print Dumper(@$aref_dayActList);
	foreach my $href_currInt(@$aref_dayActList){
		print ("[$href_currInt->{time}, $href_currInt->{size}, $href_currInt->{slope}]");
	}
	print "\n";
	return;
}


###########################################3
#   Below are all the interval calculations 
#


sub calculateActivityIntervalSugar($$)
{
	my ($href_interval, $startSugar) = @_;

	my $slope = $href_interval->{slope};
	my $time = $href_interval->{time};
	my $size = $href_interval->{size};

#print the beginning of the time=0 interval
# TODO: Not good to have side-effects (printing) in this function.
# To avoid this, store the following with the intervals (startSugar)
# And for the normInervals store the "normIntSize, and maybe the normRate)
	if($time==0){
		print ("$time $startSugar \n");
	}

#compute the sugar level contribution of the interval 
	my $intSugar =  $size * $slope;
	my $endSugar = $startSugar + $intSugar;
	my $endpoint = $href_interval->{time} + $href_interval->{size};

# Compute the glycation of the interval
	my $glycation =0;
	my $glyHours = 0;
	if(($slope > 0) && ($endSugar > $GLYCATION_LEVEL)){
		$glyHours = ($endSugar - $GLYCATION_LEVEL)/$slope;
	} 
	elsif(($slope < 0) && ($startSugar > $GLYCATION_LEVEL)){
		$glyHours = ($GLYCATION_LEVEL - $startSugar)/$slope; # both num and div are negative 
	}

	$glyHours = ($glyHours > $size) ? $size : $glyHours;
	$glycation += $glyHours * $MINS_IN_HOUR;


# print the interval - used to generate the graph 
#TODO: Avoid printing in functions 
	print ("$endpoint $endSugar \n");

	return ($intSugar, $glycation);
}


sub calculateNormIntervalSugar($$)
{
	my ($href_interval, $startSugar) = @_;

	my $slope = $href_interval->{slope};
	my $time = $href_interval->{time};
	my $size = $href_interval->{size};


	my %normInterval = %$href_interval;
	my $href_normInterval = \%normInterval;

# Calc normalization sugar 
	my ($sugar,$glycation);
	$slope = ($startSugar > $NORM_SUGAR) ? -$NORM_RATE : $NORM_RATE;
	my $normIntSize = (abs($startSugar - $NORM_SUGAR))/60;

	$normIntSize = ($normIntSize > $size) ? $size : $normIntSize;
	my $remainIntSize = $size - $normIntSize;

	($sugar, $glycation) = (0,0);
	if($normIntSize){ # non-zero intervals need to be processed
# start remains unchanged
		$href_normInterval->{slope}= $slope;
		$href_normInterval->{size} = $normIntSize; #change to norm size 
		($sugar,$glycation) = calculateActivityIntervalSugar($href_normInterval, $startSugar);  
	}
	if($remainIntSize){
		$href_normInterval->{time} += $normIntSize;
		$href_normInterval->{size} =  $href_interval->{size} - $normIntSize;
		$href_normInterval->{slope} = 0;
		my ($intSugar,$intGlycation) = calculateActivityIntervalSugar($href_normInterval, $startSugar + $sugar); 
		$sugar += $intSugar;
		$glycation += $intGlycation;
	}
	return ($sugar, $glycation);
}

sub updateIntSugarLevel($)
{
	my ($aref_dayActList) = @_;

	my $i=0;
	my $totalSugar;
	my $totalGlycation;

	$totalSugar= $NORM_SUGAR;
	print "Sugar Level:\n";

	foreach my $href_currInt (@$aref_dayActList){

		my $slope = $href_currInt->{slope};
		my $time = $href_currInt->{time};
		my $size = $href_currInt->{size};

		#Update the startSugar for Interval
		Interval::updateStartSugar($href_currInt, $totalSugar);
		
		if($slope !=0 ){#This is a food/activity interval
			$totalSugar += Interval::computeActIntSugar($href_currInt);
		}
		else # Normalization interval
		{
			$totalSugar += Interval::computeNormIntSugar($href_currInt);
                }

	}
}

sub printSugarGraph($)
{
	my ($aref_dayActList) = @_;

	foreach my $href_currInt (@$aref_dayActList){

		my $slope = $href_currInt->{slope};

		if($slope !=0 ){#This is a food/activity interval
			Interval::printActInterval($href_currInt);
		}
		else # Normalization interval
		{
			Interval::printNormInterval($href_currInt);
                }

	}
}


sub computeDayGlycation($)
{
	my ($aref_dayActList) = @_;

	my $totalGlycation =0;
	foreach my $href_currInt (@$aref_dayActList){

		my $slope = $href_currInt->{slope};

		if($slope !=0 ){#This is a food/activity interval
			$totalGlycation += Interval::computeActIntGlycation($href_currInt);
		}
		else # Normalization interval
		{
			$totalGlycation += Interval::computeNormIntGlycation($href_currInt);
                }

	}
	return $totalGlycation;
}



1;

