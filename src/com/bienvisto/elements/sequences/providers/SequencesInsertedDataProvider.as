package com.bienvisto.elements.sequences.providers
{
	import com.bienvisto.core.aggregate.Aggregate;
	import com.bienvisto.core.aggregate.AggregateDataProvider;
	import com.bienvisto.core.aggregate.IAggregateProvider;
	import com.bienvisto.elements.sequences.sources.SequencesInserted;
	
	/**
	 * SequencesInsertedDataProvider.as
	 * 
	 * @author Cristobal Dabed
	 */ 
	public final class SequencesInsertedDataProvider extends AggregateDataProvider
	{
		public function SequencesInsertedDataProvider(sequencesInserted:SequencesInserted)
		{
			super("Sequence Inserted", sequencesInserted);
		}
		
		/**
		 * @override
		 */ 
		override protected function aggregateSum(oldValue:Number, group:int, size:int, item:Aggregate):Number
		{
			// we count one more inserted sequence
			return oldValue + 1;
		}
	}
}