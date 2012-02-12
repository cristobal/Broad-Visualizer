package com.broad.elements.sequences.providers
{
	import com.broad.core.aggregate.Aggregate;
	import com.broad.core.aggregate.AggregateDataProvider;
	import com.broad.core.aggregate.IAggregateProvider;
	import com.broad.elements.sequences.sources.SequencesForwarded;
	
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