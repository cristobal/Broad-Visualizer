package com.broad.core.events
{
	import flash.display.MovieClip;
	import flash.events.Event;
 
	/**
	 * Events associated with some kind of time value. This time value will be
	 * stored in milliseconds
	 *
	 * @author Miguel Santirso
	 * @author Cristobal Dabed
	 */
	public class TimedEvent extends Event
	{
		/**
		 * @public
		 */ 
		public static const ELAPSED:String = "elapsed";

		/**
		 * Constructor of the event.
		 *
		 * @param elapsed A time value in milliseconds associated with this event
		 */
		public function TimedEvent (type:String, bubbles:Boolean = false, cancelable:Boolean = false, elapsed:uint = 0)
		{
			super(type, bubbles, cancelable);
			
			_elapsed = elapsed;
		}
		
		
		/**
		 * The time value
		 */
		private var _elapsed:uint;

		/**
		 * @readonly elapsed time in ms
		 */ 
		public function get elapsed():uint { 
			return _elapsed; 
		}
		
		/**
		 * @override
		 */ 
		public override function clone():Event
		{
			return new TimedEvent(type, bubbles, cancelable, elapsed);
		}


	}
}
