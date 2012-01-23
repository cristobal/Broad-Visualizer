package com.bienvisto.elements.routing
{
	public class SimpleRoute extends RoutingTableEntry
	{
		public function SimpleRoute(from:int, dest:int, next:int = -1, distance:int = 1)
		{
			super(dest, next, distance);
			
			_from = from;
		}
		
		/**
		 * @private
		 */ 
		private var _from:int;
		
		/**
		 * @readonly from
		 */ 
		public function get from():int
		{
			return _from;
		}
		
		/**
		 * @private
		 */
		private var _complete:Boolean = false;
		
		/**
		 * @readwrite complete
		 */ 
		public function get complete():Boolean
		{
			return _complete;
		}
		
		public function set complete(value:Boolean):void
		{
			_complete = value;
		}
		
		/**
		 * @private
		 */
		private var _traceback:Boolean = false;
		
		/**
		 * @readwrite traceback
		 */ 
		public function get traceback():Boolean
		{
			return _traceback;
		}
		
		public function set traceback(value:Boolean):void
		{
			_traceback = value;
		}
		
		/**
		 * @private
		 */ 
		private var _paths:Vector.<int>;
		
		/**
		 * @readwrite paths
		 */ 
		public function get paths():Vector.<int>
		{
			return _paths;
		}
		
		public function set paths(value:Vector.<int>):void
		{
			_paths = value;	
		}
		
		/**
		 * To string
		 */ 
		override public function toString():String 
		{
			return [from, next, destination, "hops: ", distance, "complete: ", complete].join(" - ");	
		}
	}
}