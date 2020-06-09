using Toybox.WatchUi;
using Toybox.Time ;
using Toybox.Time.Gregorian ;
using Toybox.Attention;

// The different alerts that will be used by the app
enum {
	Pause,	   // A pause in the tones
	ThirtyMin, // Played N times to indictae the number of 30 minute durations left
	FiveMin,   // Played N times to indicate the number of 5 minute durations left
	OneMin,    // Played N times to indicate the number of 1 minute durations left
	TimesUp,   // Played when time is up
	PointLost, // Played when yet more points are lost
	TimedOut   // All points lost - you've had a bad day!
}

// The tones associated with each alert type
const AlertTones = {
	Pause     => {:toneProfile => [new Attention.ToneProfile( 0, 100)]},
	ThirtyMin => {:toneProfile => [new Attention.ToneProfile( 2500, 250),
        						   new Attention.ToneProfile( 2500, 250)]},
    FiveMin   => {:toneProfile => [new Attention.ToneProfile( 2500, 250),
        						   new Attention.ToneProfile( 5000, 250)]},
    OneMin    => {:toneProfile => [new Attention.ToneProfile( 5000, 250),
        						   new Attention.ToneProfile( 7500, 250)]},
    TimesUp   => {:toneProfile => [new Attention.ToneProfile( 2500, 500),
        						   new Attention.ToneProfile( 2000, 500)]},
    PointLost => {:toneProfile => [new Attention.ToneProfile( 2500, 250),
        						   new Attention.ToneProfile( 2000, 250)]},
    TimedOut => {:toneProfile =>  [new Attention.ToneProfile( 2500, 500),
        						   new Attention.ToneProfile( 2000, 500)]}
   } ;


// A class to hold an time event that we need to notify the user about.
class MBOTimedEvent {

	private var m_eventWhen ;
	private var m_eventType ;
	private var m_numBeeps ;
	private var m_eventHappened = false ;

	// Constructor for the class
	function initialize(eventWhen, eventType, numBeeps) {
		me.m_eventWhen = eventWhen ;
		me.m_eventType = eventType ;
		me.m_numBeeps  = numBeeps  ;
		System.println("beeps " + me.m_numBeeps) ;
	}
	
	// Is it time for this event to be activated?
	function timeForEvent(timeLeft) {
		System.println(me.m_eventWhen.compare(timeLeft)) ;
		if (me.m_eventWhen.compare(timeLeft) >= 0) {
			return true ;
		}
		return false ;
	}
	
	// Play the alert for this event
	function playAlert(timeLeft) {
		System.println("playingAlert") ;
		for( var i = 0; i < me.m_numBeeps; i++ ) {
			if (Attention has :playTone) {
				System.println("has :playTone. loop " + i +" of " + me.m_numBeeps) ;
				Attention.playTone(AlertTones[ThirtyMin]);
				//Attention.playTone(AlertTones[Pause]);
			}
		}
	}
	
	// Event checking and processing
	function checkEvent(timeLeft) {
		if (me.m_eventHappened == false) {
			if (me.timeForEvent(timeLeft) == true) {
				me.m_eventHappened = true ;
				System.println("Event has happened") ;
				me.playAlert(timeLeft) ;
			}
		}
    }
}


class MBOCountdownView extends WatchUi.SimpleDataField {

	const eventDuration = Gregorian.duration({:seconds => 30});
	
	const t1 = Gregorian.duration({:seconds => 25}) ;
	
	const events = [new MBOTimedEvent(t1, ThirtyMin,5)] ;

    // Set the label of the data field here.
    function initialize() {
        SimpleDataField.initialize();
        label = "Time Left";
    }

    // The given info object contains all the current workout
    // information. Calculate a value and return it in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info) {
        // See Activity.Info in the documentation for available information.
        var timeUsed = new Time.Duration(info.elapsedTime/1000) ;
        System.println(timeUsed.value()) ;
        var timeLeft = eventDuration.subtract(timeUsed) ;
        System.println(timeLeft.value()) ;
        
        
        for( var i = 0; i < events.size(); i++ ) {
			var event = events[i] ;
			event.checkEvent(timeLeft) ;
		}
		
        return timeLeft  ;
    }
}