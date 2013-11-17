#!perl

# @Copyright 2013: 
# This program computes the blood sugar level graph as per the below definition.
# 
# Object Oriented Design (OOD): Modular code for ease of maintainence and testing.
# Perl: 
#   Perl is not designed from the ground up with OOD is mind. The current file should be split into
#   packages (.pm files) for having more modular code. This will enable easy "unit testing" of basic
#   building blocks of the code. Having them as modules in perl.
# Python:
#     These can be proper classes in python (or any object oriented language, C++, Java etc.)

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


sub addAllInputIntervals($$)
{
	my ($aref_dayActList, $aref_inputList) = @_;

	foreach my $href_inputInterval (@$aref_inputList)
	{
		DayActivity::addInterval($aref_dayActList, $href_inputInterval);
	}

	return;
}


sub main()
{
# init a 24 hour window, staring at time=0
	(scalar(@ARGV) == 1) or die "Incorrect format: test filename expected e.g. \n perl graph.pl test_file\n";


	my $aref_inputList = ReadInput::readTestFile($ARGV[0]);

        my $aref_dayActList = DayActivity::initDayActivity();
	#print Dumper($aref_inputList);

# Add all input intervals to form the final list of intervals
	addAllInputIntervals($aref_dayActList, $aref_inputList);

	DayActivity::printIntervalList($aref_dayActList);

	my($finalSugar, $totalGlycation) = DayActivity::calculateSugarLevel($aref_dayActList);
	print ("Total Glycation = $totalGlycation \n")
}

main();

