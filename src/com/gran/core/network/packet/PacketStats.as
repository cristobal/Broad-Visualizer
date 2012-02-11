package com.gran.core.network.packet
{
	
	/**
	 * PacketStats.as
	 * 
	 * @author Cristobal Dabed
	 */ 
	public final class PacketStats
	{
		public function PacketStats(time:uint, totalOwn:int, totalOther:int)
		{
			_time		= time;
			_totalOwn 	= totalOwn;
			_totalOther = totalOther;
		}
		
		/**
		 * @private
		 */ 
		private var _time:uint;
		
		/**
		 * @readonly time
		 */ 
		public function get time():uint
		{
			return _time;
		}
		
		/**
		 * @private
		 */ 
		private var _totalOwn:int;
		
		/**
		 * @readonly totalOwn
		 */ 
		public function get totalOwn():int
		{
			return _totalOwn;
		}
		
		/**
		 * @private
		 */ 
		private var _totalOther:int
		
		/**
		 * @readonly totalOther
		 */ 
		public function get totalOther():int
		{
			return _totalOther;
		}
	}
}