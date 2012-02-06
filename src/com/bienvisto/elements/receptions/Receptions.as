package com.bienvisto.elements.receptions
{
	import com.bienvisto.core.ISimulationObject;
	import com.bienvisto.core.aggregate.AggregateCollection;
	import com.bienvisto.core.parser.TraceSource;
	import com.bienvisto.elements.network.node.Node;
	import com.bienvisto.elements.network.node.NodeContainer;
	import com.bienvisto.elements.network.packet.Packet;
	import com.bienvisto.elements.network.packet.PacketStats;
	
	import flash.utils.Dictionary;
	
	/**
	 * Receptions.as
	 * 	A trace source subclass which parses all the trace sources 
	 *  for the mac receptions event type in the simulations.
	 * 
	 * @author Miguel Santirso
	 * @author Cristobal Dabed
	 */  
	public final class Receptions extends TraceSource implements ISimulationObject
	{
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Constructor
		 * 
		 * @param nodeContainer
		 */
		public function Receptions(nodeContainer:NodeContainer)
		{
			super("Mac Receptions", "mr"); // mac receptions
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
		 * 	A collection of AggregateCollection that stores packet arggreate received at each node
		 */
		private var collections:Dictionary = new Dictionary();
		
		/**
		 * @private
		 * 	A hash map to lookup sampled items that have already been calculated
		 */ 
		private var samples:Dictionary     = new Dictionary();
		
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
			samples		= new Dictionary();
			complete    = false;
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
			// mr <node id> <time> <packet_size> <last_hop_id> <next_hop_id>
			var id:int 		= int(params[0]);
			var time:uint 	= uint(params[1]);
			var size:Number = uint(params[2]);
			var from:int 	= int(params[3]);
			var to:int 		= int(params[4]);

			if (!(id in collections)) {
				collections[id] = new AggregateCollection();
				samples[id]		= new Dictionary();
			}		
			
			AggregateCollection(collections[id]).add(
				new Packet(time, from, to, size)
			);
			
			return time;
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Sample packet stats
		 * 
		 * @param node
		 * @param time
		 * @param windowSize The window size of packets to highlit in ms
		 */ 
		public function samplePacketStats(node:Node, time:uint, windowSize:uint):PacketStats
		{
			var id:int = node.id;
			if (!(id in collections)) {
				return null;
			}
			
			var key:String = String(time) + "-" + String(windowSize);
			if (key in samples[id]) {
				return PacketStats(samples[id][key]);
			}
			
			var packetStats:PacketStats = resolvePacketStats(node, time, windowSize);
			// only cache if parsing complete
			if (complete) {
				samples[id][key] = packetStats;
			}
			
			return packetStats;
		}
		
		
		/**
		 * Resolve packet stats
		 * 
		 * @param node
		 * @param time
		 * @param windowSize
		 */ 
		private function resolvePacketStats(node:Node, time:uint, windowSize:uint):PacketStats
		{
			if (time == 0) {
				return null;
			}
				
			var id:int = node.id;
			var collection:AggregateCollection = AggregateCollection(collections[id]);
			var items:Vector.<Packet> 		   = Vector.<Packet>(collection.items);
			var totalOwn:int = 0;
			var totalOther:int = 0;
			var packet:Packet;
			var startTime:Number = time - windowSize;
			if (startTime < 0) {
				startTime = 0;
			}
			
			var key:int = collection.findNearestKey(time);
			for (var i:int = key + 1; i--;) {
				packet = items[i];
				if (packet.time < startTime) {
					break;
				}
				
				// add only if inside window
				if (packet.time > time) {
					continue;
				}
				
				if (packet.to == id) {
					totalOwn++;
				}
				else {
					totalOther++;
				}
			}
			var packetStats:PacketStats;
			if ((totalOwn + totalOther) > 0) {
				packetStats = new PacketStats(id, items[key].time, totalOwn, totalOther);
			}
			
			return packetStats;
		}
		
		/**
		 * Sample total
		 * 
		 * @param node
		 * @param time
		 */ 
		public function sampleTotal(node:Node, time:uint):int
		{
			var id:int = node.id;
			if (!(id in collections)) {
				return 0;
			}
			
			return AggregateCollection(collections[id]).sampleTotal(time);
		}
		
	}
}