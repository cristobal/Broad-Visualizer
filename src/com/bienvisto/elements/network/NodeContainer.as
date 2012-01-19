package com.bienvisto.elements.network
{
	import com.bienvisto.core.ISimulationObject;
	import com.bienvisto.core.parser.TraceSource;
	import com.bienvisto.util.log;

	/**
	 * NodeContainer.as
	 * 	Manages all the nodes (basic pooling). 
	 * 
	 * @author Cristobal Dabed
	 */ 
	public final class NodeContainer extends TraceSource implements ISimulationObject
	{
		/**
		 * Constructor
		 */ 
		public function NodeContainer()
		{
			super("Node Properties", "np");
		}
		
		/**
		 * @private
		 */ 
		private var _nodes:Vector.<Node> = new Vector.<Node>();
		
		/**
		 * @readonly nodes
		 */ 
		public function get nodes():Vector.<Node>
		{
			return _nodes.concat(); // Returns a shallow copy.
		}
		
		/**
		 * @readonly size
		 */ 
		public function get size():int 
		{
			return int(_nodes.length);	
		}
		
		/**
		 * Find node by id
		 * 
		 * @param id The node id to lookup
		 * @return Returns the node with the given id, if none was found a new one will be created.
		 */ 
		public function getNode(id:uint):Node
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
		
		/**
		 * @override
		 */ 
		override public function update(params:Vector.<String>):uint
		{
;
			// Format: nr <id> <role> <ipv4Address> <macAddress>
			var id:int = int(params[0]);
			var role:String = params[1];
			var ipv4Address:String = params[2];
			var macAddress:String  = params[3];
			
			// Get the node and set the role and address properties
			var node:Node = getNode(id);
			node.ipv4Address = ipv4Address;
			node.macAddress = macAddress;
			
			node.role = role;
			
			log("Updated node", node.toString());
			
			return 0;
		}
		
		/**
		 * On time update
		 * 
		 * @parm elapsed
		 */ 
		public function onTimeUpdate(elapsed:uint):void
		{
			
		}
		
		/**
		 * Set duration
		 * 
		 * @param time
		 */ 
		public function setDuration(time:uint):void
		{
			
		}
	}
}