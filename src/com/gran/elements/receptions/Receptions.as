package com.gran.elements.receptions
{
	import com.gran.core.ISimulationObject;
	import com.gran.core.aggregate.Aggregate;
	import com.gran.core.aggregate.AggregateCollection;
	import com.gran.core.aggregate.IAggregateProvider;
	import com.gran.core.network.node.Node;
	import com.gran.core.network.node.NodeContainer;
	import com.gran.core.network.packet.Packet;
	import com.gran.core.network.packet.PacketStats;
	import com.gran.core.parser.TraceSource;
	
	import flash.utils.Dictionary;
	
	/**
	 * Receptions.as
	 * 	A trace source subclass which parses all the trace sources 
	 *  for the mac receptions event type in the simulations.
	 * 
	 * @author Miguel Santirso
	 * @author Cristobal Dabed
	 */  
	public final class Receptions extends TraceSource implements ISimulationObject, IAggregateProvider
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
		private var samples:Dictionary = new Dictionary();
		
		/**
		 * @private
		 * 	The last point in time at which we sampled a mac reception
		 */ 
		private var delta:uint = uint.MAX_VALUE;
		
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
			
			delta    = uint.MAX_VALUE;
			complete = false;
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
			delta = time;
			
			return time;
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  Methods
		//
		//--------------------------------------------------------------------------
		
		public function samplePacket(node:Node, time:uint):Packet
		{
			var id:int = node.id;
			if (!(id in collections)) {
				return null;
			}
			
			return Packet(AggregateCollection(collections[id]).findNearest(time));
		}
		
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
			// only cache after parsing completed or if the time is before the last sampled value
			if (complete || time < delta) {
				samples[id][key] = packetStats;
			}
			
			return packetStats;
		}
		
		private var totalCreated:Number = 0;
		
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
				packetStats = new PacketStats(items[key].time, totalOwn, totalOther);	
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
		
		/**
		 * Sample rate
		 * 
		 * @param node
		 * @param time
		 */ 
		public function sampleRate(node:Node, time:int):int
		{
			
			var id:int = node.id;
			if (!(id in collections)) {
				return 0;	
			}
			
			var rate:int = 0;
			var collection:AggregateCollection = AggregateCollection(collections[id]);
			var windowSize:int = 1000;
			var up:int = time - (time % windowSize);
			if (up > 0) {	
				var lb:int = time - windowSize;	
				var start:int = collection.findNearestKey(lb);
				var end:int   = collection.findNearestKey(up);
				
				rate = end - start;
			}
			
			return rate;
		}
		
		
		//--------------------------------------------------------------------------
		//
		//  IAggregateDataProvider Implementation
		//
		//--------------------------------------------------------------------------
		
		/**
		 * Get items
		 * 
		 * @param node
		 */ 
		public function getItems(node:Node):Vector.<Aggregate>
		{
			var id:int = node.id;
			if (!(id in collections)) {
				return null;
			}
			
			return AggregateCollection(collections[id]).items;
		}
		
	}
}