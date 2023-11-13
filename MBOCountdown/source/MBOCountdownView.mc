// Released under GNU General Public License v3.0
// See https://github.com/rjmccann101/MBO for the full license and source code
//
// MBO Countdown
// This Garmin simple data field is intended to be used by competetors in 
// Mountain Bike Orienteering events.  It can be configured for events 
// of 1,2,3,4,5 or 6 hours duration.

import Toybox.Application;
import Toybox.Application.Properties;
import Toybox.Activity ;
import Toybox.WatchUi;
import Toybox.Lang ;
import Toybox.Time ;

// A simple data field that provides a count down for a three hour Mountain
// Bike Orienteering event.
class MBOCountdownView extends WatchUi.SimpleDataField {


    //*****************************************************************
    // Constants:
    // Seconds per minute	
    const secondsPerMinute as Number = 60 ;
    // Seconds per minute	
    const minsPerHour as Number = 60 ;
    // Working in seconds or minutes?
    const timeType as Symbol = :minutes ;
    // Penalty points, after 30 minutes you lose the lot!
    const _mboLostPoints as Array<Number> = [1,2,3,4,5, 7,9,11,13,15, 20,25,30,35,40, 50,60,70,80,90, 100,110,120,130,140, 150,160,170,180,190] as Array<Number>;
    // Property value for MBO Scoring (the default)
    const _mbo_score as Number = 0 ;
    //*****************************************************************

    //******************************************************************
    //  Properties.  The following values are set based on the property
    //               values selected by the user of the Data COntrol 
    // The duration of the event in minutes and in seconds
    private var _eventDurationMinutes as Number;
    private var _eventDurationSeconds as Number;
    // The point scheme to use for this event
    private var _eventPointScheme as Number ;
    // Should the data field play alerts
    private var _playAlerts as Boolean = true ;
    // Should the data field play beeps after the alerts
    private var _playBeepsAfterAlerts as Boolean = true ;
    //*****************************************************************

    //*****************************************************************
    // Class Private Variables
    // An array of MBOTimedEvent objects, when the time comes the alert actions
    // associated with the event will be played.
    private var _events as Array<MBOTimedEvent> = [] as Array<MBOTimedEvent> ;
    // Index into events, points to next unrun event	
    private var _nextEvtIdx as Number = 0 ;
    // The number of points that have been lost!
    private var _eventPointsLost as Number = 0 ;
    // Indicator that the Out of Time alert has been played
    private var _outOfTimePlayed as Boolean = false ;
    // Has all of the processing for the last event completed?
    private var _eventComplete as Boolean = true ;
        
    // Populate the events array with the events that we want to alert the user to
    private function buildEvents(mins as Number) as Void {
        var beepRepeatCount = 1 ;  // Number of beeps to play after the event alert
        for (var i = _eventDurationMinutes - 30; i >= 30; i=i-30) {
            _events.add(new MBOTimedEvent(i * 60,
                            Attention.TONE_INTERVAL_ALERT, 
                            beepRepeatCount, _playAlerts, _playBeepsAfterAlerts ));
            beepRepeatCount++ ;
        }
        beepRepeatCount = 1 ;
        for (var i = 25; i >= 5; i=i-5) {
            _events.add(new MBOTimedEvent(i*60,
                            Attention.TONE_ALERT_LO, 
                            beepRepeatCount, _playAlerts, _playBeepsAfterAlerts ));
            beepRepeatCount++ ;
        }
        beepRepeatCount = 1 ;
        for (var i = 4; i >= 1; i--) {
            _events.add(new MBOTimedEvent(i*60,
                            Attention.TONE_ALERT_HI,
                            beepRepeatCount, _playAlerts, _playBeepsAfterAlerts ));
            beepRepeatCount++ ;
        }

        _events.add(new MBOTimedEvent(0, Attention.TONE_CANARY,1, _playAlerts, _playBeepsAfterAlerts)) ;
        
    }

    //  Normal time has expired and now we need to report on the points being lost
    private function overTimeEvents(secondsLeftNumber as Number) as Lang.String {

        // The number of whole minutes we are late.  This will be zero (0) when we are between
        // 1 and 59 seconds late - which works as the index into the MBO score points lat array
        var wholeMinutesLate = secondsLeftNumber.abs()/secondsPerMinute ;

        // Value of _eventPointsLost, used to check if we have changed this value
        var lastPointsLost = _eventPointsLost ;

        var result = "" ;

        if (_eventPointScheme == _mbo_score) {
            if (wholeMinutesLate < _mboLostPoints.size()) {
                // There are penalties associated with the current wholeMinutesLate so
                // not completely out of time yet!
                if (_eventPointsLost < _mboLostPoints[wholeMinutesLate])
                {
                    _eventPointsLost = _mboLostPoints[wholeMinutesLate] ;
                    if ( _playAlerts ) {
                        $.playMBOAlert(Attention.TONE_LOUD_BEEP) ;
                    }
                }
                result = "-" + _eventPointsLost ;
            }
            else {
                // So late that all of your points are lost!
                if (!_outOfTimePlayed) 
                {
                    if (_playAlerts) {
                        $.playMBOAlert(Attention.TONE_FAILURE) ;
                    }
                    _outOfTimePlayed = true ;
                }
                result =  "Out of Time!" ;
            }
        }	 
        else {
            _eventPointsLost = (wholeMinutesLate+1) * _eventPointScheme ;
            result = "-" + _eventPointsLost ;
            if (lastPointsLost < _eventPointsLost) {
                if ( _playAlerts) {
                    $.playMBOAlert(Attention.TONE_LOUD_BEEP) ;
                }
            }
        } 

        return result ;
    }

    // Normal time - process the timed events
    private function normalTimeEvents(timeLeftSeconds as Number) as Void {

        // Process the actions if we have an uncompleted event
        if (!_eventComplete) {
            _eventComplete =  _events[_nextEvtIdx].processEvent() ;
            if (_eventComplete) {
                _nextEvtIdx++ ; // Move onto the next event
            }
        }
        else {
            // If there are any more events to consume then see if they can be run
            if (_nextEvtIdx < _events.size()) {
                // Test to see if the next event has happened
                if (_events[_nextEvtIdx].checkEvent(timeLeftSeconds)) {
                    _eventComplete = false ;
                }
            } 
        }
    }

    // Turn a number of seconds into a string in HH:MM:SS format
    private function secondsToStringTime(timeSeconds as Number) as String
    {
        var result ;
        var hours   = timeSeconds / 3600 ;
        var minutes = (timeSeconds - (hours * 3600)) / 60 ;
        var seconds = (timeSeconds - (hours * 3600) - (minutes * 60)) ;
        if (hours > 0) {
            result  = Lang.format("$1$:$2$:$3$",
                        [hours.format("%1d"), minutes.format("%02d"), seconds.format("%02d")]) ;
        } else {
             result  = Lang.format("$1$:$2$",
                        [minutes.format("%02d"), seconds.format("%02d")]) ;
        }
        return result ;
    }
    
    // The timer is running, determine what to show the client and what alerts to play
    private function checkEvents(timeLeftSeconds as Number) as Lang.String
    {
        var result ;

        // When secondsLeftNumber is less then zero then time is up and
        // we are into penalty points 
        if (timeLeftSeconds >= 0) {
            normalTimeEvents(timeLeftSeconds) ;
            result = secondsToStringTime(timeLeftSeconds) ;
        }
        else {
            result = overTimeEvents(timeLeftSeconds) ;
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
        _eventDurationMinutes = eventDurationHours * 60 ;
        _eventDurationSeconds = _eventDurationMinutes * 60 ;
        _eventPointScheme = getIntPropertyWithDefault("point_scoring_prop", _mbo_score) ;
        _playAlerts = getBooleanPropertyWIthDefault("alerts_prop", true) ;
        _playBeepsAfterAlerts = getBooleanPropertyWIthDefault("beeps_prop", true) ;

        label = eventDurationHours + " Hour Event";
        buildEvents(_eventDurationMinutes) ;

        _eventDurationSeconds = 31 * 60 ;
    }

    // The given info object contains all the current workout
    // information. Calculate a value and return it in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    // See Activity.Info in the documentation for available information.
    function compute(info as Activity.Info) as Numeric or Duration or String or Null {
        var timerState  = info.timerState as Number ;
        var timeUsedSeconds = info.elapsedTime as Number /1000 ;
        var timeLeftSeconds = _eventDurationSeconds - timeUsedSeconds ;  // The time left as a Time.Duration object
        
        var result = "Error!" ;
               
        // Decide what to do based on the timer state
        if (timerState == 3) {
            result = checkEvents(timeLeftSeconds) ;
        }
        else {
            if (timerState == 0) {
                result = secondsToStringTime(timeLeftSeconds) ;
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