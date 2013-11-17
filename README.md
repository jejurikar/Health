This directory contains the main program (graph.pl) that is used to compute the blood sugar level graph. There are 3 test files (test?.txt and the corresponding golden file with the expected data). 
 
% perl graph.pl test1.txt 

The input file format is as follows (3 elements per line):
Note: the duration is the time interval over which the activity effects the sugar level

"time"  "duration" "glycemic index": 

8         2         55       # At time 8:00 am, a food        (effect duration of 2 hrs) of GI=55 was consumed

10        1         -40      # At time 10:00 am, an excercise (effect duration 1 hr) with of EI=40 was performed

------------------------------------------------------------------

Program 2: randomShuffle.pl

This program reads the file top500.txt as the list of the top 500 records. It is a simple test file 
with simple names representing the rank. The filename is hard-coded (not input param). The program is run as follows:

% perl randomShuffle.pl  50  5 

ARG0 (e..g 50) is the number of record to sample from the top 500 records. The records are starting from rank0. So in this example, it is form rank0 to rank50-1;

ARG1 (e.g. 5) is the random sample size. 

The program returns a random sample size (# record) from the specified number of records.
In the example a ramdom sample of 5 is returned from the first 50 records on top500.txt file.







