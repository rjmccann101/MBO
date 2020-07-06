using Toybox.WatchUi;
using Toybox.Graphics;

class MBOTurnDistanceView extends WatchUi.DataField {
       
    private var mHistory ;			// The last 5 bearings and and distances
    private var mTurnDistances ;	// The current set of turn distances

    function initialize() {
        DataField.initialize();
        mHistory = new CircularArray(5) ;
        mTurnDistances = new CircularArray(3) ;

        for (var i = 0; i < 5; i++) {
        	mHistory.add(new DistanceBearing(0.0, 0.0)) ;
        }
        
        for (var i = 0; i < 3; i++) {
        	mTurnDistances.add(new TurnDistance(" ", 0.0)) ;
        }
    }

    // Set your layout here. Anytime the size of obscurity of
    // the draw context is changed this will be called.
    function onLayout(dc) {
        var obscurityFlags = DataField.getObscurityFlags();

        // Top left quadrant so we'll use the top left layout
        if (obscurityFlags == (OBSCURE_TOP | OBSCURE_LEFT)) {
            View.setLayout(Rez.Layouts.TopLeftLayout(dc));

        // Top right quadrant so we'll use the top right layout
        } else if (obscurityFlags == (OBSCURE_TOP | OBSCURE_RIGHT)) {
            View.setLayout(Rez.Layouts.TopRightLayout(dc));

        // Bottom left quadrant so we'll use the bottom left layout
        } else if (obscurityFlags == (OBSCURE_BOTTOM | OBSCURE_LEFT)) {
            View.setLayout(Rez.Layouts.BottomLeftLayout(dc));

        // Bottom right quadrant so we'll use the bottom right layout
        } else if (obscurityFlags == (OBSCURE_BOTTOM | OBSCURE_RIGHT)) {
            View.setLayout(Rez.Layouts.BottomRightLayout(dc));

        // Use the generic, centered layout
        } else {
            View.setLayout(Rez.Layouts.MainLayout(dc));
        }
        return true;
    }

    // The given info object contains all the current workout information.
    // Calculate a value and save it locally in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info) {
    
    	if (info.timerState == 3) {
	    	System.println(info.elapsedDistance + "," + info.currentHeading) ;
	    	mHistory.add(new DistanceBearing(info.elapsedDistance, info.currentHeading)) ;
	    	
	    	var absChange = 0.0 ;
	    	var totalChange  = 0.0 ;
	    	var maxChange  = 0.0 ;
	    	
	    	var aPos = mHistory.first() ;
	    	System.println(aPos) ;
	    	//System.println(aPos + ","+ aPos.mDistance + "," + aPos.mBearing) ;
	    	do {
	    		absChange = absChange + aPos.mBearing ;
	    		aPos = mHistory.next() ;
	    	}
	    	while (!mHistory.isLast()) ; 
	    	
	    	System.println(absChange) ;
    	}
    	else {
    		System.println("Paused or Stopped") ;
    	}
    	
    }
    
    private function drawTurn(turnName, type, distance) {
    	var value = View.findDrawableById(turnName);
        if (getBackgroundColor() == Graphics.COLOR_BLACK) {
            value.setColor(Graphics.COLOR_WHITE);
        } else {
            value.setColor(Graphics.COLOR_BLACK);
        }
        value.setText(type + " " + distance.format("%.2f"));
    }
    

    // Display the value you computed here. This will be called
    // once a second when the data field is visible.
    function onUpdate(dc) {
        // Set the background color
        View.findDrawableById("Background").setColor(getBackgroundColor());
        
        drawTurn("turn1", "L", 100.0) ;
        drawTurn("turn2", "R", 120.0) ;
        drawTurn("turn3", "U", 130.0) ;

        // Call parent's onUpdate(dc) to redraw the layout
        View.onUpdate(dc);
    }

}
