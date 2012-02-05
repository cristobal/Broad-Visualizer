package com.bienvisto.elements.receptions
{
	import com.bienvisto.core.aggregate.Aggregate;
	import com.bienvisto.core.aggregate.AggregateCollection;
	import com.bienvisto.elements.network.node.Node;
	import com.bienvisto.elements.network.packet.Packet;
	import com.bienvisto.elements.network.packet.PacketStats;
	
	import flash.utils.Dictionary;
	
	public final class ReceptionCollection extends AggregateCollection
	{
		public function ReceptionCollection(node:Node)
		{
			super();
			clear();
			
			this.node = node;
		}
		
		/**
		 * @private
		 */ 
		private var node:Node;
		
		/**
		 * @private
		 */ 
		private var cache:Dictionary = new Dictionary();
		
		
		/**
		 * Sample packet stats
		 * 
		 * @param time
		 * @param windowSize
		 */ 
		public function samplePacketStats(time:uint, windowSize:uint):PacketStats
		{
			var key:String = String(time) + "-" + String(windowSize);
			if (key in cache) {
				return PacketStats(cache[key]);
			}
			var packetStats:PacketStats = processPacketStats(time, windowSize);
			if (packetStats) {
				cache[key] = packetStats;
			}
			
			return packetStats;
		}
		
		/**
		 * Process packet stats
		 * 
		 * @param time
		 * @param windowSize
		 */ 
		private function processPacketStats(time:uint, windowSize:uint):PacketStats
		{
			
			var packetStats:PacketStats;
			if (time > 0) {
				var id:int = node.id;
				var totalOwn:int = 0;
				var totalOther:int = 0;
				var packet:Packet;
				var startTime:Number = time - windowSize;
				if (startTime < 0) {
					startTime = 0;
				}
				
				var key:int = findNearestKey(time);
				for (var i:int = key + 1; i--;) {
					packet = Packet(_items[i]);
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
				
				if ((totalOwn + totalOther) > 0) {
					packetStats = new PacketStats(id, _items[key].time, totalOwn, totalOther);
				}
			}
			
			return packetStats;
		}
		
		
		/**
		 * Clear
		 */ 
		public function clear():void
		{
			cache = new Dictionary();
		}
	}
}