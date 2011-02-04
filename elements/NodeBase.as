package elements
{

	import flash.display.Sprite;



	/**
	 * Base class to be extended by all elements. This class helps to store the
	 * simulation data in an appropriate format to be visualized
	 */
	public class NodeBase extends Sprite
	{
		/**
		 * Id of the node in the simulation
		 */
		protected var id_:int;
		
		/**
		 * Vector of the keypoints associated to this node
		 */
		protected var keypoints_:Vector.<KeypointBase>;
		
		/**
		 * Total milliseconds ellapsed when the update function was last called
		 */
		protected var lastUpdate_:uint;
		
		
		
		/**
		 * Builds a new node
		 *
		 * @param nodeId Id of the node in the simulation
		 */
		public function NodeBase(nodeId:int)
		{
			id_ = nodeId;
			
			keypoints_ = new Vector.<KeypointBase>();
			lastUpdate_ = 0;
		}
		
		
		/**
		 * Tries to free all memory used by a node
		 */
		public function cleanUp():void
		{
			keypoints_ = null;
		}
		
		
		/**
		 * Id of the node
		 */
		public function get id():int { return id_; }
	}
}
