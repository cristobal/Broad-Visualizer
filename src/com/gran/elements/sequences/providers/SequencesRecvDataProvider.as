package com.gran.elements.sequences.providers
{
	import com.gran.core.aggregate.Aggregate;
	import com.gran.core.aggregate.AggregateDataProvider;
	import com.gran.core.aggregate.IAggregateProvider;
	import com.gran.elements.sequences.sources.SequencesRecv;
	
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