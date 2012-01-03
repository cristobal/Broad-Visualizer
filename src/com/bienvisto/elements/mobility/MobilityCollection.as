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
			var item:Aggregate;
			
			if (!(time in cache)) {
				item = super.findNearest(time);
				if (item) {
					cache[time] = item;
				}
			}
			else {
				item = cache[time];		
			}
				
			return item;
		}
	}
}