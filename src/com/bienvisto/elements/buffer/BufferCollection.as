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
		private var bufferCache:Dictionary = new Dictionary();
		
		/**
		 * Find buffer
		 * 
		 * @param time
		 */ 
		public function findBuffer(time:uint):Buffer
		{
			var buffer:Buffer;
			
			if (!(time in bufferCache)) {
				buffer = Buffer(findNearest(time));
				bufferCache[time] = buffer;
			}
			else {
				buffer = Buffer(bufferCache[time]);
			}
			
			return buffer;
		}
		
	}
}