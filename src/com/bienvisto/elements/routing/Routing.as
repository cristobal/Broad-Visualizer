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
			
			this.nodeContainer 			  = nodeContainer;
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
		override public function update(params:Vector.<String>):uint
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
			
			return time;
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
			if (args.length >= 3) {
				for (var i:int = 0, l:int = args.length; i < l; i += 3) {
					// The distance is not currently used, always -1
					entry = new RoutingTableEntry(args[i], args[i + 1], args[i + 2]);
					entries.push(entry);
				}
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
		
		private var cache:Dictionary = new Dictionary();
		
		/**
		 * Resolve table
		 * 
		 * @param node
		 * @param time
		 */ 
		public function resolveTable(node:Node, time:uint):RoutingTable
		{
			var table:RoutingTable;
			
			var key:String = String(node.id) + "-" + String(time);
			if (key in cache) {
				table = RoutingTable(cache[key]);
					
				return table;
			}
			
			table = findTable(node, time);
			
			if (table) {
				var traceback:Boolean;
				var complete:Boolean;
				var paths:Vector.<int>;
				
				var entries:Vector.<RoutingTableEntry> = table.entries;
				var entry:RoutingTableEntry;
				var source:int = node.id;
				
				var count:int      = entries.length;
				var lut:Dictionary = new Dictionary();
				lut[source] = table;
				
				var collection:RoutingCollection;
				for each (var id:int in collections) {
					if (id == source) {
						continue;
					}
					
					collection = collections[id];
					table	   = RoutingTable(collection.findNearest(time));
					lut[id]	   = table;
				}
				
				for (var i:int = 0, l:int = entries.length; i < l; i++) {
					entry = entries[i];
					paths = new Vector.<int>();
					paths.push(source);
					traceback = resolvePaths(source, entry, paths, lut);			
					complete  = true;
					
					for (var j:int = paths.length; j--;) {
						if (paths[j] == -1) {
							complete = false;
							break;
						}
					}
					entry.traceback = traceback;
					entry.complete  = complete;
					entry.paths	    = paths;
					
					
					entries[i] = entry;
				}
				// table.entries = entries;
				
			}
			cache[key] = new RoutingTable(time, node, entries);
			
			return cache[key];
		}
		
		/**
		 * Resolve paths
		 * 
		 * @param source
		 * @param entry
		 * @param paths
		 * @param lut
		 */ 
		private function resolvePaths(source:int, entry:RoutingTableEntry, paths:Vector.<int>, lut:Dictionary):Boolean
		{	
			var traceback:Boolean;
			
			if (entry.distance == 1) {
				paths.push(entry.destination);
				traceback = validPath(source, entry.destination, lut);
			}
			else if (entry.distance == 2) {
				paths.push(entry.next);
				paths.push(entry.destination);
				if (validPath(source, entry.next, lut)) {
					traceback = validPath(source, entry.destination, lut);
				}
			}
			else {
				
				var dest:int = entry.destination;
				var distance:int = entry.distance;
				var same:Boolean = source == dest;
				
				var flag:Boolean
				var isDest:Boolean;
				var table:RoutingTable;
				var entries:Vector.<RoutingTableEntry>;
				var visited:Dictionary = new Dictionary();
				visited[source] = source;
				visited[dest]	= dest;
				while(true) {					
					flag = false;
					
					paths.push(entry.next);
					if (traceback) {
						traceback = validPath(source, entry.next, lut);
					}
					
					source = entry.next;
/*					if (source in visited) {
						break;
					}*/
					visited[source] = source;
					table  = RoutingTable(lut[source]);
					if (table) {
						entries = table.entries;
						for (var i:int = 0, l:int = entries.length; i < l; i++) {
							entry = entries[i];
							isDest = entry.destination == dest;
							if (same && isDest) {
								if (entry.distance > 1) {
									flag = true;
								}
							}
							else if (isDest) {
								flag = true;
							}
							if (flag) {
								break;
							}
						}
					}
					
					if (flag) {
						if (entry.distance == 1) {
							break;
						}
					}
					else {
						break;
					}
				}
				
				
				if (paths.length < distance) {
					while (paths.length < distance) {
						paths.push(-1);
					}
					traceback = false;
				}
				
				paths.push(dest);
				if (traceback) {
					traceback = validPath(source, dest, lut);
				}
				
			}
			
			return traceback;
		}
		
		// private function 
		
		/**
		 * Valid path
		 * 
		 * @param source
		 * @param dest
		 * @param lut
		 */ 
		private function validPath(source:int, dest:int, lut:Dictionary):Boolean
		{
			var flag:Boolean = true;
			
			var table:RoutingTable = RoutingTable(lut[dest]);
			if (table) {
				var entries:Vector.<RoutingTableEntry> = table.entries;
				var entry:RoutingTableEntry;
			
				for (var i:int = 0, l:int = entries.length; i < l; i++) {
					entry = entries[i];
					if (entry.destination == source && entry.distance == 1) {
						flag = true;
						break;
					}
				}
			}
			
			return flag;
		}
		
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

		
	}
}