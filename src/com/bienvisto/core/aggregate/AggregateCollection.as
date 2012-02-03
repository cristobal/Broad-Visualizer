package com.bienvisto.core.aggregate
{
	import flash.utils.Dictionary;
	import flash.utils.getTimer;

	// TODO: Optimize lookup's
	/**
	 * AggregateCollection.as
	 *  
	 * @author Cristobal Dabed
	 */ 
	public class AggregateCollection
	{
		//--------------------------------------------------------------------------
		//
		//  Constants
		//
		//--------------------------------------------------------------------------
		/**
		 * @public 
		 */ 
		public static const SAMPLE_TIME:uint = 100; // update/normalize at each 100ms.
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		public function AggregateCollection()
		{
			
		}
		
		/**
		 * @private 
		 * 	A map of aggregate keys for this collection
		 */ 
		protected var keys:Dictionary = new Dictionary();
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 * 	A vector of aggregate items for this collection.
		 */ 
		protected var _items:Vector.<Aggregate> = new Vector.<Aggregate>();
		
		/**
		 * @readonly items
		 */ 
		public function get items():Vector.<Aggregate>
		{
			return _items;
		}
		
		/**
		 * @readonly size
		 */ 
		public function get size():uint 
		{
			return _items.length;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Get first item
		 */ 
		public function first():Aggregate
		{
			return size > 0 ? _items[0] : null;
		}
		
		/**
		 * Get last item
		 */ 
		public function last():Aggregate
		{
			return size > 0 ? _items[size - 1] : null;
		}
		
		/**
		 * Add a item to the collection
		 * 
		 * @param
		 */
		public function add(item:Aggregate):void
		{
			_items.push(item);
			addAggregateKey(item);
		}
		
		/**
		 * Add key
		 * 
		 * @param item
		 */ 
		private function addAggregateKey(item:Aggregate):void
		{
			var key:int   = items.length - 1;
			var time:uint = item.time - (item.time % SAMPLE_TIME);
			var total:int = 1;
			
			if (time in keys) {
				keys[time] = null; // null old reference
			}
			
			var aggregateKey:AggregateKey = new AggregateKey(key, item.time);
			keys[time]       = aggregateKey;
		}
		
		
		/**
		 * Sample items
		 * 
		 * @param time
		 * @param windowSize
		 */ 
		public function sampleItems(time:uint, windowSize:uint):Vector.<Aggregate>
		{
			var samples:Vector.<Aggregate> = new Vector.<Aggregate>();
			if (time > 0) {
				
				var startTime:Number = time - windowSize;
				if (startTime < 0) {
					startTime = 0;
				}
				
				var key:int = findNearestKey(time);	
				var sample:Aggregate;
				for (var i:int = key + 1; i--;) {
					sample = _items[i];
					if (sample.time < startTime) {
						break;
					}
					
					// add only if inside window
					if (sample.time > time) {
						continue;
					}
					
					samples.push(sample);
				}
			}
			
			return samples;
		}
		
		/**
		 * Sample total
		 * 
		 * @param time
		 */ 
		public function sampleTotal(time:uint):int
		{
			return findNearestKey(time) + 1;
		}
		
		/**
		 * Find nearest
		 * 
		 * @param time
		 */ 
		public function findNearest(time:uint):Aggregate
		{
			var item:Aggregate;
			
			var key:int = findNearestKey(time);
			if (key >= 0) {
				item = _items[key];	
			}
			
			return item;
		}
		
		/**
		 * Find nearest key
		 * 
		 * @param time
		 */ 
		public function findNearestKey(time:uint):int
		{
			var key:int = -1;
			
			// var keyTime:uint = time - (time % SAMPLE_TIME); // All values from the Simulation are clamped to 100ms
			var aggregateKey:AggregateKey = AggregateKey(keys[time]);
			if (aggregateKey) {
				key = aggregateKey.key;			
				if (time < aggregateKey.time) {
					while (key > 0 && time > _items[key].time) {
						key--;
					}
				}
			}
			else {
				key = findNearestKeyMid(time);
				
				aggregateKey  = new AggregateKey(key, time);
				keys[time] = aggregateKey;
			}
			
			return key;
		}
		
		
		/**
		 * Find nearest key mid
		 * 
		 * @param time
		 */ 
		public function findNearestKeyMid(time:uint):int 
		{
			var total:int = size; 
			var max:int   = size - 1;
			var min:int   = 0;
			var key:int	  = -1;
			
			if (size == 0) {
				return key;
			}
			
			do
			{
				key = min + int((max - min) / 2);
				if (time > _items[key].time) {
					min = key + 1;
				}
				else {
					max = key - 1;
				}
				
			} 
			while (
				key < total - 1 && 
				max >= min  &&
				(_items[key].time > time || time > _items[key + 1].time)
			);
			
			
			return key;
		}
	}
}