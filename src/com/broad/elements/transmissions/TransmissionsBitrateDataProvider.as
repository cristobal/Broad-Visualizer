package com.broad.elements.transmissions
{
	import com.broad.core.aggregate.Aggregate;
	import com.broad.core.aggregate.AggregateDataProvider;
	import com.broad.core.network.packet.Packet;
 
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