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
        						   new Attention.ToneProfile( 2000, 500),
        						   new Attention.ToneProfile( 7500, 500)]},
    PointLost => {:toneProfile => [new Attention.ToneProfile( 2500, 250),
        						   new Attention.ToneProfile( 2000, 250)]},
    TimedOut => {:toneProfile =>  [new Attention.ToneProfile( 2500, 500),
        						   new Attention.ToneProfile( 2000, 500)]}
   } ;


// A class to hold an time event that we need to notify the user about.
class MBOTimedEvent {

	private var m_eventWhen ;
	private var m_eventType ;
	private var m_repeats ;
	private var m_eventHappened = false ;

	// Constructor for the class
	function initialize(eventWhen, eventType, numBeeps) {
		me.m_eventWhen = eventWhen ;
		me.m_eventType = eventType ;
		me.m_repeats  = numBeeps  ;
	}
	
	// Is it time for this event to be activated?
	function timeForEvent(timeLeft) {
		if (me.m_eventWhen.compare(timeLeft) >= 0) {
			return true ;
		}
		return false ;
	}
	
	// Play the alert for this event
	function playAlert(timeLeft) {
		if (Attention has :playTone) {
		    AlertTones[me.m_eventType].put(:repeatCount,me.m_repeats) ;
		    Attention.playTone(AlertTones[me.m_eventType]) ;
		    System.println("Played event") ;
		}
	}
	
	// Event checking and processing, returns true if
	// the event in question has happened.
	function checkEvent(timeLeft) {
		var result = false ;
		if (me.m_eventHappened == false) {
			if (me.timeForEvent(timeLeft) == true) {
				me.m_eventHappened = true ;
				System.println("Event has happened") ;
				me.playAlert(timeLeft) ;
				result = true ;
			}
		}
		return result ;
    }
}

// A simple data field that provides a count down for a three hour Mountain
// Bike Orienteering event.
class MBOCountdownView extends WatchUi.SimpleDataField {

	// The duration of the event, 3 hours
	const eventDuration = Gregorian.duration({:seconds => 30});

	// An array of MBOTimedEvent objects, when the time comes the alert actions
	// associated with the event will be played.
	var events = [] ;
					
    var nextEvtIdx = 0 ;
    
    const thirtyMinTimes = [150,120,90,60,30] ;
    const fiveMinTimes  = [25,20,15,10,5] ;
    const oneMinTimes   = [5,4,3,2,1] ;
    
    const timeType = :seconds ;  // For testing puposes
    // const timeType = :minutes ;
        
    // Populate the events array with the events that we want to alert the user to
    function buildEvents() {
    	System.println(thirtyMinTimes) ;
    	System.println(thirtyMinTimes.size()) ;
      	for (var i = 0; i < thirtyMinTimes.size(); i++) {
    		events.add(new MBOTimedEvent(Gregorian.duration({timeType => thirtyMinTimes[i]}),ThirtyMin, i));
    	}
    	
       	for (var i = 0; i < fiveMinTimes.size(); i++) {
    		events.add(new MBOTimedEvent(Gregorian.duration({timeType => fiveMinTimes[i]}),FiveMin, i)) ;
    	}
    	
       	for (var i = 0; i < oneMinTimes.size(); i++) {
    		events.add(new MBOTimedEvent(Gregorian.duration({timeType => oneMinTimes[i]}),OneMin,i));
    	}
    	
    	events.add(new MBOTimedEvent(Gregorian.duration({timeType => 0}),TimesUp,0)) ;
    	
    }
    

    // Set the label of the data field here.
    function initialize() {
        SimpleDataField.initialize();
        label = "Time Left";
        buildEvents() ;
    }

    // The given info object contains all the current workout
    // information. Calculate a value and return it in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info) {
        // See Activity.Info in the documentation for available information.
        var result ;
        
        System.println(info.timerState) ;
        
        var timeUsed = new Time.Duration(info.elapsedTime/1000) ;
        System.println(timeUsed.value()) ;
        var timeLeft = eventDuration.subtract(timeUsed) ;
        result = timeLeft ;
        System.println(timeLeft.value()) ;
         
        // Has the activity started?
        if (info.timerState == 3) {
        	// If there are any more events to consume then
        	System.println(nextEvtIdx + " " + events.size()) ;
	        if (nextEvtIdx < events.size() - 1) {
	        	// Test to see if the next event has happened
		        if (events[nextEvtIdx].checkEvent(timeLeft) == true) {
		        	// and when it does happen move onto the next event.
		        	nextEvtIdx++ ;
		        }
	        } else {
	        	// The last event has fired, your out of time and losing 
	        	// points.
	        	System.println("No more events") ;
	        	result = -1 ;
	        }
        }
        
        System.println("result = " + result) ;
        
        return result ; 
    }
}