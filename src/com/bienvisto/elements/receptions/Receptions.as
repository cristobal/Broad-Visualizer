package com.bienvisto.elements.receptions
{
	import com.bienvisto.core.ISimulationObject;
	import com.bienvisto.core.aggregate.AggregateCollection;
	import com.bienvisto.core.parser.TraceSource;
	import com.bienvisto.elements.network.Node;
	import com.bienvisto.elements.network.NodeContainer;
	import com.bienvisto.elements.network.Packet;
	import com.bienvisto.elements.network.PacketStats;
	
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
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
		public function Receptions(nodeContainer:NodeContainer)
		{
			super("Mac Receptions", "mr"); // mac receptions
			
			this.nodeContainer = nodeContainer;
		}
		
		/**
		 * @private
		 */ 
		private var nodeContainer:NodeContainer;
		
		/**
		 * @private
		 * 
		 */ 
		private var collections:Dictionary = new Dictionary();
		
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
			
			var node:Node = nodeContainer.getNode(id);
			var packet:Packet = new Packet(time, from, to, size);
			var collection:ReceptionCollection;
			if (!(id in collections)) {
				collection = new ReceptionCollection(node);
				collections[id] = collection;
			}
			else {
				collection = ReceptionCollection(collections[id]);
			}
			
			collection.add(packet);
			
			return time;
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
		 * Sample packet statts
		 * 
		 * @param node
		 * @param time
		 * @param windowSize The window size of packets to highlit in ms
		 */ 
		public function samplePacketStats(node:Node, time:uint, windowSize:uint):PacketStats
		{
			var packetStats:PacketStats;
			var id:int = node.id;
			
			if (id in collections) {
				var collection:ReceptionCollection = ReceptionCollection(collections[id]);
				packetStats = collection.samplePacketStats(time, windowSize);
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
			
			var total:int = 0;
			var id:int = node.id;
			
			if (id in collections) {
				var collection:ReceptionCollection = ReceptionCollection(collections[id]);
				total = collection.sampleTotal(time);
			}
			
			return total;
		}
	}
}