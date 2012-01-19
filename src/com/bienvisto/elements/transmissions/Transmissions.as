package com.bienvisto.elements.transmissions
{
	import com.bienvisto.core.ISimulationObject;
	import com.bienvisto.core.aggregate.Aggregate;
	import com.bienvisto.core.aggregate.AggregateCollection;
	import com.bienvisto.core.parser.TraceSource;
	import com.bienvisto.elements.network.Node;
	import com.bienvisto.elements.network.NodeContainer;
	import com.bienvisto.elements.network.Packet;
	
	import flash.utils.Dictionary;
	
	/**
	 * Transmissions.as
	 * 	A trace source subclass which parses all the trace sources 
	 *  for the mac transmisions event type in the simulations.
	 * 
	 * @author Miguel Santirso
	 * @author Cristobal Dabed
	 */ 
	public final class Transmissions extends TraceSource implements ISimulationObject
	{
		public function Transmissions(nodeContainer:NodeContainer)
		{
			super("Mac Transmissions", "mt"); // mac transmissions
			
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
		 * @override
		 */ 
		override public function update(params:Vector.<String>):uint
		{
						
			// format: mt <node id> <time> <packet_size> <next_hop_id> 
			var id:int = int(params[0]);
			var time:uint = uint(params[1]);
			var size:Number = uint(params[2]);
			var destination:int = int(params[3]);;
			var packet:Packet = new Packet(time, id, destination, size);
			
			var collection:TransmissionCollection;
			if (!(id in collections)) {
				collection = new TransmissionCollection();
				collections[id] = collection;
			}
			else {
				collection = TransmissionCollection(collections[id])
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
		 * Find nearest
		 * 
		 * @param node
		 * @param time
		 * @param windowSize
		 */ 
		public function findNearest(node:Node, time:uint, windowSize:uint):Aggregate
		{
			var id:int = node.id;
			var item:Aggregate;
			
			if (id in collections) {
				var collection:TransmissionCollection = TransmissionCollection(collections[id]);
				item = collection.findNearest(time);
			}
			
			return item;
		}
		
		/**
		 * Sample packets
		 * 
		 * @param node
		 * @param time
		 * @param windowSize
		 */ 
		public function samplePackets(node:Node, time:uint, windowSize:uint):Vector.<Packet>
		{
			var packets:Vector.<Packet>;
			var id:int = node.id;
			
			if (id in collections) {
				var collection:TransmissionCollection = TransmissionCollection(collections[id]);
				packets = collection.samplePackets(time, windowSize);
			}
			
			return packets;
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
				var collection:TransmissionCollection = TransmissionCollection(collections[id]);
				total = collection.sampleTotal(time);
			}
			
			return total;
		}
		
	}
}