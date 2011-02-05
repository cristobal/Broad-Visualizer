package com.bienvisto.elements
{

	/**
	 * Class to be extended by all classes representing some kind of keypoint:
	 * Waypoints, routing tables, transmissions...
	 * A keypoint is a piece of information linked to a node and to a time in
	 * milliseconds.
	 * For instance, in the topology element, the keypoints would be the
	 * waypoints that define the movement of a node through time
	 */
	public class KeypointBase
	{
	
		/**
		 * Milliseconds passed since the beginning of the simulation until the
		 * moment the node passed through this keypoint
		 */
		protected var milliseconds_:uint;
		
		/**
		 * Id of the node related to this keypoint
		 */
		protected var nodeId_:int;
	
		/**
		 * Constructs a new keypoint
		 *
		 * @param ms Milliseconds elapsed since the beginning of the simulation
		 * until the node passed through this waypoint
		 * @param node Id of the node associated to this keypoint
		 */
		public function KeypointBase(ms:uint, node:int)
		{
			milliseconds_ = ms;
			nodeId_ = node;
		}
	
	
		/**
		 * Milliseconds passed since the beginning of the simulation until the
		 * moment the node passed through this keypoint
		 */
		public function get milliseconds():uint { return milliseconds_; }
		
		
		/**
		 * Id of the node related to this keypoint
		 */
		public function get nodeId():int { return nodeId_; }
	}

}
