package com.bienvisto.elements.sequences.providers
{
	import com.bienvisto.core.aggregate.Aggregate;
	import com.bienvisto.core.aggregate.AggregateDataProvider;
	import com.bienvisto.core.aggregate.IAggregateProvider;
	import com.bienvisto.elements.sequences.sources.SequencesSent;
	
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