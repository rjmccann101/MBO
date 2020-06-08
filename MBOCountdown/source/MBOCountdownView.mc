using Toybox.WatchUi;
using Toybox.Time ;
using Toybox.Time.Gregorian ;

class MBOCountdownView extends WatchUi.SimpleDataField {

	var eventDuration = Gregorian.duration({:hours => 3});

    // Set the label of the data field here.
    function initialize() {
        SimpleDataField.initialize();
        label = "Time Left";
    }

    // The given info object contains all the current workout
    // information. Calculate a value and return it in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info) {
        // See Activity.Info in the documentation for available information.
        var timeUsed = new Time.Duration(info.elapsedTime/1000) ;
        var timeLeft = eventDuration.subtract(timeUsed) ;
        return timeLeft  ;
    }

}