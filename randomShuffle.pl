#!perl

# @Copyright 2013: 
#   The main requirements of the program are as follows:
# - We have a DB and the top 500 users stored separately (we store the top500 in a csv (or txt) file)
# - For each user, display k (e.g. 10) of the top500 users (or maybe a subset ot the top500)
# - different users can (should) have different order of k top500 users
# - Each user has a window (cookie and time based) where the order does not change
#
# Solution Description:
#    This is a client server model, where the cookies can be maintained at the client side.
#    This cookie can be used on the client side to ensure that the top user list does not 
#    change on the client machine. In short the client will not request the server for a new
#    list based on the cookie (timestamps etc.). This frees the server from tracking users and
#    the (random) top user list for each user. So for every request the server returns a new 
#    random list of top users (say k top users)
#
# 1. We have a big DB and we can run a query to get the list of top500 users. This is stored 
#     may be in a separate DB - and it can be periodically updated if the top500 changes. If the 
#     top500 is static, then this top500 list need not be updated.
# 2.  Multiple lists are not required (server sends a new random list everytime)
#
# 3. Each user has a cookie for his activity. The cookie stores the time of previous request 
#    for the top user list from the server. This is used to request or not request a new list 
#    from the server (as part of accessing the web-page i.e. viewing the top users list)
#
# 4. List Management at server: Not required. Everytime, return a new random list.
#
# Coding: So from a coding perspective, we implement simple functions
# - return a random sample of the top500 users (or a sub-set of that)

use strict;
use Data::Dumper;

# using global variable to simulate a database like record read/write API
 my $aref_top500List; 

sub readRecord($)
{
	my ($index) = @_;

	(ref($aref_top500List) eq "ARRAY") or die "Error: DB not initialized (file not read)\n";
	return $aref_top500List->[$index];
}


sub readTop500File($)
{
	my ($filename) = @_;

	my @top500List;
	open (MYFILE, $filename) or die "File not found: $filename \n";
	while (<MYFILE>) { 
		chomp;
		my $line = $_;
		push (@top500List, $line)
	}
	close (MYFILE); 

	return \@top500List;
}

# Function: Get a random sample of sampleSize(k) from the totalRecords(n). 
#           The totalRecords(n)  by parametersa 0 ($totalRecords). 
#
#Input:
#   $ 0: The start offset within the top500
#   $totalRecords(n): Total number of records to sample from (staring from 0)
#   $sampleSize(k) : The size of the sample to compute  
#
#Return:
#   $the list of record indexes that constitute the random sample 


# Use the "Reservoir Sampling" Algorithm by Vitter et. al.
# This ensures that each record is slected with equal probability (from the records sampled).
#
sub computeRandomSample($$)
{
	my ($totalRecords, $sampleSize) = @_;

	my @sampleArray; # it contains the indexes of the records (not the records)
#Fill the reservoir (the initial sample is first k records)
	for(my $i=0; $i < $sampleSize; $i++){
		$sampleArray[$i] = readRecord($i);
	}

#sample the remaining indexes, replacing the reservoir as follows
	for(my $i=$sampleSize; $i < $totalRecords; $i++){
# Get a random j, such that  0 <= j <= i
# int(rand(n)) retuns a number between 0..n-1 i.e. (0<= r <= n-1)
# So use rand($i+1)
		my $j = int(rand($i+1));

		if($j < $sampleSize){
			$sampleArray[$j] = readRecord($i); 
# If reading records from database, read the record[$i] only when it is selected in the sample.
		}
	}
	return \@sampleArray;
}

sub main()
{ 
	my $totalRecords = $ARGV[0];
	my $sampleSize = $ARGV[1];

        (scalar(@ARGV) == 2) or 
	die "Incorrect Parameters e.g. perl randomShuffle  30 4";

	 (($totalRecords <= 500) && ($sampleSize <= $totalRecords)) or 
	die "Invalid Parameters e.g. perl randomShuffle  30 4 # (ARGV[1] < 500, ARGV[1] < ARGV[0])";

	$aref_top500List = readTop500File("top500.txt");
#print Dumper($aref_top500List);

	my $aref_sample = computeRandomSample($totalRecords,$sampleSize);
	foreach my $rec (@$aref_sample){
		print "$rec \n";
	}
}

main();


#foreach my $i (0..500-1)
#{
#	print("$i  NAME_$i \n");
#}
#
