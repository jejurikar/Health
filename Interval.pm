package Interval;

use strict;
use Exporter;
use Data::Dumper;

my $NORM_SUGAR = 80;
my $NORM_RATE = 60;
my $GLYCATION_LEVEL = 150;
my $MINS_IN_HOUR = 60;

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



############################################################
# Uupdate the sugar and other metrics of an interval
# ##########################################################

sub updateStartSugar($$)
{
   my ($href_int, $startSugar) = @_;

   $href_int->{"startSugar"} = $startSugar; 

   return;
}


sub normIntToActIntList($)
{
   my ($href_interval) = @_;

   defined($href_interval->{"startSugar"}) or die "Error: Undefined key{startSugar} encountered \n";
   my $startSugar = $href_interval->{"startSugar"};

   my $slope = $href_interval->{"slope"};
   my $size = $href_interval->{"size"};

	my $sugar;
	my $normSlope = ($startSugar > $NORM_SUGAR) ? -$NORM_RATE : $NORM_RATE;
	my $normIntSize = (abs($startSugar - $NORM_SUGAR))/60;
	$normIntSize = ($normIntSize > $size) ? $size : $normIntSize;
	my $remainIntSize = $size - $normIntSize;

	my $href_normInt = copyInterval($href_interval);
	$href_normInt->{"startSugar"} = $startSugar;
	$href_normInt->{"time"} = $href_interval->{"time"};
	$href_normInt->{"slope"} = $normSlope;
	$href_normInt->{"size"}  = $normIntSize;

	my $href_remainInt = copyInterval($href_interval);
	$href_remainInt->{"startSugar"} = $startSugar + computeActIntSugar($href_normInt);
	$href_remainInt->{"time"}  = $href_interval->{"time"} + $normIntSize;
	$href_remainInt->{"slope"} = 0;
	$href_remainInt->{"size"}  = $remainIntSize;

	my $aref_normToactList = [];
	if($normIntSize)  { push(@$aref_normToactList, $href_normInt);}
	if($remainIntSize){ push(@$aref_normToactList, $href_remainInt);}

	return $aref_normToactList;
}

############################################################
# Uupdate the sugar and other metrics of an interval
# ##########################################################

sub computeActIntSugar($)
{
   my ($href_int, $startSugar) = @_;

	my $slope = $href_int->{slope};
	my $size = $href_int->{size};

        return $size * $slope;
}


sub computeNormIntSugar($)
{
	my ($href_interval) = @_;

	my $aref_actList = normIntToActIntList($href_interval);
	#print Dumper($aref_actList);
	my $normIntSugar = 0;
	foreach my $href_actInt (@$aref_actList){
		$normIntSugar += computeActIntSugar($href_actInt);
	}
	return $normIntSugar;
}

############################################################
# Uupdate the sugar and other metrics of an interval
# ##########################################################
sub printActInterval($)
{
	my ($href_interval) = @_;

	defined($href_interval->{"startSugar"}) or die "Error: Undefined key{startSugar} encountered \n";
	my $startSugar = $href_interval->{"startSugar"};
	my $time = $href_interval->{time};
	my $size = $href_interval->{size};
	my $endpoint = $href_interval->{time} + $href_interval->{size};

	my $endSugar = $startSugar + computeActIntSugar($href_interval);
	if($time==0){ print ("$time $startSugar \n"); }
	print ("$endpoint $endSugar \n");

}

sub printNormInterval($)
{
	my ($href_interval) = @_;

	my $aref_actList = normIntToActIntList($href_interval);
	#print Dumper($aref_actList);
	foreach my $href_actInt (@$aref_actList){
		printActInterval($href_actInt);
	}

}

############################################################
# Uupdate the sugar and other metrics of an interval
# ##########################################################

sub computeActIntGlycation($)
{
   my ($href_int) = @_;

	my $slope = $href_int->{"slope"};
	my $size = $href_int->{"size"};
        my $startSugar = $href_int->{"startSugar"};
        my $endSugar = $startSugar + computeActIntSugar($href_int);

	my $glycation =0;
	my $glyHours = 0;
	if(($slope > 0) && ($endSugar > $GLYCATION_LEVEL)){
		$glyHours = ($endSugar - $GLYCATION_LEVEL)/$slope;
	} 
	elsif(($slope < 0) && ($startSugar > $GLYCATION_LEVEL)){
		$glyHours = ($GLYCATION_LEVEL - $startSugar)/$slope; # both num and div are negative 
	}

	$glyHours = ($glyHours > $size) ? $size : $glyHours;
	$glycation = $glyHours * $MINS_IN_HOUR;

        return $glycation;
}


sub computeNormIntGlycation($)
{
	my ($href_interval) = @_;

	my $aref_actList = normIntToActIntList($href_interval);
	#print Dumper($aref_actList);
	my $normIntGlycation = 0;
	foreach my $href_actInt (@$aref_actList){
		$normIntGlycation += computeActIntGlycation($href_actInt);
	}
	return $normIntGlycation;
}



1;

