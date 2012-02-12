package com.broad.elements.routing
{
	/**
	 * A single entry of a routing table
	 */
	public class RoutingTableEntry
	{
		
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
		 * @private
		 * 	Id of the destination node
		 */
		private var _destination:int;
		
		/**
		 * Id of the destination node
		 */
		public function get destination():int 
		{ 
			return _destination; 
		}

		/**
		 * @private
		 * 	If of next node in the path to the destination
		 */
		private var _next:int;
		
		/**
		 * If of next node in the path to the destination
		 */
		public function get next():int 
		{ 
			return _next; 
		}
		
		/**
		 * @private
		 * 	Number of hops until the destination node.
		 */
		private var _distance:int;
		
		/**
		 * Number of hops until the destination node
		 */
		public function get distance():int 
		{ 
			return _distance; 
		}
		
		/**
		 * To string
		 */ 
		public function toString():String 
		{
			return destination + " - " + next + ", hops: " + distance;	
		}
	
	}
}
