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

			if (!(id in collections)) {
				collections[id] = new ReceptionCollection(
					nodeContainer.getNode(id)
				);
			}		
			
			ReceptionCollection(collections[id]).add(
				new Packet(time, from, to, size)
			);
			
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
			var id:int = node.id;
			if (!(id in collections)) {
				return null;
			}
			
			return ReceptionCollection(collections[id]).samplePacketStats(time, windowSize);
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
			
			return ReceptionCollection(collections[id]).sampleTotal(time);
		}
	}
}