package com.bienvisto.elements.routing
{

	import com.bienvisto.core.Vector2D;

	import com.bienvisto.elements.KeypointBase;


	/**
	 * Stores the routing table of a node at certain time in the simulation
	 */
	public class RoutingTable extends KeypointBase
	{

		/**
		 * Vector of routing table entries
		 */
		protected var entries_:Vector.<RoutingTableEntry>;


		/**
		 * Constructor of the class
		 *
		 * @param table Array containing all entries of the table
		 * @param ms Milliseconds elapsed since the beginning of the simulation
		 * until the node passed through this waypoint
		 * @param node Id of the node associated to this keypoint
		 */
		public function RoutingTable(entries:Vector.<RoutingTableEntry>, ms:uint, node:int)
		{
			super (ms, node);
			
			entries_ = entries;
		}


		/**
		 * Array of all entries in the table. The vector is composed of 
		 * RoutingTableEntry objects
		 */
		public function get entries():Vector.<RoutingTableEntry> { return entries_; }

	}
}
