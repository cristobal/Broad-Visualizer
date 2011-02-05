package com.bienvisto.elements.template_element
{
	import com.bienvisto.core.Tools;
	import com.bienvisto.core.Visualizer;

	import com.bienvisto.elements.NodeBase;



	/**
	 * Template class for a new Node
	 */
	public class Node extends NodeBase
	{




		/**
		 * Constructor of the class
		 */
		public function Node(nodeId:int)
		{
			super(nodeId);
			
			updateGraphics();
		}


		// Template for the function that should be used to add new keypoints
		/*public function addKeypoint(..., ms:uint):void
		{
			keypoints_.push(new TemplateKeypoint(..., ms, id_));
		}*/


		/**
		 * Updates the status of the node to represent this node at
		 * millisecondsTotal
		 *
		 * @param millisecondsTotal Milliseconds since the beginning of the
		 * simulation
		 */
		public function goTo(millisecondsTotal:uint):void
		{
			// Binary search for the keypoint corresponding to millisecondsTotal
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
			
			// "mid" will be the index in keypoints_ of the last keypoint for 
			// millisecondsTotal
		}



		/**
		 * Updates the graphics for this node.
		 */
		protected function updateGraphics():void
		{
			graphics.clear(); // Clear the graphics layer
			
			// update the graphics here using the ActionScript API
			// see: http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/display/Graphics.html
		}

	}

}
