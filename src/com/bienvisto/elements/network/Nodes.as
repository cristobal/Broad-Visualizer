package com.bienvisto.elements.network
{
	import com.bienvisto.core.ISimulationObject;
	import com.bienvisto.core.parser.TraceSource;
	import com.bienvisto.elements.mobility.IMobilityModel;

	/**
	 * NodeManager.as
	 * 	Manages all the nodes (basic pooling). 
	 * 
	 * @author Cristobal Dabed
	 */ 
	public final class Nodes extends TraceSource implements ISimulationObject
	{
		/**
		 * Constructor
		 */ 
		public function Nodes(mobilityModel:IMobilityModel)
		{
			super("Node Properties", "np");
			this.mobilityModel = mobilityModel;
		}
		
		/**
		 * @private
		 */ 
		private var mobilityModel:IMobilityModel;
		
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
				node.mobilityModel = mobilityModel;
				_nodes.push(node);	
			}
			
			return node;
		}
		
		/**
		 * @override
		 */ 
		override public function update(params:Vector.<String>):void
		{
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
		}
		
		/**
		 * On time update
		 * 
		 * @parm elapsed
		 */ 
		public function onTimeUpdate(elapsed:uint):void
		{
			
		}
	}
}