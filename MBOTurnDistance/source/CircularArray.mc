// A fixed sized data structure where adding a new element to a full array
// will remove the oldest element in the array
class CircularArray {

	private var mSize ;
	private var mData ;
	
	private var fst = 0 ;  // First item
	private var lst = 0 ;  // Last item
	private var pos = 0 ;  // Used when iterating over the array

	function initialize(size) {
		me.mSize = size ;
		mData = new [mSize] ;
	}
	
	// Add a new element into the circular array
	function add(val) {
		lst++ ;
		if (lst >= mSize) {
			lst = 0 ;
		}
		
		mData[lst] = val ;
		
		if (lst == fst) {
			fst++ ;
			if (fst >= mSize) {
				fst = 0 ;
			}
		}
	}
	
	// If lst == fst then nothing has been added and the circular array
	// is empty.
	function isEmpty() {
		return lst == fst ;
	}
	
	// Return the 1st item in the array and set the position for subsequent calls
	// to next 
	function first() {
		pos = fst ;
		return mData[pos] ;
	}
	
	// Return the next item from the array
	function next() {
		pos++ ;
		if (pos == mSize) {
			pos = 0 ; 
		}
		return mData[pos] ;
	}
	
	// Return the previous item from the array
	function previous() {
		pos-- ;
		if (pos < 0) {
			pos = mSize - 1 ;
		}
		return mData[pos] ;
	}
	
	// Return the last item from the array
	function last() {
		pos = lst ;
		return mData[pos] ;
	}
	
	// Return true if now at the end of the circular array
	function isLast() {
		return pos == lst ;
	}
	
}