package com.broad.io
{
	import flash.events.Event;
	
	/**
	 * ReaderEvent.as 
	 * 
	 * 
	 */ 
	public final class ReaderEvent extends Event
	{
		/**
		 * @public
		 */ 
		public static const READ_LINE:String = "readLine";
		
		public function ReaderEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, line:String = null)
		{
			super(type, bubbles, cancelable);
			_line = line;
		}
		
		/**
		 * @private
		 */ 
		private var _line:String;
		
		/**
		 * @readonly line
		 */ 
		public function get line():String
		{
			return _line;
		}
		
		override public function clone():Event
		{
			return new ReaderEvent(type, bubbles, cancelable, line);
		}
	}
}