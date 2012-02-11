package com.gran.elements.receptions
{
	import com.gran.core.aggregate.Aggregate;
	import com.gran.core.aggregate.AggregateDataProvider;
	import com.gran.core.aggregate.IAggregateProvider;
	
	/**
	 * ReceptionsDataProvider.as
	 * 	Old VariableReceptions class
	 * 
	 * @author Miguel Santirso
	 * @author Cristobal Dabed
	 */
	public final class ReceptionsDataProvider extends AggregateDataProvider
	{
		public function ReceptionsDataProvider(receptions:Receptions)
		{
			super("Packets Received", receptions);
		}
		
		/**
		 * @override
		 */ 
		override protected function aggregateSum(oldValue:Number, group:int, size:int, item:Aggregate):Number
		{
			// we count one more packet
			return oldValue + 1;
		}
		
	}
}