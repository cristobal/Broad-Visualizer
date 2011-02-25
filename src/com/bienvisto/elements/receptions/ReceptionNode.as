package com.bienvisto.elements.receptions
{
	import com.bienvisto.core.Tools;
	import com.bienvisto.core.Vector2D;
	import com.bienvisto.core.Visualizer;
	import com.bienvisto.elements.Node;
	import com.bienvisto.elements.NodeBase;
	
	import flash.display.Sprite;


	public class ReceptionNode extends NodeBase
	{
		/**
		 * A node will be highlited if it transmitted a packet in the last 
		 * HIGHLIGHTING_WINDOW milliseconds
		 */
		protected static const HIGHLIGHTING_WINDOW:uint = 500;
		
		/**
		 * Color used to highlight receptions for this node
		 */
		protected static const HIGHLIGHT_COLOR_OWN:uint = 0x70FAA3;
		/**
		 * Color used to highlight receptions at this node but that were 
		 * sent to other nodes
		 */
		protected static const HIGHLIGHT_COLOR_OTHERS:uint = 0xFFDA9E;
		
		/**
		 * Builds a new node
		 *
		 * @param id The id of the node in the simulation
		 */
		public function ReceptionNode(id:int, node:Node)
		{
			super(id, node);
		}
		
		
		/**
		 * @inheritDoc
		 */
		public override function cleanUp():void
		{
			super.cleanUp();
		}
		
		
		/**
		 * Adds a new reception performed by this node
		 *
		 * @param nr The new reception to add
		 */
		public function addReception(nr:Reception):Reception
		{
			keypoints_.push(nr);
			
			node.addReception(nr.milliseconds, nr.source, nr.size);
			return nr;
		}
		
		
		/** 
		 * Updates the status of the node to represent this node at
		 * millisecondsTotal
		 *
		 * @param millisecondsTotal Milliseconds since the beginning of the
		 * simulation
		 */
		public function goTo(millisecondsTotal:uint):void
		{
			
			// Search for the reception corresponding to millisecondsTotal
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
			
			// If the reception is after the moment visualized, we just return
			if (millisecondsTotal < keypoints_[mid].milliseconds)
				return;
			
			// Count of how many packets have been received for this node within the
			// highlighting window
			var nOwnPackets:int = 0;
			// Count of how many packets have been received for other nodes within
			// the highlighting window
			var nOtherPackets:int = 0;
		

			
			// Count how many packets are in the highlighting window
			while (mid >=0 && 
				keypoints_[mid].milliseconds + HIGHLIGHTING_WINDOW > millisecondsTotal)
			{
				// Check if this reception is for this node or if it was for
				// other node
				if ((keypoints_[mid] as Reception).destination == id_)
					nOwnPackets++; // It actually was for this node
				else
					nOtherPackets++; // It was for other node
				mid--;
			}
			
			updateGraphics(nOwnPackets, nOtherPackets);
		}


		/**
		 * Updates the graphics for this node.
		 * Draws two overlaped circles. The first circle represents in green the
		 * amount of packets received for this node. The second one represents
		 * in light brown the amount of packets received by this node but that
		 * where destinated to other nodes
		 *
		 * @param nOwnPackets Number of packets sent to this node
		 * @param nOtherpackets Number of packets received by this node but
		 * destinated to other nodes
		 */
		protected function updateGraphics(nOwnPackets:int, nOtherPackets:int):void
		{
			graphics.clear();
			
			if (Visualizer.topology.getNodePosition(id_) != null)
			{
				// Draw circle for packets for other nodes
				graphics.beginFill(HIGHLIGHT_COLOR_OTHERS, 0.5);
				graphics.drawCircle(Visualizer.topology.getNodePosition(id_).x, 
					Visualizer.topology.getNodePosition(id_).y, 9 + 
					0.5*(nOwnPackets+0.5*nOtherPackets));
				graphics.endFill();
				
				// Circle of packets for this node (will be smaller, green color)
				graphics.beginFill(HIGHLIGHT_COLOR_OWN);
				graphics.drawCircle(Visualizer.topology.getNodePosition(id_).x, 
					Visualizer.topology.getNodePosition(id_).y, 9 +
					0.5*nOwnPackets);
				graphics.endFill();
			}
		}

	}
}
