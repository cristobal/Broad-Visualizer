package com.bienvisto.elements.buffer
{
	import com.bienvisto.core.Tools;
	import com.bienvisto.core.Vector2D;
	import com.bienvisto.core.Visualizer;
	import com.bienvisto.elements.Node;
	import com.bienvisto.elements.NodeBase;


	public class BufferNode extends NodeBase
	{
		
		/**
		 * Builds a new node
		 *
		 * @param id The id of the node in the simulation
		 */
		public function BufferNode(id:int, node:Node)
		{
			super(id, node);
		}
		
		/**
		 * Adds a new buffer operation related to this node
		 *
		 * @param ms The time elapsed, in milliseconds, since the beginning of
		 * the simulation
		 */
		public function addBufferChange(ms:uint, currentSize:uint):BufferChange
		{
			var bc:BufferChange = new BufferChange(ms, id_, currentSize);
			keypoints_.push(bc);
			return bc;
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
			{
				return;
			}
			
			
			node.bufferSize = (keypoints_[mid] as BufferChange).bufferSize; 
			updateGraphics(node.bufferSize);
		}
		
		
		protected function updateGraphics(size:Number):void
		{
			var nodePos:Vector2D = Visualizer.topology.getNodePosition(id_);
			graphics.clear();
			graphics.lineStyle(5, 0xAA8888);
			graphics.moveTo(nodePos.x, nodePos.y);
			graphics.lineTo(nodePos.x, nodePos.y - size/3000);
		}
	}
}
