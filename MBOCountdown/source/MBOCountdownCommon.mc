// Released under GNU General Public License v3.0
// See https://github.com/rjmccann101/MBO for the full license and source code
//
// MBO Countdown
// This Garmin simple data field is intended to be used by competetors in three
// hour Mountain Bike Orienteering events.
//

import Toybox.Attention;
import Toybox.Lang ;

// The diferent event lengths that are supported
enum {
    one_hour_event   = 1,
    two_hour_event   = 2,
    three_hour_event = 3,
    four_hour_event  = 4, 
    five_hour_event  = 5,
    six_hour_event   = 6
}

// Play the alert for this event
function playMBOAlert(alertToneNumber as Tone) as Void {
    if (Attention has :playTone) {
        Attention.playTone(alertToneNumber) ;
    }
}

// Play the alert for the number of periods used so far
function playMBOTimeUsedAlert(repeatCount as Number) as Void 
{
    if (Attention has :playTone && Attention has :ToneProfile) {
        // Tone profile used when indicating the number of periods used
        var toneProfile = [
            new Attention.ToneProfile(5000,250),
            new Attention.ToneProfile(0,250)] as Array<Attention.ToneProfile> ;
        Attention.playTone({:toneProfile=>toneProfile, :repeatCount=>repeatCount}) ;
    }
}

// Vibrate the watch to alert the user something has happened
function playMBOVibrate() as Void {
    if (Attention has :vibrate) {
        // Single vibrate profile - used for all events
        var AlertVibe = [new Attention.VibeProfile(100, 500)] as Array<Attention.VibeProfile>;
        Attention.vibrate(AlertVibe);
    }
}