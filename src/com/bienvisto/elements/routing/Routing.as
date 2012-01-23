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
		 * @private
		 */ 
		private var simpleRoutes:Dictionary = new Dictionary();
		
		/**
		 * @private
		 */ 
		private var simpleRoutesWithNode:Dictionary = new Dictionary();
		
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
		 * find route
		 * 
		 * @param time
		 * @param nodeFrom
		 * @param nodeTo
		 */ 
		public function findCompleteRoute(time:uint, nodeFrom:Node, nodeTo:Node):Vector.<SimpleRoute>
		{
			var routes:Vector.<SimpleRoute>;
			var key:String = [nodeFrom.id, nodeTo.id, time].join("-");
			
			if (!(key in simpleRoutes)) {
				routes = resolveCompleteRoute(time, nodeFrom, nodeTo);
				simpleRoutes[key] = routes;
			}
			else {
				routes = Vector.<SimpleRoute>(simpleRoutes[key]);
			}
			
			return routes;
		}
		
		/**
		 * Resolve route
		 * 
		 * @param time
		 * @param nodeFrom
		 * @param nodeTo
		 */ 
		private function resolveCompleteRoute(time:uint, nodeFrom:Node, nodeTo:Node):Vector.<SimpleRoute>
		{
			var routes:Vector.<SimpleRoute> = new Vector.<SimpleRoute>();
			
			var lut:Dictionary = getLUT(time);
			
			
			var from:int = nodeFrom.id;
			var to:int   = nodeTo.id;
			
			var table:RoutingTable = RoutingTable(lut[from]);
			//trace("resolveCompleteRoute", time, from, table, RoutingCollection(collections[from]).findNearest(time));
			if (table) {
				var entries:Vector.<RoutingTableEntry> = table.entries;
				var entry:RoutingTableEntry;
				var search:Boolean = false;
				for (var i:int = 0, l:int = entries.length; i < l; i++) {
					entry = entries[i];
					if (entry.destination == to) {	
						search = true;
						break;
					}
				}
				
				if (search) {
					var route:SimpleRoute;
					var broken:Boolean;
					var visited:Dictionary = new Dictionary();
					while (true) {
						if (entry.destination == to && entry.distance == 1) {
							broken = (validPath(from, entry.destination, lut) ? false : true);
							route  = new SimpleRoute(from, entry.destination, -1, 1, broken); 
							routes.push(route);
							break;
						}
						visited[from] = true;
						
						broken = (validPath(from, entry.next, lut) ? false : true);
						route  = new SimpleRoute(from, entry.next, -1, 1, broken);
						routes.push(route);
						
						from = entry.next;
						if (from in visited) {
							break; // already been here…
						}
						
						table = lut[from];
						entries = table.entries;
						search  = false;
						for (i = 0, l = entries.length; i < l; i++) {
							entry = entries[i];
							if (entry.destination == to) {	
								search = true;
								break;
							}
						}
						
						if (!search) {
							// found no route exit loop
							break;
						}

					}
				}
			}
			
			
			return routes;
		}
		
		/**
		 * Find simple routes
		 * 
		 * @param time
		 */ 
		public function findSimpleRoutes(time:uint):Vector.<SimpleRoute>
		{
			var routes:Vector.<SimpleRoute>;
			var key:String = String(time);
			
			if (!(key in simpleRoutes)) {
				routes = resolveSimpleRoutes(time);
				simpleRoutes[key] = routes;
			}
			else {
				routes = Vector.<SimpleRoute>(simpleRoutes[key]);
			}
			
			
			return routes;
		}
		
		/**
		 * Resolve global routes
		 * 
		 * @param time
		 */ 
		private function resolveSimpleRoutes(time:uint):Vector.<SimpleRoute>
		{
			var routes:Vector.<SimpleRoute> = new Vector.<SimpleRoute>();
			
			var node:Node, nodes:Vector.<Node> = nodeContainer.nodes;
			
			var table:RoutingTable;
			var entry:RoutingTableEntry, entries:Vector.<RoutingTableEntry>;
			
			
			var visited:Dictionary = new Dictionary();
			var path:String, pathRe:String;
			var route:SimpleRoute;
			var from:int, dest:int;
			
			var lut:Dictionary = new Dictionary();
			var collection:RoutingCollection;
			for each (var id:int in collections) {
				collection  = RoutingCollection(collections[id]);
				table	   = RoutingTable(collection.findNearest(time));
				lut[id]	   = table;
			}
			
			var broken:Boolean;
			for (var i:int = 0, l:int = nodes.length; i < l; i++) {
				node  = nodes[i];
				table = findTable(node, time);
				if (!table) {
					continue;
				}
				
				from    = node.id;
				entries = table.entries;
				for (var j:int = 0, n:int = entries.length; j < n; j++) {
					entry = entries[j];
					
					if (entry.distance == 1) {
						dest   = entry.destination;
						path   = [from, entry.destination].join("-");	
						pathRe = [entry.destination, from].join("-");	
					}
					else {
						dest   = entry.next;
						path   = [from, entry.next].join("-");	
						pathRe = [entry.next, from].join("-");	
					}
					
					
					if (!(path in visited) && !(pathRe in visited)) {
						
						visited[path] = true;
						visited[pathRe] = true;
						
						broken = (validPath(from, dest, lut) ? false : true);		
						route  = new SimpleRoute(from, dest, -1, 1, broken);
						
						routes.push(route);
					}
				}
			}
			
			return routes;
		}
		
		/**
		 * Find simple routes with node
		 *  
		 * @param time
		 * @param node
		 */ 
		public function findSimpleRoutesWithNode(time:uint, node:Node):Vector.<SimpleRoute>
		{
			var routes:Vector.<SimpleRoute>;
			var key:String = [node.id, time].join("-");
			
			if (!(key in simpleRoutesWithNode)) {
				routes = resolveSimpleRoutesWithNode(time, node);
				simpleRoutes[key] = routes;
			}
			else {
				routes = Vector.<SimpleRoute>(simpleRoutesWithNode[key]);
			}
			
			
			return routes;
		}
		
		/**
		 * Resolve simple routes with node
		 * 
		 * @param time
		 * @param node 
		 */ 
		private function resolveSimpleRoutesWithNode(time:uint, node:Node):Vector.<SimpleRoute>
		{
			var routes:Vector.<SimpleRoute> = findSimpleRoutes(time).concat();
			
			var table:RoutingTable;
			var lut:Dictionary = new Dictionary();
			var collection:RoutingCollection;
			for each (var id:int in collections) {
				collection  = RoutingCollection(collections[id]);
				table	   = RoutingTable(collection.findNearest(time));
				lut[id]	   = table;
			}
			
			
			table   = RoutingTable(lut[id]);
			if (table) {
				var entries:Vector.<RoutingTableEntry> = table.entries;
				var entry:RoutingTableEntry;
				
				var path:String, pathRe:String, pathRoute:String;
				var route:SimpleRoute;
				var from:int = node.id, dest:int;
				var broken:Boolean;
				for (var i:int = 0, l:int = entries.length; i < l; i++) {
					entry = entries[i];
					broken = (validPath(from, entry.destination, lut) ? false : true);
					
					
					if (entry.distance == 1) {
						path   = [from, entry.destination].join("-");	
						pathRe = [entry.destination, from].join("-");
					}
					else {
						path   = [from, entry.next].join("-");	
						pathRe = [entry.next, from].join("-");
					}
					
					for (var j:int = routes.length; j--;) {
						route = routes[j];
						pathRoute = [route.from, route.destination].join("-");	
						if (pathRoute == path || pathRoute == pathRe) {
							routes.splice(j, 1);
							// break;
						}
					}
					
					route = new SimpleRoute(from, entry.destination, entry.next, entry.distance, broken);
					routes.push(route);
				}
			}
			
			
			return routes;
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
		
		
		private function getLUT(time:uint):Dictionary
		{
			var lut:Dictionary = new Dictionary();
			var table:RoutingTable;
			
			var collection:RoutingCollection;
			var id:int;
			var node:Node;
			var nodes:Vector.<Node> = nodeContainer.nodes;
			for (var i:int = 0, l:int = nodes.length; i < l; i++) {
				node = nodes[i];
				id   = node.id;
				collection = RoutingCollection(collections[id]);
				table	   = RoutingTable(collection.findNearest(time));
				lut[id]	   = table;
			}
			
			return lut;
		}
		
	}
}