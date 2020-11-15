using Toybox.WatchUi;
using Toybox.Graphics;

class MBOTurnDistanceView extends WatchUi.DataField {
       
    private var mHeadHist = new [5] ;			// The last 5 headings
    private var mDistHist = new [5] ;			// The last 5 distances
    private var mTurn = new [4] ;				// The turns associated with the last 5 headings
    private var mTurnDistances ;	// The current set of turn distances
    
    private var PI = 355.0/133.0 ;  // An aproximation for PI
    private var SIXTY_DEG = PI/3.0 ;  // 60 degrees in radians

    function initialize() {
        DataField.initialize();
        mTurnDistances = new CircularArray(3) ;

        for (var i = 0; i < 3; i++) {
        	mTurnDistances.add(new TurnDistance(" ", 0.0)) ;
        }
        
        for (var i = 0; i < mHeadHist.size() ; i++) {
        	mHeadHist[i] = 0.0 ;
        	mDistHist[i] = 0.0 ;
        }
        
        for (var i = 0; i < mTurn.size(); i++) {
        	mTurn[i] = 0 ;
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
    
    // Get the absolute value of a number - abs(-1.9) = 1.9
    function abs(val) {
    	if (val < 0.0) {
    		return val * (-1.0) ;
    	}
    	else {
    		return val ;
    	}
    }
    
    // Given two headings work out how the amount and directions of the turn.
    // A turn to the right will be a positive value and a turn to the left a
    // negative value.  For example:
    // H1 = 10, H2 = 30 => Turn = 20. A right turn of 20 degress
    // H1 = 50, H2 = 20 => Turn = -30. A left turn of 30 degress
    // When a turn is more that 180 then it's sign is reversed it's subtracted from 360 to
    // to make a left turn more that 180 a right turn and a right turn more than 180 a 
    // left turn 
    // H1 = 350, H2 = 10 => 10 - 350 = -340 => 360  -340 = 20 => Turn = 20
    // H1 = 10, H2 = 330 => 330 - 10 = 320 => 360 - 320 = 40 => Turn = -40
    function amountOfTurn(H1,H2) {
    	var T = H2 - H1 ;
    	
    	System.println("Turn calc " + H1 + " => " + H2 + " Raw turn => " + T) ;

    	if (abs(T) > PI) {
    		if (T > 0.0) {
    			T = (PI - T) * (-1.0) ;
    		} else {
    			T = (PI + T) ;
    		}
    	}
    	
    	return T ;
    } 
    

    // The given info object contains all the current workout information.
    // Calculate a value and save it locally in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info) {
    
    	if (info.timerState == 3) {
	    	System.println("Distance = " + info.elapsedDistance + ", heading = " + info.currentHeading) ;

			if (mDistHist[4] != info.elapsedDistance) { 	    	
	    		
	    		for (var i = 1; i < mDistHist.size(); i++) {
	    			mDistHist[i-1] = mDistHist[i] ;
	    			mHeadHist[i-1] = mHeadHist[i] ;
	    		}
	    		mDistHist[4] = info.elapsedDistance ;
	    		mHeadHist[4] = info.currentHeading ;
	    		
	    		mTurn[0] = mTurn[1] ;
	    		mTurn[1] = mTurn[2] ;
	    		mTurn[2] = mTurn[3] ;
	    		mTurn[3] = amountOfTurn(mHeadHist[3], mHeadHist[4]) ;
	    	
	    		for (var i = 0 ; i < mTurn.size(); i++) {
	    			System.println("Turn of " + mTurn[i]) ;
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
