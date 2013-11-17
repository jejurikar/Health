#!perl

# @Copyright 2013: 
# This program computes the blood sugar level graph as per the below definition.
# 
# TODO: 
# Object Oriented Design (OOD): Have a object oriented design for coe maintainence and testing.
# Perl: 
#   Perl is not designed from the ground up with OOD is mind. The current file should be split into
#   packages (.pm files) for having more modular code. This will enable easy "unit testing" of basic
#   building blocks of the code.
#
# Python (or othe object oriented language, C++, Java etc.)
#   The object oriented design will look as follows:
# class Interval:
# 	private: time, size, slope
# 	public: 
# 		Interval($$$); # Constructor
# 		Interval splitInterval(); # returns the new interval (after splitting existing one)
#
# class DayActivity:
# 	private: list(partition) of Intervals 
# 	public: 
# 		DayActivity(class Interval); # This will be the initial inteval (0,24,0)
#               addInterval;
#
# class ReadInputFile:
#	private: 
#	       list of Intervals 
#	public: 
#	 	ReadInputFile($fileName) 
#

use strict;
use Data::Dumper;
use ReadInput;
use DayActivity;

my $NORM_SUGAR = 80;
my $NORM_RATE = 60;
my $GLYCATION_LEVEL = 150;
my $MINS_IN_HOUR = 60;



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


sub addAllInputIntervals($$)
{
	my ($aref_intervalList, $aref_inputList) = @_;

	foreach my $href_inputInterval (@$aref_inputList)
	{
		DayActivity::addInterval($aref_intervalList, $href_inputInterval);
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
	(scalar(@ARGV) == 1) or die "Incorrect format: test filename expected e.g. \n perl graph.pl test_file\n";


	my $aref_inputList = ReadInput::readTestFile($ARGV[0]);

        my $aref_intervalList = DayActivity::initDayActivity();
	#print Dumper($aref_inputList);

# Add all input intervals to form the final list of intervals
	addAllInputIntervals($aref_intervalList, $aref_inputList);

	printIntervalList($aref_intervalList);

	my($finalSugar, $totalGlycation) = calculateSugarLevel($aref_intervalList);
	print ("Total Glycation = $totalGlycation \n")
}

main();

#	addIntervalAtIndex($aref_intervalList, 0,{"time" => 1, "size" =>2, "slope" => 55});
