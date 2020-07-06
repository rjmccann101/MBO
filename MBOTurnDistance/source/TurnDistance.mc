// A class to hold the turn distances
class TurnDistance {

	public var mTurnType ;
	public var mTurnDistance  ;
	
	function initialize(turnType, distance) {
		me.mTurnType = turnType ;
		me.mTurnDistance = distance ;
	}
	
	function setDistance(distance) {
		me.mTurnDistance = distance ;
	}
	
}