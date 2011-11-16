package com.bienvisto.elements.transmissions
{
	import com.bienvisto.util.Tools;
	import com.bienvisto.core.Visualizer;
	import com.bienvisto.elements.network.Node;
	import com.bienvisto.elements.NodeBase;


	public class TransmissionNode extends NodeBase
	{
		/**
		 * A node will be highlited if it transmitted a packet in the last 
		 * HIGHLIGHTING_WINDOW milliseconds
		 */
		protected static const HIGHLIGHTING_WINDOW:uint = 50;
		/**
		 * A communication will be rendered if it occured in the last 
		 * COMMUNICATION_HIGHLIGHTING_WINDOW milliseconds
		 */
		protected static const COMMUNICATION_HIGHLIGHTING_WINDOW:uint = 500;
		
		/**
		 * Color used to highlight communications (the arrow between source and
		 * destination)
		 */
		protected static const COMMUNICATION_HIGHLIGHT_COLOR:uint = 0x6383FF;
		/**
		 * Color used to highlight transmissions (any kind of transmitted 
		 * packet). In the visualization this corresponds to the nodes blinking
		 */
		protected static const TRANSMISSION_HIGHLIGHT_COLOR:uint = 0xFFF94A;
		
		/**
		 * Builds a new node
		 *
		 * @param id  The id of the node in the simulation
		 */
		public function TransmissionNode(id:int, node:Node)
		{
			super(id, node);
		}
		
		
		/**
		 * Adds a new transmission performed by this node
		 *
		 * @param ms The time elapsed, in milliseconds, since the beginning of
		 * the simulation until the node performed this transmission
		 * @param size The size of the packet transmitted
		 */
		public function addTransmission(ms:uint, destination:int, size:Number):TransmissionKeypoint
		{
			var nt:TransmissionKeypoint = new TransmissionKeypoint(ms, id_, destination, size);
			keypoints_.push(nt);
			
			// node.addTransmission(ms, destination, size);
			return nt;
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
			
			updateGraphics(mid, millisecondsTotal);
		}
		
		
		/**
		 * Draws all transmissions occured within the highlighting window of time
		 *
		 * @param startingKeypoint keypoint representing the last transmission
		 * performed by the node.
		 */
		protected function updateGraphics(startingKeypoint:int, millisecondsTotal:uint):void
		{
			
			// If the last packet was transmitted within the highlighting 
			// window, we highlight the node in the topology element
			if (keypoints_[startingKeypoint].milliseconds + HIGHLIGHTING_WINDOW > 
				millisecondsTotal)
			{
				Visualizer.topology.highlightNode(id_, TRANSMISSION_HIGHLIGHT_COLOR);
			}
			
			// Clear the graphics layer
			graphics.clear();
			
			// Draw all transmissions (as arrows) in the highlighting window
			while (startingKeypoint >=0 && 
				keypoints_[startingKeypoint].milliseconds + 
				COMMUNICATION_HIGHLIGHTING_WINDOW > millisecondsTotal)
			{
				Tools.drawArrow(Visualizer.topology.getNodePosition(id_),
								Visualizer.topology.getNodePosition(
								(keypoints_[startingKeypoint] as TransmissionKeypoint).destination),
								graphics,
								COMMUNICATION_HIGHLIGHT_COLOR,
								2);
				
				startingKeypoint--;
			}
		}
	}
}
