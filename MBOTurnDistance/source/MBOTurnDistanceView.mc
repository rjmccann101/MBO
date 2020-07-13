using Toybox.WatchUi;
using Toybox.Graphics;

class MBOTurnDistanceView extends WatchUi.DataField {
       
    private var mHistory ;			// The last 5 bearings and and distances
    private var mTurnDistances ;	// The current set of turn distances

    function initialize() {
        DataField.initialize();
        mHistory = new CircularArray(5) ;
        mTurnDistances = new CircularArray(3) ;

		clearHistory() ;        
        for (var i = 0; i < 3; i++) {
        	mTurnDistances.add(new TurnDistance(" ", 0.0)) ;
        }
    }
    
    function clearHistory() {
        for (var i = 0; i < 5; i++) {
        	mHistory.add(new DistanceBearing(0.0, 0.0)) ;
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
    
    function abs(val) {
    	if (val < 0.0) {
    		return val * (-1.0) ;
    	}
    	else {
    		return val ;
    	}
    }

    // The given info object contains all the current workout information.
    // Calculate a value and save it locally in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info) {
    
    	if (info.timerState == 3) {
	    	System.println("Distance = " + info.elapsedDistance + ", heading = " + info.currentHeading) ;
	    	var aLast = mHistory.last() ;
	    	
	    	if (aLast.mDistance != info.elapsedDistance) {
	    		mHistory.add(new DistanceBearing(info.elapsedDistance, info.currentHeading)) ;
	    	
		    	var absChange = 0.0 ;
		    	var totalChange  = 0.0 ;
		    	
		    	var aPos = mHistory.first() ;
		    	var bPos = mHistory.next() ;
		    	do {
		    		totalChange = totalChange +  bPos.mBearing - aPos.mBearing ;
		    		absChange = absChange + abs(bPos.mBearing - aPos.mBearing) ;
		    		
		    		aPos = bPos ;
		    		bPos = mHistory.next() ;
		    	}
		    	while (!mHistory.isLast()) ; 
		    	totalChange = totalChange +  bPos.mBearing - aPos.mBearing ;
		    	absChange = absChange + abs(bPos.mBearing - aPos.mBearing) ;
		    	
		    	var totalChangeDeg = totalChange * 180.0 * 7.0 /22.0 ;
		    	var absChangeDeg = absChange * 180.0 * 7.0 /22.0 ;
		    	System.println("Total change = " + totalChange + " rad, " + totalChangeDeg + " deg") ;
		    	System.println("Abs change = " + absChange + " rad, " + absChangeDeg + " deg") ;
		    	
		    	if (totalChangeDeg > 60.0) {
		    		System.println("New right turn") ;
		    		clearHistory() ;
		    	}
		    	else if (totalChangeDeg < -60.0) {
		    		System.println("New left turn") ;
		    		clearHistory() ;
		    	}
		    	else if (absChange > 90) {
		    		System.println("New S bend") ;
		    		clearHistory() ;
		    	}
		    	
		    	
		    }
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
