// Released under GNU General Public License v3.0
// See https://github.com/rjmccann101/MBO for the full license and source code
//
// MBO Countdown
// This Garmin simple data field is intended to be used by competetors in three
// hour Mountain Bike Orienteering events.
//

import Toybox.Application;
import Toybox.Application.Properties;
import Toybox.WatchUi;
import Toybox.Time ;
import Toybox.Time.Gregorian ;
import Toybox.Attention;
import Toybox.System;

// The different alerts that will be used by the app
enum {
	ThirtyMin, // Played N times to indicate the number of 30 minute durations left
	FiveMin,   // Played N times to indicate the number of 5 minute durations left
	OneMin,    // Played N times to indicate the number of 1 minute durations left
	TimesUp,   // Played when time is up
	PointLost, // Played when yet more points are lost
	TimedOut   // All points lost - you've had a bad day!
}

// The tones associated with each alert type
const AlertTones = {
	ThirtyMin => Attention.TONE_INTERVAL_ALERT,
    FiveMin   => Attention.TONE_ALERT_LO,
    OneMin    => Attention.TONE_ALERT_HI,
    TimesUp   => Attention.TONE_CANARY,
    PointLost => Attention.TONE_LOUD_BEEP,
    TimedOut  => Attention.TONE_FAILURE	 
    } ;
   
// Single vibrate profile - used for all events
const AlertVibe = [new Attention.VibeProfile(100, 500)];  // 0.5 Second Vibrate

// Tone profile used when indicating the number of periods used
const toneProfile as Array<Attention.ToneProfile> = [
		new Attention.ToneProfile(5000,250),
		new Attention.ToneProfile(0,250)
	] as Array<Attention.ToneProfile> ;

// A class to hold an time event that we need to notify the user about.
class MBOTimedEvent {
 
	private var m_eventWhen ;
	private var m_eventType ;
	private var m_repeatCount ;
	private var m_eventHappened = false ;

	// Constructor for the class
	function initialize(eventWhen, eventType, repeatCount) {
		me.m_eventWhen = eventWhen ;
		me.m_eventType = eventType ;
		me.m_repeatCount = repeatCount ;
	}
	
	// Is it time for this event to be activated?
	function timeForEvent(timeLeft) as Boolean {
		if (me.m_eventWhen.compare(timeLeft) >= 0) {
			return true ;
		}
		return false ;
	}
	
	// Play the alert for this event
	function playAlert() {
		if (Attention has :playTone) {
		    Attention.playTone(AlertTones[me.m_eventType]) ;
		}
	}

	// Vibrate the watch to alert the user something has happened
	function playVibrate() {
		if (Attention has :vibrate) {
			Attention.vibrate(AlertVibe);
		}
	}
	
	// Play the alert for the number of periods used so far
    function playTimeUsedAlert() as Void 
    {
        if (Attention has :playTone) {
            Attention.playTone({:toneProfile=>toneProfile, :repeatCount=>m_repeatCount - 1}) ;
        }
    }
	
	// Event checking and processing, returns true if
	// the event in question has happened.
	function checkEvent(timeLeft) {
		var result = false ;
		if (me.m_eventHappened == false) {
			if (me.timeForEvent(timeLeft) == true) {
				me.m_eventHappened = true ;
				me.playAlert() ;
				result = true ;
			}
		}
		return result ;
    }
}

// A simple data field that provides a count down for a three hour Mountain
// Bike Orienteering event.
class MBOCountdownView extends WatchUi.SimpleDataField {
	
	// Seconds per minute	
	const secondsPerMinute = 60 ;

	// Seconds per minute	
	const minsPerHour = 60 ;

	// Penalty points, after 30 minutes you lose the lot!
	const _mboLostPoints = [1,2,3,4,5, 7,9,11,13,15, 20,25,30,35,40, 50,60,70,80,90, 100,110,120,130,140, 150,160,170,180,190] ;

	// The duration of the event in minutes
	private var _eventDurationMins ;

	// The setting that controls the event duration
	private var _eventDurationHours ;

	// An array of MBOTimedEvent objects, when the time comes the alert actions
	// associated with the event will be played.
	private var events = [] ;
				
    // Index into events, points to next unrun event	
    private var nextEvtIdx = 0 ;
    
    // The number of points that have been lost!
    private var pointsLost = 0 ;
    
    // Indicator that the Out of Time alert has been played
    private var outOfTimePlayed = false ;
    
    // Index of the last event that was played
    private var lastPlayedEvtIdx = -1 ;

	// Do we need to vibrate?
	private var needToVibrate = false ;
    
    // Working in seconds or minutes?
    const timeType = :minutes ;
        
    // Populate the events array with the events that we want to alert the user to
    private function buildEvents() {

		var mins = _eventDurationHours * minsPerHour ;
		var eventCnt = 1 ;
		for (var i = mins - 30; i >= 30; i=i-30) {
			events.add(new MBOTimedEvent(Gregorian.duration({timeType => i}),ThirtyMin, eventCnt ));
			eventCnt++ ;
		}
		eventCnt = 1 ;
		for (var i = 25; i >= 5; i=i-5) {
			events.add(new MBOTimedEvent(Gregorian.duration({timeType => i}),FiveMin, eventCnt ));
			eventCnt++ ;
		}
		eventCnt = 1 ;
    	for (var i = 4; i >= 1; i--) {
			events.add(new MBOTimedEvent(Gregorian.duration({timeType => i}),OneMin, eventCnt ));
			eventCnt++ ;
		}

    	events.add(new MBOTimedEvent(Gregorian.duration({timeType => 0}),TimesUp,1)) ;
    	
    }
    
    // PLay a tone and vibrate to let the user know
    // they have lost yet more points.
    private function playLostPointsAlerts()
    {
		if (Attention has :playTone) {
			Attention.playTone(AlertTones[PointLost]) ;
		}
    }
    
    // The timer is running, determine what to show the client and what alerts to play
    private function checkEvents(timeLeft, secondsLeft)
    {
    	var result = timeLeft ;
    	
    	// If we just played an event then we need to play the repeat beeps for it
    	// in the next loop.
    	if (lastPlayedEvtIdx >= 0 ) {
			if (needToVibrate == false) {
    			events[lastPlayedEvtIdx].playTimeUsedAlert() ;
    			lastPlayedEvtIdx = -1 ;
			} else {
				events[lastPlayedEvtIdx].playVibrate() ;
				needToVibrate = false ;
			}
    	} 
    	else { 
	    	// If there are any more events to consume then see if they can be run
		    if (nextEvtIdx < events.size()) {
		    	// Test to see if the next event has happened
		        if (events[nextEvtIdx].checkEvent(timeLeft) == true) {
		        	// and when it does happen move onto the next event.
		        	lastPlayedEvtIdx = nextEvtIdx ;
					needToVibrate = true ;
		        	nextEvtIdx++ ;
		        }
		    } 
		}	    
		
	    // When secondsLeft is less then zero then time is up and
	    // we are into penalty points 
		if (secondsLeft < 0) 
		{
			// The last event has fired, your out of time and losing points.
			var pointIdx = timeLeft.value().abs()/secondsPerMinute ;  // Number of whole minutes late
			if (pointIdx < _mboLostPoints.size()) {
				// There are penalties associated with the current pointIdx so
				// not completely out of time yet!
				if (pointsLost < _mboLostPoints[pointIdx])
				{
					pointsLost = _mboLostPoints[pointIdx] ;
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

	function getIntValueWithDefault(propertyKey, defaultValue) {
		var result = Properties.getValue(propertyKey) ;
		if (result == null) {
            result = defaultValue ;
        }
		return result ;
	}

    // Set the label of the data field here.
    function initialize() {
        SimpleDataField.initialize();
		_eventDurationHours = getIntValueWithDefault("event_duration_prop",3) ;
        _eventDurationMins = Gregorian.duration({:minutes => (_eventDurationHours * minsPerHour)}) ;

        label = _eventDurationHours + " Hour Event";
        buildEvents() ;
    }

    // The given info object contains all the current workout
    // information. Calculate a value and return it in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    // See Activity.Info in the documentation for available information.
    function compute(info) {
        var timeUsed = new Time.Duration(info.elapsedTime/1000) ;
        var timeLeft = _eventDurationMins.subtract(timeUsed) ;
        var secondsLeft = _eventDurationMins.compare(timeUsed) ;
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