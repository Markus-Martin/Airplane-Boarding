# Airplane-Boarding
This program runs a simulation on how long it takes passengers to board an aircraft. Many of the fixed values were set with educated guesses using videos. They were not estimated with scientific rigor so the results shouldn't be taken as absolute. However, these parameters are tunable if an experiment is ever done. The tunable parameters are shown in the heading settings.  
The aim of this simulation was to determine the best method to board an aircraft while taking simplicity into consideration. One could design a very complicated but efficient method but no actual passenger would follow it.
## Program details
To test how the input parameters effect boarding times the experiment is ran many times so an average and standard deviation can be produced. Two outputs are given: a table containing these values and a graph with the normal distributions of each method. There were 6 methods tested:  
 - Random  
 - From the front most passengers to the back most (Ascending)  
 - From the back most passengers to the front most (Descending)  
 - Boarding in 4 groups: even left and right, odd left and right (Modified best)  
 - Perfect ordering for fastest time (Best)  
 - Random but holding baggaging until the end where it's all put away together (Baggage holding)  
## Options
### Tunable Parameters
#### NumPassengers
The number of passengers boarding the aircraft.
#### RandVal
Max time (in seconds) for passengers to load baggage. They will take between no time and RandVal to load their luggage in the compartments above the seats.
#### SPR
SPR stands for Seats Per Row of the aircraft.
#### RPSec
RPSec stands for Rows Per Second. This is the speed of the walking passengers.
#### SwitchTime
The time (in seconds) it takes for passengers to switch when another passenger is blocking the seat. There are two types, hence the input is a list with two values. The first type is when the passenger must get past just one other passenger - an example would be if they wanted to take the third seat but there was someone sitting in the second but not the first. The second type is when there are two or more people in the way - in this case there would be someone in the first and second seat, blocking the third.
#### IncludeBest
Whether to include 'best method' in the outputs. This is because the best method is so much better in terms of consistency of and actual speed of boarding that it throws the perspective off when the probability distribution is plotted.
#### Repeats
The number of times to repeat the simulation on each method. Larger values gives more accurate results but may take longer.
