package ReadInput;

use strict;
use Exporter;

sub  hello{ 
   print "ReadInout";
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


1;

