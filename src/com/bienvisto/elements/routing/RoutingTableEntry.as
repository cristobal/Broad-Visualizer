package com.bienvisto.elements.routing
{
	import com.bienvisto.core.Tools;

	/**
	 * A single entry of a routing table
	 */
	public class RoutingTableEntry
	{
		/**
		 * Id of the destination node
		 */
		protected var destination_:int;
		/**
		 * If of next node in the path to the destination
		 */
		protected var nextNode_:int;
		/**
		 * Number of hops until the destination node. This variable can be null
		 */
		protected var distance_:int;
		
		/**
		 * Creates a new entry of a routing table
		 * 
		 * @param dest Id of the destination node
		 * @param next Id of next node in the path
		 * @param distance Number of hops needed to reach the destination node
		 */
		public function RoutingTableEntry(dest:int, next:int, distance:int)
		{
			destination_ = dest;
			nextNode_ = next;
			distance_ = distance;
		}
		
		/**
		 * Id of the destination node
		 */
		public function get destination():int { return destination_; }
		/**
		 * If of next node in the path to the destination
		 */
		public function get next():int { return nextNode_; }
		/**
		 * Number of hops until the destination node
		 */
		public function get distance():int { return distance_; }
	}

}
