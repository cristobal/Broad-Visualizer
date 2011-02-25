package com.bienvisto.elements.roles
{
	import com.bienvisto.core.Visualizer;
	import com.bienvisto.core.events.TimedEvent;
	import com.bienvisto.elements.ElementBase;
	import com.bienvisto.elements.Node;
	
	import flash.display.Sprite;
	
	/**
	 * Class responsible of parsing the "node role" block of the trace to
	 * visualize and display the role of a node
	 */ 
	public class Roles extends ElementBase
	{
		
		/**
		 * Constructor
		 */ 
		public function Roles(v:Visualizer, c:Sprite=null)
		{
			super(v, c);
			
			_nodes = new Vector.<Node>;
		}
		
		/**
		 * @override
		 */ 
		public override function get name():String 
		{
			return "Roles";
		}
		
		/**
		 * @override
		 */ 
		public override function get lineType():String
		{
			return "nr";
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
			// TODO: Refactor time use message passing instead faste. 
			//		 And Move this code out afterwards 
			var time:uint = event.milliseconds;
			for each (var node:Node in _nodes) {
				node.time = time;
			}
		}
		
		/**
		 * @override
		 */ 
		protected override function loadNewLine(params:Array):void
		{
			// Format: nr <id> <role> <ipv4address>
			var id:int = params[0];
			var role:String = params[1];
			var address:String = params[2];
			
			// Get the node and set the role and address properties
			var node:Node = visualizer_.nodeManager.findNodeById(id);
			node.address = address;
			node.role = role;
			_nodes.push(node);
		}
		
	}
}