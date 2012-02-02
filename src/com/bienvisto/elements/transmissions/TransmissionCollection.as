package com.bienvisto.elements.transmissions
{
	import com.bienvisto.core.aggregate.AggregateCollection;
	import com.bienvisto.elements.network.packet.Packet;
	
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
/*			var key:String = String(time) + "-" + String(windowSize);
			if (key in cache) {
				return Vector.<Packet>(cache[key]);
			}
			
			var items:Vector.<Packet> = Vector.<Packet>(super.sampleItems(time, windowSize));
			cache[key] = items;*/
			
			return Vector.<Packet>(super.sampleItems(time, windowSize));
		}
		
	}
}