package com.bienvisto.elements.routing
{

	import com.bienvisto.core.Vector2D;
	import com.bienvisto.core.Visualizer;
	import com.bienvisto.elements.NodeBase;
	import com.bienvisto.util.Tools;
	
	import flash.utils.*;



	/**
	 * Stores all routing tables of a node during the simulation. Also, displays
	 * all links originating from this node
	 */
	public class Node extends NodeBase
	{

		/**
		 * Constructor of the class
		 */
		public function Node(nodeId:int)
		{
			super(nodeId);
		}


		/**
		 * Changes the active routing table to the appropriate for the time being
		 * displayed
		 *
		 * @param millisecondsTotal Milliseconds since the beginning of the
		 * simulation
		 */
		public function goTo(millisecondsTotal:uint):void
		{
			// Search for the waypoint corresponding to millisecondsTotal
			var min:int = 0;
			var max:int = keypoints_.length-1;
			var mid:int;
			do
			{
				mid = min + ( (max - min) / 2 );
				if ( millisecondsTotal > keypoints_[mid].milliseconds )
					min = mid + 1;
				else
					max = mid - 1;
			} while(mid < keypoints_.length-1 && max >= min &&
					(keypoints_[mid].milliseconds > millisecondsTotal || 
					keypoints_[mid+1].milliseconds <= millisecondsTotal));
			
			updateGraphics(keypoints_[mid] as RoutingTable);
		}


		/**
		 * Adds a new table associated to this node
		 * 
		 * @param table Array of objects containing destNode, nextNode and distance attributes
		 * @param ms Milliseconds since the beginning of the simulation until
		 * this routing table became active
		 */
		public function addTable(table:String, ms:uint):void
		{
			var entriesArray:Vector.<RoutingTableEntry> = new Vector.<RoutingTableEntry>();
			
			var entries:Array = table.split(",");
			
			var i:int = 0;
			var n:int = entries.length;
			while (i < n)
			{
				// The distance is not currently used, always -1
				entriesArray.push(new RoutingTableEntry(entries[i], entries[i+1], -1));
				i+=2;
			}
			
			keypoints_.push(new RoutingTable(entriesArray, ms, id_));
		}


		/**
		 * Draws all lines in the active routing table
		 *
		 * @param table The active routing table to be rendered
		 */
		public function updateGraphics(table:RoutingTable):void
		{

			var highlighted:Boolean = false;
			
			graphics.clear(); // Clean all lines from previous drawings
			
			
			for (var i:int = 0, l:int = table.entries.length; i < l; i++) {
				drawPath(table.entries[i]);	
			}
		}
		
		private function drawPath(entry:RoutingTableEntry):void
		{
			
			var highlighted:Boolean = 
				Visualizer.topology.isNodeSelected(id_) ||
				Visualizer.topology.isNodeSelected(entry.next) ||
				Visualizer.topology.isNodeSelected(entry.destination);
			
			if (highlighted) {
				graphics.lineStyle(3, 0xff6622)
			}
			else {
				graphics.lineStyle(1, 0xcccccc);
			}
			
			var origin:Vector2D	= Visualizer.topology.getNodePosition(id_), 			  // Origin of a link, this current node
				dest:Vector2D	= Visualizer.topology.getNodePosition(entry.destination), // Destination of the link 
				next:Vector2D	= Visualizer.topology.getNodePosition(entry.next);		  // And the Next hop
			
			/**
			 * Routing table can be invalid some times
			 */
			if (origin && dest)
			{
				graphics.moveTo(origin.x, origin.y);
				graphics.lineTo(dest.x, dest.y);
					
				if (next) {
					graphics.lineTo(next.x, next.y);
				}
			}	
		}


	}

}
