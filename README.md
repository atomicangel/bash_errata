# bash_errata
A collection of bash scripts that are small but still useful.

## Battery Runtime Logger

This script simply monitors your battery percentage and writes the output to a log file in the same folder with the date and time on a separate line. It checks once a minute and logs the data. At 80, 60, 40, and 20 percent a notification appears indicating you have reached that percentage, and in the log it will then note how much approximate screen on time you have had. I say approximate because if your display turns off but the machine is still awake (not sleeping) then this will continue logging and counting that time. In my case, because of the way my system is setup it is more accurate since my machine doesn't power off the screen until it's going to sleep.

### Note regarding battery percentage changes:
I have a laptop that will sometimes go from ~35% to ~6% without warning, so I coded in a spot that will check for a significant drop in percentage across a 1 minute period. That code starts at line 26 and goes to line 32 if you want to comment that out. If you change the comparison on line 28, you can adjust how severe of a drop is cause for alarm. I chose 5 percent since right now I don't have any workloads that would cause that big of a drop generally speaking, and anything larger than that I want to be made aware of.