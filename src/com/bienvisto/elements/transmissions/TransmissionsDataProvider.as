package com.bienvisto.elements.transmissions
{
	import com.bienvisto.core.aggregate.Aggregate;
	import com.bienvisto.core.aggregate.AggregateDataProvider;
	import com.bienvisto.core.aggregate.IAggregateProvider;
	
	/**
	 * TransmissionsDataProvider.as
	 * 	Old VariablePacketForwarded class
	 * 
	 * @author Miguel Santirso
	 * @author Cristobal Dabed
	 */ 
	public class TransmissionsDataProvider extends AggregateDataProvider
	{
		public function TransmissionsDataProvider(transmissions:Transmissions)
		{
			super("Packets Forwarded", transmissions);
		}
		
		/**
		 * @override
		 */ 
		override protected function aggregateSum(oldValue:Number, group:int, size:int, item:Aggregate):Number
		{
			// we add one packet forwarded
			return oldValue + 1; 
		}
	}
}