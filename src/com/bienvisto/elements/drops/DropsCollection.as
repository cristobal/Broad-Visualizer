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
		}
		
		/**
		 * @private
		 */ 
		private var cache:Dictionary = new Dictionary();
		
		/**
		 * @override
		 */ 
		override public function sampleItems(time:uint, windowSize:uint):Vector.<Aggregate>
		{
			return super.sampleItems(time, windowSize);
/*			var samples:Vector.<Aggregate>;
			var key:String = String(time) + "," + String(windowSize);
			if (!(key in cache)) {
				var item:Aggregate = findNearest(time);
				if (item && item.time >= time) {
					samples = super.sampleItems(time, windowSize);
				}
				cache[key] = samples;
			}
			else {
				samples = Vector.<Aggregate>(cache[key]);
			}
			return samples;*/
		}
		
	}
}