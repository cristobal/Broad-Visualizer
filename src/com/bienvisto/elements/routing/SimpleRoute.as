package com.bienvisto.elements.routing
{
	public class SimpleRoute extends RoutingTableEntry
	{
		public function SimpleRoute(from:int, dest:int, next:int = -1, distance:int = 1, broken:Boolean = false)
		{
			super(dest, next, distance);
			
			_from = from;
			_broken = broken;
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
		private var _broken:Boolean;
		
		/**
		 * @readonly broken
		 */ 
		public function get broken():Boolean
		{
			return _broken;
		}
	}
}