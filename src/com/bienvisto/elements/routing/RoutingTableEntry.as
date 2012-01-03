package com.bienvisto.elements.routing
{
	import com.bienvisto.util.Tools;

	/**
	 * A single entry of a routing table
	 */
	public final class RoutingTableEntry
	{
		/**
		 * Id of the destination node
		 */
		private var _destination:int;
		/**
		 * If of next node in the path to the destination
		 */
		private var _next:int;
		/**
		 * Number of hops until the destination node. This variable can be null
		 */
		private var _distance:int;
		
		/**
		 * Creates a new entry of a routing table
		 * 
		 * @param dest Id of the destination node
		 * @param next Id of next node in the path
		 * @param distance Number of hops needed to reach the destination node
		 */
		public function RoutingTableEntry(dest:int, next:int, distance:int)
		{
			_destination = dest;
			_next = next;
			_distance = distance;
		}
		
		/**
		 * Id of the destination node
		 */
		public function get destination():int { return _destination; }
		/**
		 * If of next node in the path to the destination
		 */
		public function get next():int { return _next; }
		/**
		 * Number of hops until the destination node
		 */
		public function get distance():int { return _distance; }
		
		/**
		 * To string
		 */ 
		public function toString():String 
		{
			return destination + " - " + next + ", hops: " + distance;	
		}
	}

}
