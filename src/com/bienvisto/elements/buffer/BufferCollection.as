package com.bienvisto.elements.buffer
{
	import com.bienvisto.core.aggregate.AggregateCollection;
	
	import flash.utils.Dictionary;
	
	/**
	 * BufferCollection.as
	 * 
	 * @author Cristobal Dabed
	 */ 
	public final class BufferCollection extends AggregateCollection
	{
		public function BufferCollection()
		{
			super();
		}
		
		/**
		 * @private
		 */ 
		private var cache:Dictionary = new Dictionary();
		
		/**
		 * Find buffer
		 * 
		 * @param time
		 */ 
		public function findBuffer(time:uint):Buffer
		{
			var buffer:Buffer;
			
			if (!(time in cache)) {
				buffer = Buffer(findNearest(time));
				cache[time] = buffer;
			}
			else {
				buffer = Buffer(cache[time]);
			}
			
			return buffer;
		}
		
	}
}