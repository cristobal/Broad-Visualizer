package com.bienvisto.elements.topology
{
	import com.bienvisto.core.ISimulationObject;
	import com.bienvisto.core.parser.TraceSource;
	import com.bienvisto.elements.network.node.Node;
	import com.bienvisto.elements.network.node.NodeContainer;
	
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	[Event(name="change", type="flash.events.Event")]
	
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
		private var flag:Boolean = false;
		
		/**
		 * @override
		 */ 
		override public function update(params:Vector.<String>):uint
		{
			// FORMAT: cc <node id> <time> <destAddr> <lastAddr> <sequenceNumber> <expirationTime> …
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
				dispatchEvent(new Event(Event.CHANGE));
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
						tuple = new TopologyTuple(destID, lastID, seqNum, expTime);
						tuples.push(tuple);
					}
				}
			}
			
			return tuples;
		}
		
		public function onTimeUpdate(elapsed:uint):void
		{
		}
		
		public function setDuration(duration:uint):void
		{
		}
	}
}