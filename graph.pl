#!perl

# @Copyright 2013: 
# This program computes the blood sugar level graph as per the below definition.
#

use strict;
use Data::Dumper;

my $NORM_SUGAR = 80;
my $NORM_RATE = 60;
my $GLYCATION_LEVEL = 150;
my $MINS_IN_HOUR = 60;


# Function: splitInterval
#   Splits a given interval into two intervals
# Arguments:
#   $aref_intervalList: the list of all intervals 
#   $index: The index of the interval that need to be split
#   $sizeLeft: the size of the first interval, the  left side interval
#           size of right side interval = original size - sizeLeft
#
sub splitInterval($$$)
{
	my ($aref_intervalList, $index, $sizeLeft) = @_;

# make a copy (new) of the interval and modify new Interval (right side interval)
	my %newInt = %{$aref_intervalList->[$index]};   # convert the hash ref to a new hash
	$newInt{"time"} += $sizeLeft;
	$newInt{"size"} -= $sizeLeft;
# slope remains the same 

# modify the original Interval (interval on the left hand side)
	my $href_origInt = $aref_intervalList->[$index];   # hash ref 
	$href_origInt->{"size"} = $sizeLeft;
#slope and time of left(original) window is unchanged 

# Add the new element 'after' splitting (i.e. @ index +1)
	splice(@$aref_intervalList, $index+1,0, \%newInt);

	return;
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
			splitInterval($aref_intervalList, $index, $leftSize); # Aligns start time of two intervals
			$index++; 
		}

#Now the new Interval and current interval is aligned 
		$href_currInt = $aref_intervalList->[$index];
		if($href_currInt->{"size"} == $href_newInt->{"size"}){
			$href_currInt->{"slope"} += $href_newInt->{"slope"};
			$done=1;
		}
		elsif($href_currInt->{"size"} > $href_newInt->{"size"}){
			my $leftSize = $href_newInt->{"size"} ; 
			splitInterval($aref_intervalList, $index, $leftSize);
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

sub calculateSugarLevel($)
{
	my ($aref_intervalList) = @_;

	my $i=0;
	my $totalSugar;
	my $totalGlycation;

	$totalSugar= $NORM_SUGAR;
	print "Sugar Level:\n";

	foreach my $href_currInt (@$aref_intervalList){

		my $slope = $href_currInt->{slope};
		my $time = $href_currInt->{time};
		my $size = $href_currInt->{size};

		my ($intSugar, $intGlycation);
		if($slope !=0 ){#This is a food/activity interval
			($intSugar, $intGlycation) = calculateActivityIntervalSugar($href_currInt, $totalSugar);
		}
		else # Normalization interval
		{
			($intSugar, $intGlycation) = calculateNormIntervalSugar($href_currInt, $totalSugar);
		}
		$totalSugar += $intSugar;
		$totalGlycation += $intGlycation;
	}
	return ($totalSugar, $totalGlycation);
}


sub readTestFile($)
{
	my ($filename) = @_;

	my @inputList;
	open (MYFILE, $filename) or die "File not found: $filename \n";
	while (<MYFILE>) { 
		chomp;
		my $line = $_;
#  space separated elements
		my @arr = split(/ +/, $line);  
		push (@inputList,
				{"time" => $arr[0], 
				"size"  => $arr[1], 
				"slope" => $arr[2]
				} 
		     );
	}
	close (MYFILE); 

	return \@inputList;
#print Dumper(\@inputList);
}

sub addAllInputIntervals($$){
	my ($aref_intervalList, $aref_inputList) = @_;

	my $index=0;
	foreach my $href_inputInterval (@$aref_inputList)
	{
		while($index < scalar(@$aref_intervalList)){
			my $href_currInt = $aref_intervalList->[$index];
# if the input Interval is intersecting the current window,
			if($href_currInt->{"time"} + $href_currInt->{"size"} <= $href_inputInterval->{"time"}){
				$index++;
			}
			else{
				addIntervalAtIndex($aref_intervalList, $index, $href_inputInterval);
				last; # break from the while loop;
			}
		}
	}

	return;
}

sub printIntervalList($)
{
	my ($aref_intervalList) = @_;

	print "Final list of all intervals: [time, duration, rate] \n";
#print Dumper(@$aref_intervalList);
	foreach my $href_currInt(@$aref_intervalList){
		print ("[$href_currInt->{time}, $href_currInt->{size}, $href_currInt->{slope}]");
	}
	print "\n";
	return;
}

sub main()
{
# init a 24 hour window, staring at time=0
	my $aref_intervalList= [ 
	{ 
		time=>0,
		size=>24,
		slope=>0
	}
	];

	(scalar(@ARGV) == 1) or die "Incorrect format: test filename expected e.g. \n perl graph.pl test_file\n";

	my $aref_inputList = readTestFile($ARGV[0]);
	#print Dumper($aref_inputList);

# Add all input intervals to form the final list of intervals
	addAllInputIntervals($aref_intervalList, $aref_inputList);

	printIntervalList($aref_intervalList);

	my($finalSugar, $totalGlycation) = calculateSugarLevel($aref_intervalList);
	print ("Total Glycation = $totalGlycation \n")
}

main();

#	addIntervalAtIndex($aref_intervalList, 0,{"time" => 1, "size" =>2, "slope" => 55});
