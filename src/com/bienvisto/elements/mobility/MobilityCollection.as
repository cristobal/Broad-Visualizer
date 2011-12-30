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
		private var fnCache:Dictionary = new Dictionary();
		
		/**
		 * @override
		 */ 
		override public function findNearest(time:uint):Aggregate
		{
			var item:Aggregate;
			
			if (!(time in fnCache)) {
				item = super.findNearest(time);
				fnCache[time] = item;
			}
			else {
				item = fnCache[item] as Aggregate;		
			}
				
			return item;
		}
	}
}