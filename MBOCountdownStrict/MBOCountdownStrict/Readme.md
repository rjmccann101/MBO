# MBO Countdown Data Field

## Strict

With Version 4 of the Garmin SDK the Monkey C type system was added. This is a port of the original
MBOCountdown project but re-written to have strict type checking. The opportunity was also taken to
refactor the code and tidy up the logic without changing the functionality.  Details of the new type
system can be found here: <https://developer.garmin.com/connect-iq/monkey-c/monkey-types/>

## MBO

This data field is intended for use during 3 hour long MBO events (see <https://www.bmbo.org.uk/>).
Add it to a screen on the MTB activity and start the activity as you start the event.
It provides a countdown with 30 minute alerts for the first 2.5 hours,
5 minute alerts for the last half hour and 1 minute alerts for the last 5 minutes.

When time is up it starts showing you the number of points that your losing until,
if your having a really bad day, you have lost all points.

Each of the periods has its own alert tone which it plays once, it then plays a
repeated beep with the number of repeats showing the number of periods you have used,
so a thirty minute alert followed by three beeps means that you have used three
thirty minute periods, half of the time, while a five minute alert followed by
3 beeps will be played when there are 10 minutes left.
