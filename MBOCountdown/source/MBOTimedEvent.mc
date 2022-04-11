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

    private var m_hasAlerted = false ;
    private var m_hasPlayedPeriods = false ;
    private var m_hasVibrated = false ;
    
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
        me.m_hasPlayedPeriods = true ;
    }

    // Play the alert noise for this event
    function playEventAlert() as Void {
        playMBOAlert(me.m_eventType)  ; 
        me.m_hasAlerted = true ;
    }

    // Play the vibration for this event
    function playEventVibrate() as Void {
        playMBOVibrate() ;
        me.m_hasVibrated = true ;
    }

    // Have all of the event actions been completed?
    function processEvent() as Boolean {
        if (!m_hasAlerted) {
            me.playEventAlert() ;
        } else {
            if (!m_hasVibrated) {
                me.playEventVibrate() ;
            }
            else {
                if (!m_hasPlayedPeriods) {
                    me.playTimeUsedAlert() ;
                }
            }
        }

        return m_hasAlerted && m_hasVibrated && m_hasPlayedPeriods ;
    }
	
	// Event checking and processing, returns true if
	// the event in question has happened.
	function checkEvent(timeLeft) {
		if (me.m_eventHappened == false) {
			if (me.timeForEvent(timeLeft) == true) {
				me.m_eventHappened = true ;
			}
		}
		return me.m_eventHappened ;
    }
}