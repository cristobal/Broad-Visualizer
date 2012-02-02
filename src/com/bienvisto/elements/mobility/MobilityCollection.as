package com.bienvisto.elements.mobility
{
	import com.bienvisto.core.aggregate.Aggregate;
	import com.bienvisto.core.aggregate.AggregateCollection;
	
	import flash.utils.Dictionary;
	
	public final class MobilityCollection extends AggregateCollection
	{
		public function MobilityCollection()
		{
			super();
			clear();
		}
		
		/**
		 * @private
		 */ 
		private var cache:Dictionary = new Dictionary();
		
		/**
		 * @override
		 */ 
		override public function findNearest(time:uint):Aggregate
		{
			if (time in cache) {
				return Aggregate(cache[time]);
			}
			
			var item:Aggregate = super.findNearest(time);
			cache[time] = item;
			
			return item;
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