package com.bienvisto.elements.transmissions
{
	import com.bienvisto.core.aggregate.Aggregate;
	import com.bienvisto.core.aggregate.AggregateCollection;
	import com.bienvisto.elements.network.Packet;
	
	import flash.utils.Dictionary;
	
	// TODO: Optimize cache
	public final class TransmissionCollection extends AggregateCollection
	{
		public function TransmissionCollection()
		{
			super();
		}
		
		/**
		 * @private
		 */ 
		private var itemCache:Dictionary = new Dictionary();
		
		/**
		 * @private
		 */ 
		private var packetsCache:Dictionary = new Dictionary();
		
		/**
		 * @override
		 */ 
		override public function findNearest(time:uint):Aggregate
		{
			var item:Aggregate;
			if (!(time in itemCache)) {
				item = super.findNearest(time);
				if (item) {
					itemCache[time] = item;
				}
			}
			else {
				item = itemCache[time];
			}
			
			return item;
		}
		
		/**
		 * Sample packets
		 * 
		 * @param time
		 * @param windowSize
		 */ 
		public function samplePackets(time:uint, windowSize:uint):Vector.<Packet>
		{
			return Vector.<Packet>(super.sampleItems(time, windowSize));
/*			var packets:Vector.<Packet>;
			var key:String = String(time) + "," + String(windowSize);
			
			if (!(key in packetsCache)) {
				packets = Vector.<Packet>(super.sampleItems(time, windowSize));
				if (packets && packets.length > 0) {					packetsCache[key] = packets;
				}
			}
				
			else {
				packets = Vector.<Packet>(packetsCache[key]);
			}
			
			return packets;*/
		}
		
	}
}