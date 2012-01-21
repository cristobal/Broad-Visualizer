package com.bienvisto.elements.routing
{
	import com.bienvisto.core.ISimulationObject;
	import com.bienvisto.core.parser.TraceSource;
	import com.bienvisto.elements.network.Node;
	import com.bienvisto.elements.network.NodeContainer;
	
	import flash.utils.Dictionary;
	
	/**
	 * Routing.as
	 * 
	 * @author Miguel Santirso
	 * @author Cristobal Dabed
	 */ 
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
		private var cache:Dictionary = new Dictionary();
		
		/**
		 * @private
		 */ 
		private var collections:Dictionary = new Dictionary();
		
		/**
		 * @private
		 */ 
		private var statsCollections:Dictionary = new Dictionary();
		
		/**
		 * @private
		 */ 
		private var statsItems:Dictionary = new Dictionary();
		
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
			var entries:Vector.<RoutingTableEntry> = parseEntries(id, time, params[2]);
			
			var node:Node 		   = nodeContainer.getNode(id);
			var table:RoutingTable = new RoutingTable(time, node, entries);
			var collection:RoutingCollection = getCollection(id);	
			collection.add(table);
			
			return time;
		}
		
		/**
		 * Get collection
		 * 
		 * @param id
		 */ 
		private function getCollection(id:int):RoutingCollection
		{
			var collection:RoutingCollection;
			if (!(id in collections)) {
				collection = new RoutingCollection();	
				collections[id] = collection;
			}
			else {
				collection = RoutingCollection(collections[id]);
			}
			
			return collection;
		}
		
		/**
		 * Get stats collection
		 * 
		 * @param id
		 */ 
		private function getStatsCollection(id:int):RoutingStatsCollection
		{
			var statsCollection:RoutingStatsCollection;
			
			if (!(id in statsCollections)) {
				statsCollection = new RoutingStatsCollection();	
				statsCollections[id] = statsCollection;
			}
			else {
				statsCollection = RoutingStatsCollection(statsCollections[id]);
			}
			
			return statsCollection;
		}
		
		/**
		 * Get stats item
		 * 
		 * @param id
		 */ 
		private function getStatsItem(id:int):Object
		{
			var item:Object;
			if (!(id in statsItems)) {
				item = {rts: false, rtsTotal: 0, rtsAvgTotal: 0};
				statsItems[id] = item;
			}
			else {
				item = statsItems[id];
			}
			
			return item;
		}
		
		/**
		 * Parse entries
		 * 
		 * @param id
		 * @param table
		 */ 
		private function parseEntries(id:int, time:uint, table:String):Vector.<RoutingTableEntry>
		{
			var item:Object = getStatsItem(id);
			var rts:Boolean    = false;
			var rtsAvg:Boolean = false;
			
			var entries:Vector.<RoutingTableEntry> = new Vector.<RoutingTableEntry>();
			var entry:RoutingTableEntry;
			var args:Array = table.split(",");
			if (args.length >= 3) {
				for (var i:int = 0, l:int = args.length; i < l; i += 3) {
					entry = new RoutingTableEntry(args[i], args[i + 1], args[i + 2]);
					if (entry.destination == id) {
						rts = true;
						continue; // drop destinations to self
					}
					
					if (entry.distance > 2) {
						rtsAvg = true;
					}
					
					entries.push(entry);
				}
			}
			
			// Add new stats item 
			if (rts && !item.rts) {
				item.rts = true; 
				item.rtsTotal++; // augment
				if (rtsAvg) {
					item.rtsAvgTotal++;
				}
				
				var statsCollection:RoutingStatsCollection = getStatsCollection(id);
				var statsItem:RoutingStatsItem = new RoutingStatsItem(time, item.rtsTotal, item.rtsAvgTotal);
				statsCollection.add(statsItem);
			}
			// reset
			else if (!rts && item.rts) {
				item.rts = false;
			}
			
			return entries;
		}
		
		/**
		 * Find stats item
		 * 
		 * @param node
		 * @param time
		 */ 
		public function findStatsItem(node:Node, time:uint):RoutingStatsItem
		{
			var collection:RoutingStatsCollection = getStatsCollection(node.id);
			var itemStats:RoutingStatsItem 		  = RoutingStatsItem(collection.findNearest(time));
			
			return itemStats;
		}
		
	   /**
		* Find table
		* 
		* @param node
		* @param time
		*/
		public function findTable(node:Node, time:uint):RoutingTable
		{
			var collection:RoutingCollection = getCollection(node.id);
			var table:RoutingTable 			 = RoutingTable(collection.findNearest(time));
			
			return table;
		}
		
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