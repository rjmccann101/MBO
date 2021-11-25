import Toybox.Activity;
import Toybox.Lang;
import Toybox.System ;
import Toybox.Time;
import Toybox.Time.Gregorian ;

class MBOTimedEvent {

    // The duration of the event, 3 hours
	const eventDuration = Gregorian.duration({:minutes => 180});

    // To convert micro-seconds to seconds
    const microSecondsPerSecond as Number = 1000 ;

	// Constructor for the class
	function initialize() {
    }

    function timeLeft(info as Activity.Info) as Time.Duration {
         var timeUsed = Gregorian.duration({:seconds => (info.elapsedTime as Number) / microSecondsPerSecond });
         var timeLeft = eventDuration.subtract(timeUsed) ;
         return timeLeft ;
    }

}