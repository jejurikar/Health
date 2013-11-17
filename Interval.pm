package Interval;

use strict;
use Exporter;

# Function: newInitInterval
# 	Create a new interval with init values = to indicate whole day w/o activity.
#
sub newInitInterval()
{
	my $href_int = 
	{ 
		time=>0,
		size=>24,
		slope=>0
	};

	return $href_int;
}

# Function: copyInterval
#	make a copy of the interval. New interval is identical to the orig interval (and a separate copy)
#

sub copyInterval($)
{
	my ($href_int) = @_;

	# note that this is a shallow copy and suffices with current data structure 
	# (no ref (pointer) in data-struct)
	my %newInt = %$href_int;

	return \%newInt;
}


# Function: splitInterval
#   Splits a given interval into two intervals
# Arguments:
#   $sizeLeft: the size/offset to split the interval, the left side interval
#           size of right side interval = original size - sizeLeft
#
sub splitInterval($$)
{
	my ($href_origInt, $sizeLeft) = @_;

	# make a copy (new) of the interval and modify new Interval (right side interval)
	my $href_newInt = copyInterval($href_origInt);
	$href_newInt->{"time"} += $sizeLeft;
	$href_newInt->{"size"} -= $sizeLeft;
# slope remains the same 

# modify the original Interval (interval on the left hand side)
	$href_origInt->{"size"} = $sizeLeft;
#slope and time of left(original) window is unchanged 

	return $href_newInt;
}



1;

