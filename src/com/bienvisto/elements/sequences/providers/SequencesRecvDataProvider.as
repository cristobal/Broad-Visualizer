package com.bienvisto.elements.sequences.providers
{
	import com.bienvisto.core.aggregate.Aggregate;
	import com.bienvisto.core.aggregate.AggregateDataProvider;
	import com.bienvisto.core.aggregate.IAggregateProvider;
	import com.bienvisto.elements.sequences.sources.SequencesRecv;
	
	/**
	 * SequencesRecvDataProvider.as
	 * 
	 * @author Cristobal Dabed
	 */ 
	public final class SequencesRecvDataProvider extends AggregateDataProvider
	{
		public function SequencesRecvDataProvider(sequencesRecv:SequencesRecv)
		{
			super("Sequence Recv", sequencesRecv);
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