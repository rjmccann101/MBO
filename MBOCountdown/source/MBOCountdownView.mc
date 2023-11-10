// Released under GNU General Public License v3.0
// See https://github.com/rjmccann101/MBO for the full license and source code
//
// MBO Countdown
// This Garmin simple data field is intended to be used by competetors in three
// hour Mountain Bike Orienteering events.
//

import Toybox.Application;
import Toybox.Application.Properties;
import Toybox.Activity ;
import Toybox.WatchUi;
import Toybox.Time ;
import Toybox.Time.Gregorian ;
import Toybox.Lang ;

// A simple data field that provides a count down for a three hour Mountain
// Bike Orienteering event.
class MBOCountdownView extends WatchUi.SimpleDataField {

	// Seconds per minute	
	const secondsPerMinute = 60 ;

	// Seconds per minute	
	const minsPerHour = 60 ;

	// Penalty points, after 30 minutes you lose the lot!
	const _mboLostPoints as Array<Number> = [1,2,3,4,5, 7,9,11,13,15, 20,25,30,35,40, 50,60,70,80,90, 100,110,120,130,140, 150,160,170,180,190] as Array<Number>;

	// The duration of the event in minutes
	private var _eventDurationMins as Duration;

	// The point scheme to use for this event
	private var _eventPointScheme as Number ;

	// Should the data field play alerts
	private var _playAlerts as Boolean = true ;

	// Should the data field play beeps after the alerts
	private var _playBeepsAfterAlerts as Boolean = true ;

	// An array of MBOTimedEvent objects, when the time comes the alert actions
	// associated with the event will be played.
	private var events as Array<MBOTimedEvent> = [] as Array<MBOTimedEvent> ;
				
    // Index into events, points to next unrun event	
    private var nextEvtIdx as Number = 0 ;
    
    // The number of points that have been lost!
    private var _eventPointsLost as Number = 0 ;
    
    // Indicator that the Out of Time alert has been played
    private var outOfTimePlayed as Boolean = false ;
    
	// Has all of the processing for the last event completed?
	private var eventComplete as Boolean = true ;

    // Working in seconds or minutes?
    const timeType = :minutes ;
        
    // Populate the events array with the events that we want to alert the user to
    private function buildEvents(mins as Number) as Void {
		var eventCnt = 1 ;
		for (var i = mins - 30; i >= 30; i=i-30) {
			events.add(new MBOTimedEvent(Gregorian.duration({timeType => i}),ThirtyMin, eventCnt, _playAlerts, _playBeepsAfterAlerts ));
			eventCnt++ ;
		}
		eventCnt = 1 ;
		for (var i = 25; i >= 5; i=i-5) {
			events.add(new MBOTimedEvent(Gregorian.duration({timeType => i}),FiveMin, eventCnt, _playAlerts, _playBeepsAfterAlerts ));
			eventCnt++ ;
		}
		eventCnt = 1 ;
    	for (var i = 4; i >= 1; i--) {
			events.add(new MBOTimedEvent(Gregorian.duration({timeType => i}),OneMin, eventCnt,  _playAlerts, _playBeepsAfterAlerts ));
			eventCnt++ ;
		}

    	events.add(new MBOTimedEvent(Gregorian.duration({timeType => 0}),TimesUp,1, _playAlerts, _playBeepsAfterAlerts)) ;
    	
    }

	//  Normal time has expired and now we need to report on the points being lost
	private function overTimeEvents(secondsLeftNumber as Number) as Lang.String {

		// The number of whole minutes we are late.  This will be zero (0) when we are between
		// 1 and 59 seconds late - which works as the index into the MBO score points lat array
		var wholeMinutesLate = secondsLeftNumber.abs()/secondsPerMinute ;

		// Value of _eventPointsLost, used to check if we have changed this value
		var lastPointsLost = _eventPointsLost ;

		var result = "" ;

		if (_eventPointScheme == mbo_score) {
			if (wholeMinutesLate < _mboLostPoints.size()) {
				// There are penalties associated with the current wholeMinutesLate so
				// not completely out of time yet!
				if (_eventPointsLost < _mboLostPoints[wholeMinutesLate])
				{
					_eventPointsLost = _mboLostPoints[wholeMinutesLate] ;
					if ( _playAlerts ) {
						playMBOAlert(PointLost) ;
					}
				}
				result = "-" + _eventPointsLost ;
			}
			else {
				// So late that all of your points are lost!
				if (!outOfTimePlayed) 
				{
					if (_playAlerts) {
						playMBOAlert(TimedOut) ;
					}
					outOfTimePlayed = true ;
				}
				result =  "Out of Time!" ;
			}
		}	 
		else {
			_eventPointsLost = (wholeMinutesLate+1) * _eventPointScheme ;
			result = "-" + _eventPointsLost ;
			if (lastPointsLost < _eventPointsLost) {
				if ( _playAlerts) {
					playMBOAlert(PointLost) ;
				}
			}
		} 

		return result ;
	}

	// Normal time - process the timed events
	private function normalTimeEvents(timeLeftDuration as Duration) as Void {

		// Process the actions if we have an uncompleted event
		if (!eventComplete) {
			eventComplete =  events[nextEvtIdx].processEvent() ;
			if (eventComplete) {
				nextEvtIdx++ ; // Move onto the next event
			}
		}
		else {
			// If there are any more events to consume then see if they can be run
			if (nextEvtIdx < events.size()) {
				// Test to see if the next event has happened
				if (events[nextEvtIdx].checkEvent(timeLeftDuration)) {
					eventComplete = false ;
				}
			} 
		}
	}
    
    // The timer is running, determine what to show the client and what alerts to play
    private function checkEvents(timeLeftDuration as Duration, secondsLeftNumber as Number) as Lang.String
    {
		var result = timeLeftDuration as String ;

	    // When secondsLeftNumber is less then zero then time is up and
	    // we are into penalty points 
		if (secondsLeftNumber >= 0) {
			normalTimeEvents(timeLeftDuration) ;
		}
		else {
			result = overTimeEvents(secondsLeftNumber) ;
		}

	    return result ;
    }

	// Get an Integer property value for the Data Control.  If no value can be found then the 
	// defaultValue given will be used.
	function getIntPropertyWithDefault(propertyKey as String, defaultValue as Number) as Number {
		var result = Properties.getValue(propertyKey) ;
		if (result == null) {
            result = defaultValue ;
        }
		return result as Number ;
	}

	// Get a Boolean property value for the Data Control.  If no value can be found then the 
	// defaultValue given will be used.
	function getBooleanPropertyWIthDefault(propertyKey as String, defaultValue as Boolean) as Boolean {
		var result = Properties.getValue(propertyKey) ;
		if (result == null) {
            result = defaultValue ;
        }
		return result as Boolean ;
	}

    // Set the label of the data field here.
    function initialize() {
        SimpleDataField.initialize();
		var eventDurationHours = getIntPropertyWithDefault("event_duration_prop", three_hour_event) ;
        _eventDurationMins = Gregorian.duration({:minutes => (eventDurationHours * minsPerHour)}) ;
		_eventPointScheme = getIntPropertyWithDefault("point_scoring_prop", mbo_score) ;
		_playAlerts = getBooleanPropertyWIthDefault("alerts_prop", true) ;
		_playBeepsAfterAlerts = getBooleanPropertyWIthDefault("beeps_prop", true) ;

        label = eventDurationHours + " Hour Event";
        buildEvents(eventDurationHours * 60) ;
    }

    // The given info object contains all the current workout
    // information. Calculate a value and return it in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    // See Activity.Info in the documentation for available information.
    function compute(info as Activity.Info) as Numeric or Duration or String or Null {

		var elapsedTime = info.elapsedTime as Number;
		var timerState  = info.timerState as Number ;
        var timeUsed    = new Time.Duration(elapsedTime/1000) ;
        var timeLeftDuration    = _eventDurationMins.subtract(timeUsed) ;  // The time left as a Time.Duration object
        var secondsLeftNumber = _eventDurationMins.compare(timeUsed) ;  // The number of seconds left as a Lang.Number, goes negative when we reach the end of normal time
        
		var result = "Error!" ;
               
		// Decide what to do based on the timer state
		if (timerState == 3) {
			result = checkEvents(timeLeftDuration, secondsLeftNumber) ;
		}
		else {
			if (timerState == 0) {
				result = timeLeftDuration ;
			}
			else {
				if (timerState == 2) {
					result = "Paused" ;
				}
				else {
					result = "Stopped" ;
				}
			}
		}
		return result ;
    }
}