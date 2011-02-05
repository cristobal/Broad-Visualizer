package com.bienvisto.core.events
{
	import flash.display.MovieClip;
	import flash.events.Event;
 
	/**
	 * Events associated with some kind of time value. This time value will be
	 * stored in milliseconds
	 *
	 * @author Miguel Santirso
	 */
	public class TimedEvent extends Event
	{

		/**
		 * The time value
		 */
		protected var milliseconds_:uint;


		/**
		 * Constructor of the event.
		 *
		 * @param milliseconds A time value in milliseconds associated with this event
		 */
		public function TimedEvent (type:String, ms:uint, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			
			milliseconds_ = ms;
		}


		public override function clone():Event
		{
			return new TimedEvent(type,milliseconds_, bubbles, cancelable);
		}


		public function get milliseconds():uint { return milliseconds_; }


	}
}
