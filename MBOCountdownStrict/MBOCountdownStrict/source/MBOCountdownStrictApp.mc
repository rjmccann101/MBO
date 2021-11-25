import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.System ;

class MBOCountdownStrictApp extends Application.AppBase {

    // Holds an array of point values that tell how many points are lost for being late
    private var _mboLostPoints as Array<Number>;

    function initialize() {
        AppBase.initialize();
       _mboLostPoints = Application.loadResource(Rez.JsonData.mboLostPoints) as Array<Number> ;
       for (var index = 0; index < _mboLostPoints.size(); index++) {
           System.println(_mboLostPoints[index]) ;
       }
    } 

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    // Return the initial view of your application here
    function getInitialView() as Array<Views or InputDelegates>? {
        return [ new MBOCountdownStrictView() ] as Array<Views or InputDelegates>;
    }

}

function getApp() as MBOCountdownStrictApp {
    return Application.getApp() as MBOCountdownStrictApp;
}