# Mountain Bike Orienteering Turn Distance Datafield

This Garmin data field keeps track of the turns you have made and the distance
you have travelled since you made them.  It classifies the turns in 1 of 3 ways:
* Left turn
* Right turn
* S bend

and shows the distance you have travelled since the tirn was made.

The thinking behind this is that I always forget to check the distance when 
I reach a feature in the track and end up knowing that the check point is 
250m past the bend but not how far past the bend I am!  So this is an attempt 
to automate this process.

The key to making this work will of course be making the turn detection accurate,
I'm interested in features that are easily distinguised on the map, not in long 
spread out turns.