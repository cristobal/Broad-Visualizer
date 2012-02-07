package com.bienvisto.elements.sequences.providers
{
	import com.bienvisto.core.aggregate.Aggregate;
	import com.bienvisto.core.aggregate.AggregateDataProvider;
	import com.bienvisto.core.aggregate.IAggregateProvider;
	import com.bienvisto.elements.sequences.sources.SequencesForwarded;
	
	/**
	 * SequencesForwardedDataProvider.as
	 * 
	 * @author Cristobal Dabed
	 */ 
	public final class SequencesForwardedDataProvider extends AggregateDataProvider
	{
		public function SequencesForwardedDataProvider(sequencesForwarded:SequencesForwarded)
		{
			super("Sequence Forwarded", sequencesForwarded);
		}
		
		/**
		 * @override
		 */ 
		override protected function aggregateSum(oldValue:Number, group:int, size:int, item:Aggregate):Number
		{
			// we count one more forwarded sequence
			return oldValue + 1;
		}
	}
}