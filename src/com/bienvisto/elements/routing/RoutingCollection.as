package com.bienvisto.elements.routing
{
	import com.bienvisto.core.aggregate.Aggregate;
	import com.bienvisto.core.aggregate.AggregateCollection;
	
	import flash.utils.Dictionary;
	
	public final class RoutingCollection extends AggregateCollection
	{
		public function RoutingCollection()
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
			return super.findNearest(time);
/*			var item:Aggregate;
			
			
			
			if (!(time in cache)) {
				item = super.findNearest(time);
				
				cache[time] = item;
			}
			else {
				item = cache[item] as Aggregate;
			}
			
			return item;*/
		}
	}
}