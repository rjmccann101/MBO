import Toybox.Activity;
import Toybox.Attention;
import Toybox.Lang;
import Toybox.System ;
import Toybox.Time;
import Toybox.Time.Gregorian ;

class MBOTimedEvent {

    // The duration of the event, 3 hours
	const eventDuration = Gregorian.duration({:minutes => 180});

    // To convert micro-seconds to seconds
    const microSecondsPerSecond as Number = 1000 ;

    var toneProfile as Array<Attention.ToneProfile> = [
            new Attention.ToneProfile(5000,250),
            new Attention.ToneProfile(0,250)
        ] as Array<Attention.ToneProfile> ;


    function playTimeUsedAlert(periodsUsed as Number) as Void 
    {
        if (Attention has :playTone) {
            Attention.playTone({:toneProfile=>toneProfile, :repeatCount=>periodsUsed - 1}) ;
        }
    }

    function timeLeft(info as Activity.Info) as Time.Duration 
    {
         var timeUsed = Gregorian.duration({:seconds => (info.elapsedTime as Number) / microSecondsPerSecond });
         var timeLeft = eventDuration.subtract(timeUsed) ;
         return timeLeft ; 
    }

   	// Constructor for the class
	function initialize() 
    { 
        playTimeUsedAlert(5) ;
    }
}