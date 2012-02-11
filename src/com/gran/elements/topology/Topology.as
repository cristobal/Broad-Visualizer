package com.gran.elements.topology
{
	import com.gran.core.ISimulationObject;
	import com.gran.core.aggregate.AggregateCollection;
	import com.gran.core.network.graph.Graph;
	import com.gran.core.network.node.Node;
	import com.gran.core.network.node.NodeContainer;
	import com.gran.core.parser.TraceSource;
	
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	/**
	 * @Event
	 * 	The init event will be dispatched when the first topology set has been parsed.
	 */
	[Event(name="init", type="flash.events.Event")]
	
	/**
	 * TopologySet.as
	 * 	Class responsible of parsing "topology sets" from the trace source.
	 * 
	 * @author Cristobal Dabed
	 */ 
	public final class Topology extends TraceSource implements ISimulationObject
	{
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 */
		public function Topology(nodeContainer:NodeContainer)
		{
			super("Topology Set", "ts");
			this.nodeContainer = nodeContainer;
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		/**
		 * @private
		 * 	A references to the node container for all the current nodes  present in the simulation
		 */  
		private var nodeContainer:NodeContainer;
		
		/**
		 * @private
		 * 	A collection of AggregateCollection that stores topology set aggregates for each node
		 */  
		private var collections:Dictionary = new Dictionary();
		
		/**
		 * @private
		 *  A hash map to lookup sampled sets that have already been calculated
		 */ 
		private var sets:Dictionary = new Dictionary();
		
		/**
		 * @private
		 * 	The last point in time at which we sampled a waypoint
		 */ 
		private var delta:uint = uint.MAX_VALUE;
		
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
			collections = new Dictionary();
			sets		= new Dictionary();
			
			delta       = uint.MAX_VALUE;
			complete	= false;
			init		= false;
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Override TraceSource Methods
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
			// FORMAT: ts <node id> <time> <destAddr> <lastAddr> <sequenceNumber> <expirationTime> …
			var id:int = int(params[0]);
			var time:uint = uint(params[1]);
			
			if (!(id in collections)) {
				collections[id] = new AggregateCollection();
				sets[id]		= new Dictionary();
			}
			
			// Even if tuples have length 0 we add them since OLSR dictates that 
			var tuples:Vector.<TopologyTuple> = parseTuples(params.splice(2, params.length - 2));
			AggregateCollection(collections[id]).add(
				new TopologySet(time, tuples)
			);
			delta = time;
			
			if (!init) {
				dispatchEvent(new Event(Event.INIT));
				init = true;
			}
			
			return time;
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
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
		 * Get local graph
		 * 
		 * @param node
		 * @param time
		 */ 
		public function getLocalGraph(node:Node, time:uint):Graph
		{
			// lookup the set and get the graph for the set instead of creating new graphs reduces the amount of graphs created drastically.
			// Since its one 1 graph per existing set, instead of creating multiple equal graphs for a same given set
			var set:TopologySet = getTopologySet(node, time);
			return set ? set.graph : null;
		}
		
		/**
		 * Get topology set
		 * 
		 * @param node
		 * @param time
		 */ 
		public function getTopologySet(node:Node, time:uint):TopologySet
		{
			var id:int = node.id;
			if (!(id in collections)) {
				return null;
			}
			
			if (time in sets[id]) {
				return TopologySet(sets[id][time]);
			}
			
			
			var set:TopologySet = TopologySet(AggregateCollection(collections[id]).findNearest(time));
			
			// only cache after parsing completed or if the time is before the last sampled value
			if (complete || time < delta) {
				sets[id][time] = set;	
			}
			
			return set;
		}
		
	}
}