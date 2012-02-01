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
		 * Find buffer
		 * 
		 * @param time
		 */ 
		public function findBuffer(time:uint):Buffer
		{
			return Buffer(findNearest(time));
		}
		
	}
}