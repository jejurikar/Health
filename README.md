This directory contains the main program (graph.pl) that is used to compute the blood sugar level graph. There are 3 test files (test?.txt and the corresponding golden file describing the data). 
 
% perl graph.pl test1.txt 

The input file format is as follows (3 elements per line):
Note: the duration is the time interval over which the activity effects the sugar level

"time"  "duration" "glycemic index": 

8         2         55       # At time 8:00 am, a food        (effect duration of 2 hrs) of GI=55 was consumed

10        1         -40      # At time 10:00 am, an excercise (effect duration 1 hr) with of EI=40 was performed


