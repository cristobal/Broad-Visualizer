package com.bienvisto.elements.routing
{
	import com.bienvisto.core.ISimulationObject;
	import com.bienvisto.core.parser.TraceSource;
	import com.bienvisto.elements.network.Node;
	import com.bienvisto.elements.network.NodeContainer;
	
	import flash.utils.Dictionary;
	
	public final class Routing extends TraceSource implements ISimulationObject
	{
		public function Routing(nodeContainer:NodeContainer)
		{
			super("Routing", "rc");
			
			this.nodeContainer = nodeContainer;
		}
		
		/**
		 * @private
		 */ 
		private var nodeContainer:NodeContainer;
		
		/**
		 * @private
		 */ 
		private var collections:Dictionary = new Dictionary();
		
		/**
		 * Update
		 * 
		 * @params 
		 */ 
		override public function update(params:Vector.<String>):void
		{

			// Format: rc <node_id> <node_id2> <node_id3> …
			var id:int = int(params[0]);
			var time:uint = uint(params[1]);
			var entries:Vector.<RoutingTableEntry> = parseEntries(params[2]);
			
			var node:Node 		   = nodeContainer.getNode(id);
			var table:RoutingTable = new RoutingTable(time, node, entries);
			var collection:RoutingCollection;
			if (!(id in collections)) {
				collection = new RoutingCollection();
				collections[id] = collection;
			}
			else {
				collection = RoutingCollection(collections[id]);
			}
			//trace("id", id, "new table on time", time, "entries", entries.length);			
			collection.add(table);
		}
		
		/**
		 * Parse entries
		 * 
		 * @param table
		 */ 
		private function parseEntries(table:String):Vector.<RoutingTableEntry>
		{
			var entries:Vector.<RoutingTableEntry> = new Vector.<RoutingTableEntry>();
			var entry:RoutingTableEntry;
			var args:Array = table.split(",");
			
			for (var i:int = 0, l:int = args.length; i < l; i += 3) {
				// The distance is not currently used, always -1
				entry = new RoutingTableEntry(args[i], args[i+1], args[i + 2]);
				entries.push(entry);
			}
			
			return entries;
		}
		
	   /**
		* Find table
		* 
		* @param node
		* @param time
		*/
		public function findTable(node:Node, time:uint):RoutingTable
		{
			var table:RoutingTable;
			var id:int = node.id;
			var collection:RoutingCollection 
			
			if (id in collections) {
				collection = RoutingCollection(collections[id]);
				table 	   = RoutingTable(collection.findNearest(time));
			}
			
			return table;
		}
		
		public function onTimeUpdate(elapsed:uint):void
		{
			
		}
		
	}
}