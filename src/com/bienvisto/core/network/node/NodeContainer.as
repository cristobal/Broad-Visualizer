package com.bienvisto.core.network.node
{
	import com.bienvisto.core.ISimulationObject;
	import com.bienvisto.core.parser.TraceSource;
	
	import flash.events.Event;
	
	/**
	 * @Event
	 * 	The change event will be dispatched when a new node has been added to the container.
	 */ 
	[Event(name="change", type="flash.events.Event")]
	
	/**
	 * NodeContainer.as
	 * 	Manages all the nodes (basic pooling) for a simulation. 
	 *  All other objects have a reference to this node container to get a node reference by an id.
	 *  
	 *  The node container also parses node properties for a node if any given.
	 * 
	 * @author Cristobal Dabed
	 */ 
	public final class NodeContainer extends TraceSource implements ISimulationObject
	{
		
		//--------------------------------------------------------------------------
		//
		//  Constants
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @public
		 * 	This event will be dispatched when node properties for a node has been read.
		 */
		[Event(name="propertyChange", type="flash.events.Event")]
		public static const PROPERTY_CHANGE:String = "propertyChange";
		
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */ 
		public function NodeContainer()
		{
			super("Node Properties", "np");
		}		
		
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  nodes
		//---------------------------------- 
		
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
		
		//----------------------------------
		//  size
		//---------------------------------- 
		
		/**
		 * @readonly size
		 */ 
		public function get size():uint 
		{
			return _nodes.length;
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
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
				dispatchEvent(new Event(Event.CHANGE));
			}
			
			return node;
		}
		
		/**
		 * @override
		 */ 
		override public function update(params:Vector.<String>):uint
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
			
			dispatchEvent(new Event(PROPERTY_CHANGE));
			return 0;
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  ISimulation Object Implementation
		//
		//--------------------------------------------------------------------------
		
		/**
		 * On time update
		 * 
		 * @param elapsed
		 */ 
		public function onTimeUpdate(elapsed:uint):void
		{
			
		}
		
		/**
		 * Set duration
		 * 
		 * @param duration
		 */
		public function setDuration(duration:uint):void
		{
			
		}
		
		/**
		 * Reset
		 */ 
		public function reset():void
		{
			_nodes = new Vector.<Node>(); 
		}
		
	}
}