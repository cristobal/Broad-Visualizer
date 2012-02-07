package com.bienvisto.elements.buffer
{
	import com.bienvisto.core.aggregate.Aggregate;
	import com.bienvisto.core.aggregate.AggregateDataProvider;
	import com.bienvisto.core.aggregate.IAggregateProvider;
	
	/**
	 * BuffersDataProvider.as
	 * 	Old VariableBuffers class
	 * 
	 * @author Miguel Santirso
	 * @author Cristobal Dabed
	 */
	public final class BuffersDataProvider extends AggregateDataProvider
	{
		
		public function BuffersDataProvider(buffers:Buffers)
		{
			super("Packets in buffer", buffers);
		}
		
		/**
		 * @override
		 */ 
		override protected function aggregateSum(oldValue:Number, group:int, size:int, item:Aggregate):Number
		{
			return (oldValue * size + Buffer(item).size) / (size + 1);
		}
	}
}