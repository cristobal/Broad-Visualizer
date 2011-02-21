package com.bienvisto.elements.roles
{
	import com.bienvisto.core.Visualizer;
	import com.bienvisto.core.events.TimedEvent;
	import com.bienvisto.elements.ElementBase;
	
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
			setup();
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
		private var nodes:Vector.<NodeRole>;
		
		/**
		 * Setup
		 */ 
		private function setup():void
		{
			nodes = new Vector.<NodeRole>();
		}
		
		/**
		 * @override
		 */ 
		public override function update(event:TimedEvent):void
		{
			// nothing todo here 
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
			var node:NodeRole = new NodeRole(id, role, address);
			
			// push the nodeRole
			nodes.push(node);
		}
		
		/**
		 * Find role by id
		 * 
		 * @param id The id of the node to lookup
		 * @return	Returns the nodeRole if found otherwise null
		 */ 
		public function findRoleById(id:int):NodeRole
		{
			var node:NodeRole = null;
			var flag:Boolean = false;
			
			for each(node in nodes) {
				if (node.id == id) {
					flag = true;
					break;
				}
			}
				
			if (!flag) {
				node = null;	
			}
			
			return node;
		}
	}
}