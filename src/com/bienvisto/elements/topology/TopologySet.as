package com.bienvisto.elements.topology
{
	import com.bienvisto.core.aggregate.Aggregate;
	
	/**
	 * TopologySet.as
	 * 
	 * @author Cristobal Dabed
	 */ 
	public class TopologySet extends Aggregate
	{
		public function TopologySet(time:uint, tuples:Vector.<TopologyTuple>)
		{
			super(time);
			
			_tuples = tuples;
			if (!_tuples) {
				_tuples = new Vector.<TopologyTuple>();
			}
		}
		
		
		/**
		 * @private 
		 */ 
		private var _tuples:Vector.<TopologyTuple>;
		
		/**
		 * @readonly tuples
		 */ 
		public function get tuples():Vector.<TopologyTuple>
		{
			return _tuples;
		}
	}
}