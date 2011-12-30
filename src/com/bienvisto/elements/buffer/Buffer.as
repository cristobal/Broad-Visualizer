package com.bienvisto.elements.buffer
{
	import com.bienvisto.core.aggregate.Aggregate;
	
	/**
	 * Buffer.as
	 * 
	 * @author Cristobal Dabed
	 */ 
	public final class Buffer extends Aggregate
	{
		public function Buffer(time:uint, size:int)
		{
			super(time);
			_size = size;
		}
		
		/**
		 * @private
		 */ 
		private var _size:int;
		
		/**
		 * @readonly size
		 * 	The number of packets stored in the buffer
		 */ 
		public function get size():int
		{
			return _size;
		}
	}
}