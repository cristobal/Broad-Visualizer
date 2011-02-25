package com.bienvisto.elements
{

	/**
	 * NodeManager.as
	 * 	Manages all the nodes (basic pooling). 
	 * 
	 * @author Cristobal Dabed
	 * @version {{VERSION_NUMBER}}
	 */ 
	public class NodeManager
	{
		/**
		 * Constructor
		 */ 
		public function NodeManager()
		{
			setup();
		}
		
		
		/**
		 * @protected
		 */ 
		protected var _nodes:Vector.<Node>;
		
		/**
		 * @readonly nodes
		 */ 
		public function get nodes():Vector.<Node>
		{
			return _nodes.concat(); // Returns a shallow copy.
		}
		
		/**
		 * Setup
		 */ 
		private function setup():void
		{
			_nodes = new Vector.<Node>;
		}
		
		/**
		 * Find node by id
		 * 
		 * @param id The node id to lookup
		 * @return Returns the node with the given id, if none was found a new one will be created.
		 */ 
		public function findNodeById(id:uint):Node
		{
			var node:Node = null;
			var flag:Boolean = false;
			
			for each(node in _nodes) {
				if (node.id == id) {
					flag = true;
					break;
				}
			} 
			
			if (!flag) {
				node = new Node(id);
				_nodes.push(node);	
			}
			
			return node;
		}
	}
}