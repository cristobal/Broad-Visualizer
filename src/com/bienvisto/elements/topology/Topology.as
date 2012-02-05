package com.bienvisto.elements.topology
{
	import com.bienvisto.core.ISimulationObject;
	import com.bienvisto.core.parser.TraceSource;
	import com.bienvisto.elements.network.graph.Graph;
	import com.bienvisto.elements.network.node.Node;
	import com.bienvisto.elements.network.node.NodeContainer;
	
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	[Event(name="init", type="flash.events.Event")]
	
	/**
	 * TopologySet.as
	 * 
	 * @author Cristobal Dabed
	 */ 
	public final class Topology extends TraceSource implements ISimulationObject
	{
		public function Topology(nodeContainer:NodeContainer)
		{
			super("Topology Set", "ts");
			
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
		 * @private
		 */ 
		private var sets:Dictionary = new Dictionary();
		
		/**
		 * @private
		 */ 
		private var flag:Boolean = false;
		
		/**
		 * @override
		 */ 
		override public function update(params:Vector.<String>):uint
		{
			// FORMAT: ts <node id> <time> <destAddr> <lastAddr> <sequenceNumber> <expirationTime> …
			var id:int = int(params[0]);
			var time:uint = uint(params[1]);
			
			var tuples:Vector.<TopologyTuple> = parseTuples(params.splice(2, params.length - 2));
			if (tuples.length) {
				
				// trace("added new ts for node:", id, ", time:", time, " total of:", tuples.length, "tuples");
				var set:TopologySet = new TopologySet(time, tuples);
				var collection:TopologySetCollection = getCollection(id);	
				collection.add(set);
			}
			if (!flag) {
				dispatchEvent(new Event(Event.INIT));
				flag = true;
			}
			
			return time;
		}
		
		/**
		 * Get collection
		 * 
		 * @param id
		 */ 
		private function getCollection(id:int):TopologySetCollection
		{
			var collection:TopologySetCollection;
			if (!(id in collections)) {
				collection = new TopologySetCollection();	
				collections[id] = collection;
			}
			else {
				collection = TopologySetCollection(collections[id]);
			}
			
			return collection;
		}
		
		/**
		 * Parse tuples
		 * 
		 * @param topologySet
		 */ 
		private function parseTuples(params:Vector.<String>):Vector.<TopologyTuple>
		{
			var tuples:Vector.<TopologyTuple> = new Vector.<TopologyTuple>();
			if (params.length >= 4) {
				
				var addresses:Dictionary = new Dictionary();
				var id:int;
				var addr:String;
				var nodes:Vector.<Node> = nodeContainer.nodes;
				var node:Node;
				for (var i:int = 0, l:int = nodes.length; i < l; i++) {
					node = nodes[i];
					addr = node.ipv4Address;
					id   = node.id;
					addresses[addr] = id;
				}
				
				var destAddr:String;
				var lastAddr:String;
				
				var destID:int;
				var lastID:int;
				var seqNum:int;
				var expTime:uint;
				var tuple:TopologyTuple;
				
				for (i= 0, l = params.length; i < l; i += 4) {
					destAddr = String(params[i]);
					lastAddr = String(params[i + 1]);
					seqNum   = int(params[i + 2]);
					expTime  = uint(params[i + 3]);
					
					if ((destAddr in addresses) && (lastAddr in addresses)) {
						destID = addresses[destAddr];
						lastID = addresses[lastAddr];
						tuple  = new TopologyTuple(destID, lastID, seqNum, expTime);
						tuples.push(tuple);
					}
				}
				
				
			}
			
			return tuples;
		}
		
		/**
		 * Get topology set
		 * 
		 * @param node
		 * @param time
		 */ 
		public function getTopologySet(node:Node, time:uint):TopologySet
		{
			var set:TopologySet;
			var key:String = [node.id, time].join("-");
			
			if (!(key in sets)){
				set = resolveSet(node, time);
				sets[key] = set;
			}
			else {
				set = TopologySet(sets[key]);
			}
			
			return set;
		}
		
		/**
		 * Get local graph
		 * 
		 * @param node
		 * @param time
		 */ 
		public function getLocalGraph(node:Node, time:uint):Graph
		{
			var graph:Graph;
			
			// lookup the set and get the graph for the set instead of creating new graphs reduces the amount of graphs created drastically.
			// Since its one 1 graph per existing set, instead of creating multiple equal graphs for a same given set
			var set:TopologySet = getTopologySet(node, time);
			if (set) {
				graph = set.graph;
			}
			
			return graph;
		}
	
		
		/**
		 * Resolve set
		 * 
		 * @param node
		 * @param time
		 */ 
		private function resolveSet(node:Node, time:uint):TopologySet
		{
			var set:TopologySet;
			
			var collection:TopologySetCollection = getCollection(node.id);
			if (collection) {
				set = TopologySet(collection.findNearest(time));
			}
			
			return set;
		}
		
		
		public function onTimeUpdate(elapsed:uint):void
		{
		}
		
		public function setDuration(duration:uint):void
		{
		}
	}
}