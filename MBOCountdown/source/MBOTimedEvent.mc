// Released under GNU General Public License v3.0
// See https://github.com/rjmccann101/MBO for the full license and source code
//
// MBO Countdown
// This Garmin simple data field is intended to be used by competetors in three
// hour Mountain Bike Orienteering events.
//

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

	// Play the alert for the number of periods used so far
    function playTimeUsedAlert() as Void 
    {
        playMBOTimeUsedAlert(m_repeatCount - 1) ;
    }

    // Play the alert noise for this event
    function playEventAlert() as Void {
        playMBOAlert(me.m_eventType)  ; 
    }

    // Play the vibration for this event
    function playEventVibrate() as Void {
        playMBOVibrate() ;
    }
	
	// Event checking and processing, returns true if
	// the event in question has happened.
	function checkEvent(timeLeft) {
		var result = false ;
		if (me.m_eventHappened == false) {
			if (me.timeForEvent(timeLeft) == true) {
				me.m_eventHappened = true ;
				playEventAlert()  ;
				result = true ;
			}
		}
		return result ;
    }
}