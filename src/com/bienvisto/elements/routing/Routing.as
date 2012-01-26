package com.bienvisto.elements.routing
{
	import com.bienvisto.core.ISimulationObject;
	import com.bienvisto.core.parser.TraceSource;
	import com.bienvisto.elements.network.graph.AdjacencyMatrix;
	import com.bienvisto.elements.network.graph.Graph;
	import com.bienvisto.elements.network.node.Node;
	import com.bienvisto.elements.network.node.NodeContainer;
	
	import flash.utils.Dictionary;
	
	import mx.utils.ObjectProxy;
	
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
		 * @private
		 */ 
		private var adjacencyMatrixes:Dictionary = new Dictionary();
		
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
		public function findCompleteRoute(time:uint, nodeFrom:Node, nodeTo:Node):SimpleRoute
		{
			var route:SimpleRoute
			var key:String = [nodeFrom.id, nodeTo.id, time].join("-");
			
			if (!(key in simpleRoutes)) {
				route = resolveCompleteRoute(time, nodeFrom, nodeTo);
				simpleRoutes[key] = route;
			}
			else {
				route = SimpleRoute(simpleRoutes[key]);
			}
			
			return route;
		}
		
		/**
		 * Resolve route
		 * 
		 * @param time
		 * @param nodeFrom
		 * @param nodeTo
		 */ 
		private function resolveCompleteRoute(time:uint, nodeFrom:Node, nodeTo:Node):SimpleRoute
		{
			var route:SimpleRoute;
			var lut:Dictionary = getLUT(time);
			
			var from:int = nodeFrom.id;
			var to:int   = nodeTo.id;
			
			var table:RoutingTable = RoutingTable(lut[from]);
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
					
					route = new SimpleRoute(from, to, entry.next, entry.distance);
					route.paths = resolvePaths(from, entry, lut);
					
					route.complete = true;
					if (route.distance > 2) {
						for each (var path:int in route.paths) {
							if (path < 0) {
								route.complete = false;
								break;
							}
						}
					}
					
					
					// route.traceback = tracebackPath(from, entry, lut);
				}
				
			}
			
			return route;
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
		public function resolveSimpleRoutes(time:uint):Vector.<SimpleRoute>
		{
			var routes:Vector.<SimpleRoute> = new Vector.<SimpleRoute>();
			
			var node:Node, nodes:Vector.<Node> = nodeContainer.nodes;
			
			var table:RoutingTable;
			var entry:RoutingTableEntry, entries:Vector.<RoutingTableEntry>;
			
			
			var visited:Dictionary = new Dictionary();
			var path:String, pathRe:String;
			var route:SimpleRoute;
			var from:int, dest:int;
			
			var lut:Dictionary = getLUT(time);
			
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
							
						route  = new SimpleRoute(from, dest, -1, 1);
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
			var lut:Dictionary = getLUT(time);
			
			var id:int      		 = node.id;
			var table:RoutingTable   = RoutingTable(lut[id]);
			if (table) {
				var entries:Vector.<RoutingTableEntry> = table.entries;
				var entry:RoutingTableEntry;
				
				var path:String, pathRe:String, pathRoute:String;
				var route:SimpleRoute;
				var from:int = node.id, dest:int;
				for (var i:int = 0, l:int = entries.length; i < l; i++) {
					entry = entries[i];
					
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
					
					route = new SimpleRoute(from, entry.destination, entry.next, entry.distance);
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
		 * Resolve table routes
		 * 
		 * @param node
		 * @param time
		 */ 
		public function resolveTableRoutes(node:Node, time:uint):Vector.<SimpleRoute>
		{
			var routes:Vector.<SimpleRoute>;
			var key:String = [node.id, time].join("-");
			
			if (key in cache) {
				routes = Vector.<SimpleRoute>(cache[key]);
				return routes;
			}
			
			
			var lut:Dictionary = getLUT(time);
			var from:int         = node.id;
			var table:RoutingTable = RoutingTable(lut[from]);
			if (table) {
				routes = new Vector.<SimpleRoute>();
				
				var entries:Vector.<RoutingTableEntry> = table.entries;
				var entry:RoutingTableEntry;
				var route:SimpleRoute;
				var dest:int;
				var search:Boolean;
				var paths:Vector.<int>;
				for (var i:int = 0, l:int = entries.length; i < l; i++) {
					entry = entries[i];
					dest  = entry.destination;
					
					route = new SimpleRoute(from, dest, entry.next, entry.distance);
					route.paths     = resolvePaths(from, entry, lut);
					route.traceback = tracebackPath(from, entry, lut);
					
					route.complete = true;
					if (route.distance > 2) {
						for each (var path:int in route.paths) {
							if (path < 0) {
								route.complete = false;
								break;
							}
						}
					}
					
					routes.push(route);
				}
				
				
				cache[key] = routes;
			}
			
			return routes;
		}
		
		/**
		 * Resolve paths
		 * 
		 * @param from
		 * @param entry
		 * @param lut
		 */ 
		private function resolvePaths(from:int, entry:RoutingTableEntry, lut:Dictionary):Vector.<int>
		{
			var paths:Vector.<int> = new Vector.<int>();
			var to:int = entry.destination;
			paths.push(from);
			
			if (entry.distance == 2) {
				paths.push(entry.next);
			}
			else if (entry.distance > 2) {
				var table:RoutingTable;
				var entry:RoutingTableEntry, entries:Vector.<RoutingTableEntry>;
				var search:Boolean;
				var visited:Dictionary = new Dictionary();
				var next:int;
				while (true) {
					if (entry.destination == to && entry.distance == 1) {
						break;
					}
					visited[from] = true;
					
					from = entry.next;
					if (from in visited) {
						paths.push(-1);
						break; // already been here…
					}
					paths.push(from);
					
					table = lut[from];
					entries = table.entries;
					search  = false;
					for (var i:int = 0, l:int = entries.length; i < l; i++) {
						entry = entries[i];
						if (entry.destination == to) {	
							search = true;
							break;
						}
					}
					
					if (!search) {
						// found no route exit loop
						paths.push(-1);
						break;
					}
				}
			}
			
			paths.push(to);
			
			return paths;
		}
		
		/**
		 * Traceback path
		 * 
		 * @param from
		 * @param entry
		 * @param lut
		 */
		private function tracebackPath(from:int, entry:RoutingTableEntry, lut:Dictionary):Boolean
		{
			var traceback:Boolean = false;
			
			var to:int = entry.destination;
			var table:RoutingTable  = RoutingTable(lut[to]);
			if (table) {
				var entries:Vector.<RoutingTableEntry> = table.entries;
				var entry:RoutingTableEntry;
				var search:Boolean = false;
				for (var i:int = 0, l:int = entries.length; i < l; i++) {
					entry = entries[i];
					if (entry.destination == from) {
						search = true;
						break;
					}
				}
				
				if (search) {
					var paths:Vector.<int> = resolvePaths(to, entry, lut);
					traceback = true;
					for each (var path:int in paths) {
						if (path < 0) {
							traceback = false;
							break;
						}
					}
				}
			}
			
			
			
			return traceback;
		}
			
		/**
		 * Get adjacency matrix
		 */ 
		public function getAdjacencyMatrix(node:Node, time:uint):AdjacencyMatrix
		{
			var adjacencyMatrix:AdjacencyMatrix;
			var key:String = [node.id, time].join("-");
			
			if (!(key in adjacencyMatrixes)) {
				adjacencyMatrix        = resolveAdjacencyMatrix(node, time);
				adjacencyMatrixes[key] = adjacencyMatrix;
			}
			else {
				adjacencyMatrix = AdjacencyMatrix(adjacencyMatrixes[key]);
			}
			
			
			return adjacencyMatrix;
		}
		
		
		/**
		 * Resolve adjacency matrix
		 * 
		 * @param node
		 * @param time
		 */ 
		private function resolveAdjacencyMatrix(node:Node, time:uint):AdjacencyMatrix
		{
			var adjacencyMatrix:AdjacencyMatrix;
			
			var table:RoutingTable = findTable(node, time);
			if (table) {
				
				var graph:Graph = new Graph();
				var entries:Vector.<RoutingTableEntry> = table.entries;
				var entry:RoutingTableEntry;
				var from:int = node.id;
				var next:int, to:int; 
				var  hops:int;
				for (var i:int = 0, l:int = entries.length; i < l; i++) {
					entry = entries[i];
					hops  = entry.distance;
					next  = entry.next;
					to    = entry.destination;
					if (hops == 1) {
						// 1 hop, single edge
						graph.addEdge(from, to);
					}
					else if (hops == 2) {
						// 2 hops gives us
						// Single edge to the next
						// And single edge from next to destination
						graph.addEdge(from, next);
						graph.addEdge(next, to);
					}
					else if (hops > 2){
						// 3 or more hops single edge to next
						graph.addEdge(from, next); 
					}
				}
				
				adjacencyMatrix = graph.getAdjacencyMatrix();

			}
			
			return adjacencyMatrix;
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
		
		/**
		 * @private
		 */ 
		private var lastLUTTime:Number = -1;
		
		/**
		 * @private
		 */ 
		private var lut:Dictionary;
		
		/**
		 * Get lut
		 * 
		 * @param time
		 */ 
		private function getLUT(time:uint):Dictionary
		{
			
			if (lastLUTTime != time) {
				lastLUTTime = time;	
				lut = null;
			}
			
			if (!lut) {
				lut = new Dictionary();
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
			}
			
			return lut;
		}
		
	}
}