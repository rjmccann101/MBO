// Released under GNU General Public License v3.0
// See https://github.com/rjmccann101/MBO for the full license and source code
//
// MBO Countdown
// This Garmin simple data field is intended to be used by competetors in three
// hour Mountain Bike Orienteering events.
//

import Toybox.Attention;

// The tones associated with each alert type
const AlertTones = {
	ThirtyMin => Attention.TONE_INTERVAL_ALERT,
    FiveMin   => Attention.TONE_ALERT_LO,
    OneMin    => Attention.TONE_ALERT_HI,
    TimesUp   => Attention.TONE_CANARY,
    PointLost => Attention.TONE_LOUD_BEEP,
    TimedOut  => Attention.TONE_FAILURE	 
} ;

// The different alerts that will be used by the app
enum {
	ThirtyMin, // Played N times to indicate the number of 30 minute durations left
	FiveMin,   // Played N times to indicate the number of 5 minute durations left
	OneMin,    // Played N times to indicate the number of 1 minute durations left
	TimesUp,   // Played when time is up
	PointLost, // Played when yet more points are lost
	TimedOut   // All points lost - you've had a bad day!
}

// The point schemes 
enum {
	mbo_score              = 0,
	one_point_per_minute   = 1,
	two_point_per_minute   = 2,
	three_point_per_minute = 3,
	four_point_per_minute  = 4,
	five_point_per_minute  = 5
}

// The diferent event lengths that are supported
enum {
	one_hour_event   = 1,
	two_hour_event   = 2,
	three_hour_event = 3,
	four_hour_event  = 4,
	five_hour_event  = 5,
}

// Single vibrate profile - used for all events
const AlertVibe = [new Attention.VibeProfile(100, 500)];  // 0.5 Second Vibrate

// Tone profile used when indicating the number of periods used
const toneProfile as Array<Attention.ToneProfile> = [
        new Attention.ToneProfile(5000,250),
        new Attention.ToneProfile(0,250)
    ] as Array<Attention.ToneProfile> ;

// Play the alert for this event
function playMBOAlert(eventType) {
    if (Attention has :playTone) {
        Attention.playTone(AlertTones[eventType]) ;
    }
}

// Play the alert for the number of periods used so far
function playMBOTimeUsedAlert(repeatCount) as Void 
{
    if (Attention has :playTone) {
        Attention.playTone({:toneProfile=>toneProfile, :repeatCount=>repeatCount}) ;
    }
}

// Vibrate the watch to alert the user something has happened
function playMBOVibrate() {
    if (Attention has :vibrate) {
        Attention.vibrate(AlertVibe);
    }
}