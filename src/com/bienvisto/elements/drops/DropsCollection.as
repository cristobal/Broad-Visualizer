package com.bienvisto.elements.drops
{
	import com.bienvisto.core.aggregate.Aggregate;
	import com.bienvisto.core.aggregate.AggregateCollection;
	
	import flash.utils.Dictionary;
	
	/**
	 * DropsCollection.as
	 * 
	 * @author Cristobal Dabed
	 */ 
	public final class DropsCollection extends AggregateCollection
	{
		public function DropsCollection()
		{
			super();
			clear();
		}
		
		/**
		 * @private
		 */ 
		private var cache:Dictionary;
		
		/**
		 * @override
		 */ 
		override public function sampleItems(time:uint, windowSize:uint):Vector.<Aggregate>
		{
			var key:String = String(time) + "-" + String(windowSize);
			if (key in cache) {
				return Vector.<Aggregate>(cache[key]);
			}
						
			var samples:Vector.<Aggregate> = super.sampleItems(time, windowSize);
			cache[key] = samples;
			
			return samples;
		}
		
		/**
		 * Clear
		 */ 
		public function clear():void
		{
			cache = new Dictionary();
		}
	}
}