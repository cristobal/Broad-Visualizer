package com.bienvisto.elements.routing
{
	import com.bienvisto.core.aggregate.Aggregate;
	
	/**
	 * RoutingStatssItem.as
	 * 
	 * @author Cristobal Dabed
	 */ 
	public final class RoutingStatsItem extends Aggregate
	{
		public function RoutingStatsItem(time:uint, rtsTotal:int, rtsAvgTotal:int)
		{
			super(time);
			
			_rtsTotal = rtsTotal;
			_rtsAvgTotal = rtsAvgTotal;
		}
		
		/**
		 * @private
		 */ 
		private var _rtsTotal:int;
		
		/**
		 * @readonly rtsTotal
		 */ 
		public function get rtsTotal():int
		{
			return _rtsTotal;
		}
		
		/**
		 * @private
		 */ 
		private var _rtsAvgTotal:int;
		
		/**
		 * @readonly rtsTotalAvg
		 */ 
		public function get rtsAvgTotal():int
		{
			return _rtsAvgTotal;
		}
	}
}