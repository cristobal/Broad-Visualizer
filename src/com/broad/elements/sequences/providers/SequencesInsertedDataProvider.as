package com.broad.elements.sequences.providers
{
	import com.broad.core.aggregate.Aggregate;
	import com.broad.core.aggregate.AggregateDataProvider;
	import com.broad.core.aggregate.IAggregateProvider;
	import com.broad.elements.sequences.sources.SequencesInserted;
	
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