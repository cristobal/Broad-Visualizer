package com.bienvisto.elements.transmissions
{
	import com.bienvisto.core.aggregate.Aggregate;
	import com.bienvisto.core.aggregate.AggregateCollection;
	import com.bienvisto.elements.network.Packet;
	
	import flash.utils.Dictionary;
	
	public final class TransmissionCollection extends AggregateCollection
	{
		public function TransmissionCollection()
		{
			super();
		}
		
		
		
		/**
		 * @private
		 */ 
		private var cache:Dictionary = new Dictionary();
		
		/**
		 * Sample packets
		 * 
		 * @param time
		 * @param windowSize
		 */ 
		public function samplePackets(time:uint, windowSize:uint):Vector.<Packet>
		{
			var packets:Vector.<Packet>;
			var key:String = String(time) + "," + String(windowSize);
			if (!(key in cache)) {
				var item:Aggregate = findNearest(time);
				if (item && item.time >= time)  {
					packets = Vector.<Packet>(super.sampleItems(time, windowSize));
				}
				cache[key] = packets;
			}
				
			else {
				packets = cache[key];
			}
			
			return packets;
		}
		
		private function processPackets(time:uint, windowSize:uint):Vector.<Packet>
		{
			var packets:Vector.<Packet> = new Vector.<Packet>();
			if ((time > 0) && (time <= lastTimeAdded)) {
				
				var packet:Packet;
				var startTime:int = int(time) - int(windowSize);
				if (startTime < 0) {
					startTime = 0;
				}
				
				var key:int = findNearestKeyMid(time);
				var total:int = 0;
				for (var i:int = key + 1; i--;) {
					packet = Packet(_items[i]);
					if (packet.time < startTime) {
						break;
					}
					
					packets.push(packet);
					total++;
				}
			}
			
			return packets;
		}
	}
}