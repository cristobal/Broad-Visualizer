package com.bienvisto.elements.node
{
	import com.bienvisto.core.Visualizer;
	import com.bienvisto.core.events.TimedEvent;
	import com.bienvisto.elements.ElementBase;
	
	import flash.display.Sprite;
	import com.bienvisto.elements.network.Node;
	
	/**
	 * Class responsible of parsing the "node properties" block of the trace to
	 * visualize and display the role of a node
	 */ 
	public class Properties extends ElementBase
	{
		
		/**
		 * Constructor
		 */ 
		public function Properties(v:Visualizer, c:Sprite=null)
		{
			super(v, c);
			
			_nodes = new Vector.<Node>;
		}
		
		/**
		 * @override
		 */ 
		public override function get name():String 
		{
			return "Properties";
		}
		
		/**
		 * @override
		 */ 
		public override function get lineType():String
		{
			return "np";
		}
		
		/**
		 * @private
		 */ 
		private var _nodes:Vector.<Node>;
		
		/**
		 * @readonly nodes
		 */ 
		public function get nodes():Vector.<Node>
		{
			return _nodes.concat();
		}
		
		
		/**
		 * @override
		 */ 
		public override function update(event:TimedEvent):void
		{
			// TODO: Refactor time use message passing instead faster. 
			//		 And Move this code out afterwards 
			var time:uint = event.elapsed;
			for each (var node:Node in _nodes) {
				node.time = time;
			}
		}
		
		/**
		 * @override
		 */ 
		protected override function loadNewLine(params:Array):void
		{
			// Format: nr <id> <role> <ipv4Address> <macAddress>
			var id:int = params[0];
			var role:String = params[1];
			var ipv4Address:String = params[2];
			var macAddress:String  = params[3];
			
			// Get the node and set the role and address properties
			var node:Node = visualizer_.nodeManager.getNode(id);
			node.ipv4Address = ipv4Address;
			node.macAddress = macAddress;
			
			node.role = role;
			_nodes.push(node);
		}
		
	}
}