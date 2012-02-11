package com.gran.elements.buffer
{
	import com.gran.core.aggregate.Aggregate;
	import com.gran.core.aggregate.AggregateDataProvider;
	import com.gran.core.aggregate.IAggregateProvider;
	
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