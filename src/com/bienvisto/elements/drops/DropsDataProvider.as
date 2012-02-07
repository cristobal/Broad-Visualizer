package com.bienvisto.elements.drops
{
	import com.bienvisto.core.aggregate.Aggregate;
	import com.bienvisto.core.aggregate.AggregateDataProvider;
	import com.bienvisto.core.aggregate.IAggregateProvider;
	
	/**
	 * DropsDataProvider.as
	 * 	Old VariableDrops class
	 * 
	 * @author Miguel Santirso
	 * @author Cristobal Dabed
	 */
	public final class DropsDataProvider extends AggregateDataProvider
	{
		public function DropsDataProvider(drops:Drops)
		{
			super("Packets Dropped", drops);
		}
		
		/**
		 * @override
		 */ 
		override protected function aggregateSum(oldValue:Number, group:int, size:int, item:Aggregate):Number
		{
			return oldValue + 1; // we add one more drop
		}
	}
}