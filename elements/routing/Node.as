package elements.routing
{

	import flash.utils.*;
	
	import core.Vector2D;
	import core.Tools;
	import core.Visualizer;

	import elements.NodeBase;



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
			
			while (i+1 < n)
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
			var origin:Vector2D; // Origin of a link
			var next:Vector2D; // Next hop of a path
			var highlighted:Boolean = false;
			
			graphics.clear(); // Clean all lines from previous drawings
			
			for each (var entry:RoutingTableEntry in table.entries)
			{
				highlighted = Visualizer.topology.isNodeSelected(id_) ||
							Visualizer.topology.isNodeSelected(entry.next) ||
							Visualizer.topology.isNodeSelected(entry.destination);
				
				if (highlighted)
					graphics.lineStyle(3, 0xff6622)
				else
					graphics.lineStyle(1, 0xcccccc);
				
				origin = Visualizer.topology.getNodePosition(id_);
				next = Visualizer.topology.getNodePosition(entry.next);

				/**
				 * Routing table can be invalid some times
				 */
				if (origin != null && next != null)
				{
					graphics.moveTo(origin.x, origin.y);
					graphics.lineTo(next.x, next.y);
				}
			}
		}


	}

}
