// Released under GNU General Public License v3.0
// See https://github.com/rjmccann101/MBO for the full license and source code
//
// MBO Countdown
// This Garmin simple data field is intended to be used by competetors in three
// hour Mountain Bike Orienteering events.
//

using Toybox.WatchUi;
using Toybox.Time ;
using Toybox.Time.Gregorian ;
using Toybox.Attention;

// The different alerts that will be used by the app
enum {
	ThirtyMin, // Played N times to indictae the number of 30 minute durations left
	FiveMin,   // Played N times to indicate the number of 5 minute durations left
	OneMin,    // Played N times to indicate the number of 1 minute durations left
	TimesUp,   // Played when time is up
	PointLost, // Played when yet more points are lost
	TimedOut   // All points lost - you've had a bad day!
}

// The tones associated with each alert type
const AlertTones = {
	ThirtyMin => {:toneProfile => [new Attention.ToneProfile( 2500, 250),
        						   new Attention.ToneProfile( 2500, 250)]},
    FiveMin   => {:toneProfile => [new Attention.ToneProfile( 2500, 250),
        						   new Attention.ToneProfile( 5000, 250)]},
    OneMin    => {:toneProfile => [new Attention.ToneProfile( 5000, 250),
        						   new Attention.ToneProfile( 7500, 250)]},
    TimesUp   => Attention.TONE_CANARY,
    PointLost => Attention.TONE_LOUD_BEEP,
    TimedOut  => Attention.TONE_ALERT_LO	 } ;
 
// Single vibrate profile - used for all events
const AlertVibe = [new Attention.VibeProfile(100, 500)];  // 0.5 Second Vibrate

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
			if (me.m_repeats > 0) {
		    	AlertTones[me.m_eventType].put(:repeatCount,me.m_repeats) ;
		    }
		    Attention.playTone(AlertTones[me.m_eventType]) ;
		}
		if (Attention has :vibrate) {
			Attention.vibrate(AlertVibe);
		}
	}
	
	// Event checking and processing, returns true if
	// the event in question has happened.
	function checkEvent(timeLeft) {
		var result = false ;
		if (me.m_eventHappened == false) {
			if (me.timeForEvent(timeLeft) == true) {
				me.m_eventHappened = true ;
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
	const eventDuration = Gregorian.duration({:minutes => 180});
	
	// Seconds per minute	
	const secondsPerMinute = 60 ;

	// An array of MBOTimedEvent objects, when the time comes the alert actions
	// associated with the event will be played.
	var events = [] ;
				
    // Index into events, points to next unrun event	
    var nextEvtIdx = 0 ;
    
    // The number of points that have been lost!
    var pointsLost = 0 ;
    
    // Indicator that the Out of Time alert has been played
    var outOfTimePlayed = false ;
    
    // Penalty points, after 30 minutes you lose the lot!
    const penaltyPoints = [1,2,3,4,5, 7,9,11,13,15, 20,25,30,35,40, 50,60,70,80,90, 100,110,120,130,140, 150,160,170,180,190] ;
    
    // The number of minutes at which the time events occur
    const thirtyMinTimes = [150,120,90,60,30] ;
    const fiveMinTimes  = [25,20,15,10,5] ;
    const oneMinTimes   = [5,4,3,2,1] ;
    
    // Working in seconds or minutes?
    const timeType = :minutes ;
        
    // Populate the events array with the events that we want to alert the user to
    private function buildEvents() {
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
    
    // PLay a tone and vibrate to let the user know
    // they have lost yet more points.
    private function playLostPointsAlerts()
    {
		if (Attention has :playTone) {
			Attention.playTone(AlertTones[PointLost]) ;
		}
		if (Attention has :vibrate) {
			Attention.vibrate(AlertVibe);
		}
    }
    
    // The timer is running, determine what to show the client and what alerts to play
    private function checkEvents(timeLeft, secondsLeft)
    {
    	var result = timeLeft ;
   	
    	// If there are any more events to consume then see if they can be run
	    if (nextEvtIdx < events.size()) {
	    	// Test to see if the next event has happened
	        if (events[nextEvtIdx].checkEvent(timeLeft) == true) {
	        	// and when it does happen move onto the next event.
	        	nextEvtIdx++ ;
	        }
	    } 
	    
	    // When secondsLeft is less then zero then time is up and
	    // we are into penalty points 
		if (secondsLeft < 0) 
		{
			// The last event has fired, your out of time and losing points.
			var pointIdx = timeLeft.value().abs()/secondsPerMinute ;  // Number of whole minutes late
			if (pointIdx < penaltyPoints.size()) {
				// There are penalties associated with the current pointIdx so
				// not completely out of time yet!
				if (pointsLost < penaltyPoints[pointIdx])
				{
					pointsLost = penaltyPoints[pointIdx] ;
					playLostPointsAlerts() ;
				}
				result = "-" + pointsLost ;
			}
			else {
				// So late that all of your points are lost!
				if (!outOfTimePlayed) 
				{
					playLostPointsAlerts() ;
					outOfTimePlayed = true ;
				}
				result =  "Out of Time!" ;
			}
		}	    

	    return result ;
    }

    // Set the label of the data field here.
    function initialize() {
        SimpleDataField.initialize();
        label = "M B O";
        buildEvents() ;
    }

    // The given info object contains all the current workout
    // information. Calculate a value and return it in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    // See Activity.Info in the documentation for available information.
    function compute(info) {
        var timeUsed = new Time.Duration(info.elapsedTime/1000) ;
        var timeLeft = eventDuration.subtract(timeUsed) ;
        var secondsLeft = eventDuration.compare(timeUsed) ;
        var result = "Error!" ;
               
		// Decide what to do based on the timer state
        switch (info.timerState) {
        case 0: 
        	// Activity not yet started
        	result = timeLeft ;
        	break ;
        case 1:
        	result = "Stopped" ;
        	break ;
        case 2:
        	result = "Paused" ;
        	break ;
        case 3:
        	result = checkEvents(timeLeft,secondsLeft) ;
        	break ;
        }
        
        return result ;
    }
}