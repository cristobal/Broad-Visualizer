package com.bienvisto.elements.routing
{
	import com.bienvisto.core.ISimulationObject;
	import com.bienvisto.core.aggregate.AggregateCollection;
	import com.bienvisto.core.parser.TraceSource;
	import com.bienvisto.elements.network.graph.AdjacencyMatrix;
	import com.bienvisto.elements.network.graph.Edge;
	import com.bienvisto.elements.network.graph.Graph;
	import com.bienvisto.elements.network.node.Node;
	import com.bienvisto.elements.network.node.NodeContainer;
	import com.bienvisto.util.fnv;
	
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	/**
	 * @Event
	 * 	The init event will be dispatched when the first routing change has been parsed.
	 */
	[Event(name="init", type="flash.events.Event")]
	
	/**
	 * Routing.as
	 * 	Class responsible of parsing "routing changes" from the trace source.
	 * 
	 * @author Miguel Santirso
	 * @author Cristobal Dabed
	 */ 
	public final class Routing extends TraceSource implements ISimulationObject
	{
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
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
		private var tableRoutes:Dictionary = new Dictionary();
		
		/**
		 * @private
		 */ 
		private var collections:Dictionary = new Dictionary();
		
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
		private var routesWithNode:Dictionary = new Dictionary();
		
		
		/**
		 * @private
		 */ 
		private var completeRoutes:Dictionary = new Dictionary();
		
		
		/**
		 * @private
		 */ 
		private var graphs:Dictionary = new Dictionary();
		
		/**
		 * @private
		 */ 
		private var init:Boolean = false;
		
		/**
		 * @private
		 */ 
		private var complete:Boolean = false;
		
		
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
			init     = false;
			complete = false;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Parsing Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @override 
		 */ 
		override public function onComplete():void
		{
			complete = true;
		}
		
		/**
		 * @override
		 */ 
		override public function update(params:Vector.<String>):uint
		{
			
			// Format: rc <node_id> <node_id2> <node_id3> …
			var id:int = int(params[0]);
			var time:uint = uint(params[1]);
			var entries:Vector.<RoutingTableEntry> = parseEntries(id, time, params[2]);			
			var node:Node  = nodeContainer.getNode(id);
			
			if (!(id in collections)) {
				collections[id] = new AggregateCollection();
			}
			
			AggregateCollection(collections[id]).add(
				new RoutingTable(time, node, entries)
			);
			
			if (!init) {
				dispatchEvent(new Event(Event.INIT));
				init = true;
			}
			
			return time;
		}
		
		/**
		 * Parse entries
		 * 
		 * @param id
		 * @param table
		 */ 
		private function parseEntries(id:int, time:uint, table:String):Vector.<RoutingTableEntry>
		{
			var entries:Vector.<RoutingTableEntry> = new Vector.<RoutingTableEntry>();
			var entry:RoutingTableEntry;
			var args:Array = table.split(",");
			if (args.length >= 3) {
				for (var i:int = 0, l:int = args.length; i < l; i += 3) {
					entry = new RoutingTableEntry(args[i], args[i + 1], args[i + 2]);
					
					// For some reason OLSR will often contain routes to itself
					// Often trough another hop but also and in some cases a 1-hop edge
					// Seems to often incurr in most cases when there are more than 3-hops links.
					if (entry.destination == id) {
						continue; // drop destinations to self
					}
					
					entries.push(entry);
				}
			}
			
			return entries;
		}
		
		
		/**
		 * @private
		 */ 
		private var lastLUTTime:Number = -1;
		
		/**
		 * @private
		 */ 
		private var _tables:Dictionary;
		
		/**
		 * Get lut
		 * 
		 * @param time
		 */ 
		private function getTables(time:uint):Dictionary
		{
			
			/*			if (lastLUTTime != time) {
			lastLUTTime = time;	
			lut = null;
			}
			
			if (!lut) {*/
			_tables = new Dictionary();
			var table:RoutingTable;
			
			var collection:AggregateCollection;
			var id:int;
			var node:Node;
			var nodes:Vector.<Node> = nodeContainer.nodes;
			for (var i:int = 0, l:int = nodes.length; i < l; i++) {
				node = nodes[i];
				id   = node.id;
				collection = AggregateCollection(collections[id]);
				table	   = RoutingTable(collection.findNearest(time));
				_tables[id]	   = table;
			}
			//}
			
			return _tables;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Routes
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Find simple routes
		 * 
		 * @param time
		 */ 
		public function findSimpleRoutes(time:uint):Vector.<SimpleRoute>
		{
/*			if (time in simpleRoutes) {
				return Vector.<SimpleRoute>(simpleRoutes[time]);
			}
			
			var routes:Vector.<SimpleRoute> = resolveSimpleRoutes(time);
			simpleRoutes[time] = routes;*/
			
			return resolveSimpleRoutes(time);;
		}
		
		/**
		 * Resolve global routes
		 * 
		 * @param time
		 */ 
		public function resolveSimpleRoutes(time:uint):Vector.<SimpleRoute>
		{
			var graph:Graph = getGlobalGraph(time);
			var key:String  = graph.oid;
			
			// if we have the same graph the routes will not change
			if (key in simpleRoutes) {
				return Vector.<SimpleRoute>(simpleRoutes[key]);
			}
			
			
			var routes:Vector.<SimpleRoute> = new Vector.<SimpleRoute>();
			if (graph && graph.getAdjacencyMatrix()) {
				var adjacencyMatrix:AdjacencyMatrix = graph.getAdjacencyMatrix();
				var vertices:Vector.<int>           = adjacencyMatrix.vertices;
				var u:int, v:int;
				var uv:String, vu:String;
				
				var visited:Dictionary = new Dictionary();
				for (var y:int = 0, l:int = vertices.length; y < l; y++) {
					u = vertices[y];
					for (var x:int = 0; x < l; x++) {
						v = vertices[x];
		
						uv = String(u) + "-" + String(v);
						vu = String(v) + "-" + String(u);
						if (adjacencyMatrix.edgeExists(u, v) && !(uv in visited) && !(vu in visited)) {
							routes.push(
								new SimpleRoute(u, v, -1, 1)
							);
							visited[uv] = true;
							visited[vu] = true;
						}
					}
				}
			}
			simpleRoutes[key] = routes;
			
			// For a 6minutes simulation we got ~=
			//	 total: 1195  lookup: 613
			// meaning that storing a reference with a uuid key  provided by the graph reduces 
			// the amount of objects created around ~40-50.
			
			
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
/*			var key:String = String(node.id) + "-" + String(time);
			if (key in routesWithNode) {
				return Vector.<SimpleRoute>(routesWithNode[key]);
			}
			
			var routes:Vector.<SimpleRoute> = resolveSimpleRoutesWithNode(time, node);
			if (routes) {
				routesWithNode[key]  = routes;
			}
			
			return routes;*/
			
			return resolveSimpleRoutesWithNode(time, node);
		}
		
		/**
		 * Resolve simple routes with node
		 * 
		 * @param time
		 * @param node 
		 */ 
		private function resolveSimpleRoutesWithNode(time:uint, node:Node):Vector.<SimpleRoute>
		{
			var from:int      		 = node.id;
			var tables:Dictionary    = getTables(time);
			
			var routes:Vector.<SimpleRoute> = findSimpleRoutes(time).concat();	
			var table:RoutingTable          = RoutingTable(tables[from]);
			
			if (table) {
				
				var entries:Vector.<RoutingTableEntry> = table.entries;
				var entry:RoutingTableEntry;
				
				var u:int, v:int;
				var uv:String, vu:String;
				var path:String;
				var route:SimpleRoute;
				for (var i:int = 0, l:int = entries.length; i < l; i++) {
					entry = entries[i];
					u  = from;
					v  = entry.distance > 1 ? entry.next : entry.destination;
					
					uv = String(u) + "-" + String(v);
					vu = String(v) + "-" + String(u);
					
					for (var j:int = routes.length; j--;) {
						route = routes[j];
						path = String(route.from) + "-" + String(route.destination); 
						if (path == uv || path == vu) {
							routes.splice(j, 1);
							// break;
						}
					}
					
					routes.push( 
						new SimpleRoute(from, entry.destination, entry.next, entry.distance)
					);
				}
			}
			// caching by a sequence key at this point does no optimizations…
			
			return routes;
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
/*			var key:String = String(nodeFrom.id) + "-" + String(nodeTo.id) + "-" + String(time);
			if (key in completeRoutes) {
				return SimpleRoute(completeRoutes[key]);
			}
			
			var	route:SimpleRoute = resolveCompleteRoute(time, nodeFrom, nodeTo, key);
			if (route) {
				completeRoutes[key] = route;
			}
			
			return route;*/
			
			return resolveCompleteRoute(time, nodeFrom, nodeTo);
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
			var from:int = nodeFrom.id;
			var to:int   = nodeTo.id;
				
			var lut:Dictionary = getTables(time);
			var table:RoutingTable = RoutingTable(lut[from]);
			
			var route:SimpleRoute;
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
					route       = new SimpleRoute(from, to, entry.next, entry.distance);
					route.paths = resolvePaths(from, entry, lut);
					
					route.complete = true;
					if (route.distance > 2) {
						var paths:Vector.<int> = route.paths;
						for (i = 0, l = paths.length; i < l; i++) {
							if (paths[i] < 0) {
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
		 * Find table
		 * 
		 * @param node
		 * @param time
		 */
		public function findTable(node:Node, time:uint):RoutingTable
		{
			var id:int = node.id;
			if (!(id in collections)) {
				return null;
			}
			
			return RoutingTable(AggregateCollection(collections[id]).findNearest(time));
		}
		
		/**
		 * Resolve table routes
		 * 
		 * @param node
		 * @param time
		 */ 
		public function resolveTableRoutes(node:Node, time:uint):Vector.<SimpleRoute>
		{
			
/*			var key:String = String(node.id) + "-" + String(time);
			if (key in tableRoutes) {
				return Vector.<SimpleRoute>(tableRoutes[key]);
			}
			var routes:Vector.<SimpleRoute> = resolveRoutes(node, time);
			if (routes) {
				tableRoutes[key] = routes;
			}
			
			return routes;*/
			
			return resolveRoutes(node, time);
		}
		
		/**
		 * Resolve table routes
		 * 
		 * @param node
		 * @param time
		 */ 
		private function resolveRoutes(node:Node, time:uint):Vector.<SimpleRoute>
		{
			
			var lut:Dictionary     = getTables(time);
			var from:int           = node.id;
			var table:RoutingTable = RoutingTable(lut[from]);
			if (!table) {
				return null;
			}
			
			var routes:Vector.<SimpleRoute> = new Vector.<SimpleRoute>();
			var entries:Vector.<RoutingTableEntry> = table.entries;
			var entry:RoutingTableEntry;
			var route:SimpleRoute;
			var dest:int;
			var search:Boolean;
			var paths:Vector.<int>;
			for (var i:int = 0, l:int = entries.length; i < l; i++) {
				entry = entries[i];
				dest  = entry.destination;
					
				route 			= new SimpleRoute(from, dest, entry.next, entry.distance);
				route.paths     = resolvePaths(from, entry, lut);
				route.traceback = tracebackPath(from, entry, lut);
					
				route.complete = true;
				if (route.distance > 2) {
					paths = route.paths;
					for (var j:int = 0, k:int = paths.length; j < k; j++) {
						if (paths[j] < 0) {
							route.complete = false;
							break;
						}
					}
					
					routes.push(route);
				}
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
			var to:int 			   = entry.destination;
			paths.push(from);
			
			if (entry.distance == 2) {
				paths.push(entry.next);
			}
			else if (entry.distance > 2) {
				var entry:RoutingTableEntry, entries:Vector.<RoutingTableEntry>;
				var table:RoutingTable;
				
				var found:Boolean;
				var visited:Dictionary = new Dictionary();
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
					
					table   = RoutingTable(lut[from]);
					if (!table) {
						continue;
					}
					
					entries = table.entries;
					found   = false;
					for (var i:int = 0, l:int = entries.length; i < l; i++) {
						entry = entries[i];
						if (entry.destination == to) {	
							found = true;
							break;
						}
					}
					
					if (!found) {
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
		
		
		//--------------------------------------------------------------------------
		//
		//  Graph's
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Get global graph
		 * 
		 * @param time
		 */ 
		public function getGlobalGraph(time:uint):Graph
		{
/*			if (time in graphs) {
				return Graph(graphs[time]);
			}
			
			var	graph:Graph = resolveGlobalGraph(time);
			graphs[time] = graph;*/
			
			return resolveGlobalGraph(time);;
		}
		
		/**
		 * Resolve global graph
		 * 
		 * @param node
		 * @param time
		 */ 
		private function resolveGlobalGraph(time:uint):Graph
		{

			var nodes:Vector.<Node> = nodeContainer.nodes;
			var tables:Dictionary   = getTables(time);			
			var table:RoutingTable;
			
			var entries:Vector.<RoutingTableEntry>;
			var entry:RoutingTableEntry;
			
			var uids:Vector.<String> = new Vector.<String>();
			var edges:Vector.<Edge>  = new Vector.<Edge>();
			var edge:Edge;
			
			var node:Node;
			var from:int;
			for (var i:int = 0, l:int = nodes.length; i < l; i++) {
				node  = nodes[i];
				from  = node.id;
				
				table = RoutingTable(tables[from]);
				if (table) {
					uids.push(table.oid);
					
					entries = table.entries;
					for (var j:int = entries.length; j--;) {
						entry = entries[j];
						if (entry.distance == 1) {
							edge = new Edge(from, entry.destination, 1); //
							edges.push(edge);
						}
					}
				}
			}
			var value:String = uids.join("-");
			var key:String   = fnv(value);
			var graph:Graph  = Graph(graphs[key]);
			
			if (!graph) {
				// Create new graph
				graph = new Graph();
				for (i = 0, l = edges.length; i < l; i++) {
					edge = edges[i];
					graph.addEdge(edge.from, edge.to, edge.weight);
				}
				// graphs[key] = graph; // store referencce
			}
			edges = null;
			
			// For a 6minutes simulation we got ~=
			//	 total: 428 unique: 252 lookup: 176
			// meaning that storing a reference with a md5 key reduces the amount of graph objects created around ~30-40 
			
			return graph;
		}
		
	}
}