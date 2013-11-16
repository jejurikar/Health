#!perl

# @Copyright 2013: 
#   The main requirements of the program are as follows:
# - We have a DB and the top 500 users (we store the top500 in a csv (or txt) file)
# - For each user, display k (e.g. 10) of the top500 users
# - different users can (should) have different order of k top500 users
# - Each user has a window (cookie and time based) where the order does not change
#
# Solution Description:
# 1. We have a big DB and we can run a query to get the list of top500 users. This is stored 
#     may be in a separate DB - and it can be periodically updated if the top500 changes. If the 
#     top500 is static, then this top500 list need not be updated.
# 2. From the top500 list, we can create multiple (n) lists of smaller size. E.g. we create 5 list.
#    The list can be of any size, depending on how many users are typically displayed. Or even how
#    to want to utilize the list to have different orderings for different users. E.g we have lists
#    as L0, L1, L2, L3, L4 (if we have 5 lists) 
#    API to create the list: CreateList(offset, viewSize, lisSize);
# 3. Each user has a cookie for his activity. The cookie stores the info on the list to be used. 
#    The cookie keeps track of time of the accesses to the website.  
#    The list ID is passed along with the request for the k users in top500.
#
# 4. List Management at server: Analogously, there can be some timers and respective list management
#    at the server to know which list are no longer active (no user needs the list). 
#    There can be some 'garbage collection' equivalent scheme to know the active lists and
#    maybe refresh lists (using API in item 2) to recreate newer lists.   
#
#    When a user specifies a list, the operations can be one of many options
#    (a) Simple option: Start from i=0 and return the k items from the list (0 ... k-1). 
#        Note that this limts the sharing of the lists among users (as different users want 
#        to have different orderings),
#    (b) Number theory based different list traversing : 
#        In addition to the list, we can have a function to get the items from 
#        the given list. E.g. we have lists of size=prime_number. This can enable some 
#        'number theory' techniques (using modulo arithmetic) to efficiently generate different 
#        orderings for the differnt users. We can store a 'generators' of the field and that 
#        will give a different ordering for each different ordering.
#    (c) Another Option: On top of that we can maybe have simple techniques like adding constants, 
#        to this ordering to generate different ordering. Basically, we can reduce the number of 
#        lists needed as the number of users change.
#
# Coding: So from a coding perspective, we implement simple functions
# - create a list
# - shuffle a list  

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
sub shuffleArray($)
{
	my ($aref_array) = @_;
# TODO: write code;

	return;
}

sub main()
{

	print "No code is implemented as of now \n";

}

main();



