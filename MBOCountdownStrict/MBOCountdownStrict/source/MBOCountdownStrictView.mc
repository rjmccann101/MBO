import Toybox.Activity;
import Toybox.Lang;
import Toybox.System ;
import Toybox.Time;
import Toybox.WatchUi;

class MBOCountdownStrictView extends WatchUi.SimpleDataField {

    private var eventTimer as MBOTimedEvent = new MBOTimedEvent() ;

    // Set the label of the data field here.
    function initialize() {
        SimpleDataField.initialize();
        label = Application.loadResource(Rez.Strings.DataFieldLabel) as Lang.String ;
    }

    // The given info object contains all the current workout
    // information. Calculate a value and return it in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info as Activity.Info) as Numeric or Duration or String or Null {
       	var result = "" ;

        // Decide what to do based on the timer state
        switch (info.timerState as Numeric) {
        case 0: 
        	// Activity not yet started
        	result = Application.loadResource(Rez.Strings.TimerStateZeroMsg) as Lang.String ;
        	break ;
        case 1:
            // Activity has been stopped by the user
        	result = Application.loadResource(Rez.Strings.TimerStateOneMsg) as Lang.String ;
        	break ;
        case 2:
            // Activity has been paused by the ruser
        	result = Application.loadResource(Rez.Strings.TimerStateTwoMsg) as Lang.String ;
        	break ;
        case 3:
            // Activity is running!
        	result = eventTimer.timeLeft(info) ;
        	break ;
        }

        return result ;

    }

}