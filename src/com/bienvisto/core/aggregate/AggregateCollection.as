package com.bienvisto.core.aggregate
{
	/**
	 * AggregateCollection.as
	 *  
	 * @author Cristobal Dabed
	 */ 
	public final class AggregateCollection
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
		private var lut:Vector.<Number> = new Vector.<Number>;
		
		/**
		 * @private
		 */ 
		private var threshold:int = 10; 
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 * 	A vector of aggregate items for this collection.
		 */ 
		private var _items:Vector.<Aggregate> = new Vector.<Aggregate>();
		
		/**
		 * @readonly items
		 */ 
		public function get items():Vector.<Aggregate>
		{
			return _items;
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
		public function getTotal(time:uint = uint.MAX_VALUE):Number
		{
			return 0;
		}
	}
}