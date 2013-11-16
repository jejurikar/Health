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

sub readTop500File($$$)
{
# TODO: write and test the code;
	my ($filename, $offset, $size) = @_;

	my @inputList;
	open (MYFILE, $filename) or die "File not found: $filename \n";
	my $rank =0 ;
	while (<MYFILE>) { 
		chomp;
		my $line = $_;
# skip the entries till the offset
		if ($rank < $offset){$rank++; next;} 
		if ($rank > $offset + $size){last;} 
		push (@inputList, $line)
	}
	close (MYFILE); 

	return \@inputList;
#print Dumper(\@inputList);
}
sub computeRandomSample($)
{
	my ($aref_array) = @_;
# TODO: write code;

	return;
}

sub main()
{

	print "No code is implemented as of now \n";

}

#main();

foreach my $i (1..10)
{
# int(rand(n)) retuns a number between 0..n-1 i.e. (0<= r <= n-1)
	my $r = int(rand(10));
	print(" i=$i $r \n");
}

