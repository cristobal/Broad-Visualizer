package com.bienvisto.elements
{

	import flash.display.Sprite;
	import com.bienvisto.elements.network.Node;



	/**
	 * Base class to be extended by all elements. This class helps to store the
	 * simulation data in an appropriate format to be visualized
	 */
	public class NodeBase extends Sprite
	{
		
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
		 * @param id The id of the node in the simulation
		 */
		public function NodeBase(id:int, node:Node=null)
		{
			id_ = id;
			_node = node;
			
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
		 * Id of the node in the simulation
		 */
		protected var id_:int;
		
		/**
		 * @readonly id
		 */
		public function get id():int { 
			return id_; 
		}
		
		
		/**
		 * @private
		 */ 
		private var _node:Node;
		
		/**
		 * @readonly node
		 */ 
		public function get node():Node
		{
			return _node;
		}
		
	}
}
