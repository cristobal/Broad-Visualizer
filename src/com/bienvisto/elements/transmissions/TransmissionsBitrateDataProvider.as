package com.bienvisto.elements.transmissions
{
	import com.bienvisto.core.aggregate.Aggregate;
	import com.bienvisto.core.aggregate.AggregateDataProvider;
	import com.bienvisto.core.network.packet.Packet;
 
	/**
	 * TransmissionsBitrateDataProvider.as
	 * 	Old VariableBitrate class
	 * 
	 * @author Miguel Santirso
	 * @author Cristobal Dabed
	 */
	public final class TransmissionsBitrateDataProvider extends AggregateDataProvider
	{
		public function TransmissionsBitrateDataProvider(transmissions:Transmissions)
		{
			super("Bitrate", transmissions);
		}
		
		/**
		 * @override
		 */ 
		override protected function aggregateSum(oldValue:Number, group:int, size:int, item:Aggregate):Number
		{
			return oldValue + Packet(item).size; 
		}
	}
}