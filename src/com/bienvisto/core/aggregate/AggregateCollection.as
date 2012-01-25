package com.bienvisto.core.aggregate
{
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
		//  Constructor
		//
		//--------------------------------------------------------------------------
		public function AggregateCollection()
		{
			
		}
		
		/**
		 * @private
		 */ 
		protected var lastTimeAdded:uint = 0;
		
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
		 * Add a item to the collection
		 * 
		 * @param
		 */
		public function add(item:Aggregate):void
		{
			_items.push(item);
			lastTimeAdded = item.time;
		}
		
		/**
		 * Remove a item from the collection
		 * 
		 * @param item
		 */ 
		public function remove(item:Aggregate):void
		{
			var value:Aggregate;
			for (var i:int = _items.length; i--;) {
				value = _items[i];
				if (value == item) {
					_items.splice(i, 1);
					break;
				}
			}
		}
		
		/**
		 * Get total 
		 * 
		 * @param  time
		 * @return Returns the total number
		 */ 
		public function getTotal(time:uint = uint.MAX_VALUE):int
		{
			return 0;
		}
		
		/**
		 * Count total 
		 * 
		 * @param  time
		 * @return Returns the total number
		 */
		public function countTotal(time:uint):int
		{
			var total:int = 0; 
			
			if (time > lastTimeAdded) {
				total = size;
			}
			else if (time > 0) {
				var item:Aggregate;
				for (var i:int = 0, l:int = size; i < l; i++) {
					item = _items[i];
					if (item.time > time) {
						break;
					}
					total++;
				}
			}
			
			return total;	
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
				
				var key:int = findNearestKeyMid(time);	
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
			var total:int = findNearestKeyMid(time) + 1;
			return total;
		}
		
		/**
		 * Find nearest
		 * 
		 * @param time
		 */ 
		public function findNearest(time:uint):Aggregate
		{
			var item:Aggregate;
			var key:int = -1;
			var total:int = _items.length;
			
			if (time > lastTimeAdded) {
				key = total - 1;
			}
			else {
				key = findNearestKeyMid(time);
			}
			
			if (key >= 0) {
				item = _items[key];	
			}
			
			
			return item;
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
				key = min + ( (max - min) / 2 );
				if ( time > _items[key].time) {
					min = key + 1;
				}
				else {
					max = key - 1;
				}
				
			} while (
				key < total - 1 && 
				max >= min  &&
				(_items[key].time > time || _items[key + 1].time <= time)
			);
			
			
			return key;
		}
		
		/**
		 * Find nearest key
		 * 
		 * @param time
		 */ 
		public function findNearestKey(time:uint):int
		{
			var key:int = -1;
			
			if (time <= lastTimeAdded) {
				if (size > 1) {
					key = int((size - 1) / 2);
					if (_items[key].time > time) {
						key = findNearestKeyFloor(time, key);
					}
					else {
						key = findNearestKeyCeil(time, key);
					}
				}
			}
			
			return key;
		}
		
		
		private function findNearestKeyFloor(time:uint, key:int):int
		{ 
			var item:Aggregate;
			for (var i:int = key + 1; i--;) {
				item = _items[i];
				if (item.time <= time) {
					break;
				}
			}
			key = i;
			
			return key;
		}
		
		private function findNearestKeyCeil(time:uint, key:int):int
		{ 
			var item:Aggregate;
			for (var i:int = key, l:int = _items.length; i < l; i++) {
				item = _items[i];
				if (item.time >= time) {
					break;
				}
			}
			key = i;
			if (key == l) {
				key = -1;
			}
			
			return key;
		}
		
	}
}