import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class MBOCountdownApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state) as Void {
    }

    // Return the initial view of your application here
    function getInitialView() as Array<Views or InputDelegates>? {
        return [ new MBOCountdownView() ] as Array<Views or InputDelegates>;
    }

}

function getApp() as MBOCountdownApp {
    return Application.getApp() as MBOCountdownApp;
}