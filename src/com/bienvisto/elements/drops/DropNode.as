package com.bienvisto.elements.drops
{
	import com.bienvisto.core.Tools;
	import com.bienvisto.core.Visualizer;
	import com.bienvisto.elements.Node;
	import com.bienvisto.elements.NodeBase;


	public class DropNode extends NodeBase
	{
		/**
		 * A node will be highlited if it transmitted a packet in the last 
		 * HIGHLIGHTING_WINDOW milliseconds
		 */
		protected static const HIGHLIGHTING_WINDOW:uint = 50;
		
		
		/**
		 * Builds a new node
		 *
		 * @param nodeId Id of the node in the simulation
		 */
		public function DropNode(id:int, node:Node)
		{
			super(id, node);
		}
		
		
		/**
		 * Adds a new transmission performed by this node
		 *
		 * @param ms The time elapsed, in milliseconds, since the beginning of
		 * the simulation until the node performed this transmission
		 */
		public function addPacketDrop(ms:uint):PacketDrop
		{
			var np:PacketDrop = new PacketDrop(ms, id_);
			keypoints_.push(np);
			node.addDrop(ms);
			
			return np;
		}
		
		
		/**
		 * Updates the status of the node to represent this node at
		 * millisecondsTotal
		 *
		 * @param millisecondsTotal Milliseconds since the beginning of the
		 * simulation
		 */
		public function goTo(millisecondsTotal:uint):void
		{/*
			// Search for the transmission corresponding to millisecondsTotal
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
			
			if (millisecondsTotal < keypoints_[mid].milliseconds)
				return;
			
			if (keypoints_[mid].milliseconds + HIGHLIGHTING_WINDOW > 
				millisecondsTotal)
			{
				Visualizer.topology.highlightNode(id_);
			}*/
		}
		
	}
}
