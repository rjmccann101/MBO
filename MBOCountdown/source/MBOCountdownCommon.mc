// Released under GNU General Public License v3.0
// See https://github.com/rjmccann101/MBO for the full license and source code
//
// MBO Countdown
// This Garmin simple data field is intended to be used by competetors in three
// hour Mountain Bike Orienteering events.
//

import Toybox.Attention;
import Toybox.Lang ;

// The different alerts that will be used by the app
enum AlertTypeEnum {
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
    six_hour_event   = 6
}

// Play the alert for this event
function playMBOAlert(eventType as AlertTypeEnum) as Void {
    if (Attention has :playTone) {
        var tone ;
        if (eventType == ThirtyMin) {
            tone = Attention.TONE_INTERVAL_ALERT ;
        }
        else {
            if (eventType == FiveMin) {
                tone = Attention.TONE_ALERT_LO ;
            }
            else {
                if (eventType == OneMin) {
                    tone = Attention.TONE_ALERT_HI ;
                }
                else {
                    if (eventType == TimesUp) {
                        tone = Attention.TONE_CANARY ;
                    }
                    else {
                        if (eventType == PointLost) {
                            tone = Attention.TONE_LOUD_BEEP ;
                        }
                        else {
                            tone = Attention.TONE_FAILURE ;
                        }
                    }
                }
            }
        }
       Attention.playTone(tone) ;
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