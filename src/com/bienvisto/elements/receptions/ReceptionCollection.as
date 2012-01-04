package com.bienvisto.elements.receptions
{
	import com.bienvisto.core.aggregate.Aggregate;
	import com.bienvisto.core.aggregate.AggregateCollection;
	import com.bienvisto.elements.network.Node;
	import com.bienvisto.elements.network.Packet;
	import com.bienvisto.elements.network.PacketStats;
	
	import flash.utils.Dictionary;
	
	public final class ReceptionCollection extends AggregateCollection
	{
		public function ReceptionCollection(node:Node)
		{
			super();
			
			this.node = node;
		}
		
		/**
		 * @private
		 */ 
		private var node:Node;
		
		/**
		 * @private
		 */ 
		private var spsCache:Dictionary = new Dictionary();
		
		
		/**
		 * Sample packet stats
		 * 
		 * @param time
		 * @param windowSize
		 */ 
		public function samplePacketStats(time:uint, windowSize:uint):PacketStats
		{
			return processPacketStats(time, windowSize);
/*			var packetStats:PacketStats;
			var key:String = String(time) + "," + String(windowSize);
			if (!(key in spsCache)) {
				packetStats = processPacketStats(time, windowSize);
				spsCache[key] = packetStats;
			}

			else {
				packetStats = PacketStats(spsCache[key]);
			}
			
			return packetStats;	*/
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
			if ((time > 0) && (time <= lastTimeAdded)) {
				var id:int = node.id;
				var totalOwn:int = 0;
				var totalOther:int = 0;
				var packet:Packet;
				var startTime:int = int(time) - int(windowSize);
				if (startTime < 0) {
					startTime = 0;
				}
				
				var key:int = findNearestKeyMid(time);
				for (var i:int = key + 1; i--;) {
					packet = Packet(_items[i]);
					if (packet.time < startTime) {
						break;
					}
					
					if (packet.to == id) {
						totalOwn++;
					}
					else {
						totalOther++;
					}
				}
				
				if ((totalOwn +  totalOther)> 0) {
					packetStats = new PacketStats(node, _items[key].time, totalOwn, totalOther);
				}
			}
			
			return packetStats;
		}
	}
}