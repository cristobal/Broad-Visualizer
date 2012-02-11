package com.gran.elements.sequences.providers
{
	import com.gran.core.aggregate.Aggregate;
	import com.gran.core.aggregate.AggregateDataProvider;
	import com.gran.core.aggregate.IAggregateProvider;
	import com.gran.elements.sequences.sources.SequencesSent;
	
	/**
	 * SequencesSentDataProvider.as
	 * 
	 * @author Cristobal Dabed
	 */ 
	public final class SequencesSentDataProvider extends AggregateDataProvider
	{
		public function SequencesSentDataProvider(sequencesSent:SequencesSent)
		{
			super("Sequence Sent", sequencesSent);
		}
		
		/**
		 * @override
		 */ 
		override protected function aggregateSum(oldValue:Number, group:int, size:int, item:Aggregate):Number
		{
			// we count one more recv sequence
			return oldValue + 1;
		}
	}
}